// keyholder.dart
//
// Flutter/Dart port of the KeyHolder password manager core.
//
// Dependencies (add to pubspec.yaml):
//   pointycastle: ^3.9.1
//   crypto: ^3.0.3
//
// dart:convert and dart:typed_data are part of the Dart SDK — no extra install needed.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;
import 'package:pointycastle/export.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 1 — Encryption / Decryption  (mirrors encrypt.py)
// ─────────────────────────────────────────────────────────────────────────────

/// Derives a 16-byte AES-128 key from [password] using SHA-256.
Uint8List _deriveKey(String password) {
  final digest = crypto.sha256.convert(utf8.encode(password));
  return Uint8List.fromList(digest.bytes.sublist(0, 16));
}

/// Generates [length] cryptographically random bytes.
Uint8List _randomBytes(int length) {
  final rng = Random.secure();
  return Uint8List.fromList(List.generate(length, (_) => rng.nextInt(256)));
}

/// Pads [data] to a multiple of [blockSize] using PKCS7.
Uint8List _pkcs7Pad(Uint8List data, int blockSize) {
  final padLen = blockSize - (data.length % blockSize);
  return Uint8List.fromList([...data, ...List.filled(padLen, padLen)]);
}

/// Removes PKCS7 padding from [data].
Uint8List _pkcs7Unpad(Uint8List data) {
  final padLen = data.last;
  return Uint8List.fromList(data.sublist(0, data.length - padLen));
}

/// Encrypts [plaintext] with [password] using AES-128-CBC + SHA-256 MAC.
///
/// Returns a JSON string: {"iv": "...", "ciphertext": "...", "mac": "..."}
String encrypt(String plaintext, String password) {
  final key = _deriveKey(password);
  final iv = _randomBytes(16);

  // AES-CBC encrypt
  final cipher = CBCBlockCipher(AESEngine())
    ..init(true, ParametersWithIV(KeyParameter(key), iv));

  final padded = _pkcs7Pad(Uint8List.fromList(utf8.encode(plaintext)), 16);
  final ciphertext = Uint8List(padded.length);
  for (var offset = 0; offset < padded.length; offset += 16) {
    cipher.processBlock(padded, offset, ciphertext, offset);
  }

  // SHA-256 MAC over key + ciphertext
  final macInput = Uint8List.fromList([...key, ...ciphertext]);
  final mac = Uint8List.fromList(crypto.sha256.convert(macInput).bytes);

  return jsonEncode({
    'iv': _bytesToHex(iv),
    'ciphertext': _bytesToHex(ciphertext),
    'mac': _bytesToHex(mac),
  });
}

/// Decrypts a JSON string produced by [encrypt].
///
/// Throws [ArgumentError] if the MAC check fails.
/// Returns "[]" if the JSON cannot be parsed (mirrors Python behaviour).
String decrypt(String s, String password) {
  final key = _deriveKey(password);

  Map<String, dynamic> data;
  try {
    data = jsonDecode(s) as Map<String, dynamic>;
  } catch (_) {
    return '[]';
  }

  final iv = _hexToBytes(data['iv'] as String);
  final ciphertext = _hexToBytes(data['ciphertext'] as String);
  final mac = _hexToBytes(data['mac'] as String);

  // Verify MAC
  final macInput = Uint8List.fromList([...key, ...ciphertext]);
  final macCheck = Uint8List.fromList(crypto.sha256.convert(macInput).bytes);
  if (!_bytesEqual(mac, macCheck)) {
    throw ArgumentError('MAC check failed');
  }

  // AES-CBC decrypt
  final cipher = CBCBlockCipher(AESEngine())
    ..init(false, ParametersWithIV(KeyParameter(key), iv));

  final padded = Uint8List(ciphertext.length);
  for (var offset = 0; offset < ciphertext.length; offset += 16) {
    cipher.processBlock(ciphertext, offset, padded, offset);
  }

  return utf8.decode(_pkcs7Unpad(padded));
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 2 — File I/O  (mirrors load_file.py)
// ─────────────────────────────────────────────────────────────────────────────
//
// Flutter does not have direct filesystem access the same way as desktop Python.
// Pass file *bytes* (from file_picker or path_provider) into these helpers.
//
// A KeyHolder record is a List<dynamic> with the layout:
//   [name, username, password, date_string, time_tag_as_double]

typedef KHRecord = List<dynamic>;

/// Decrypts [encryptedBytes] with [password] and returns the record list.
/// Returns null if decryption fails (wrong password, corrupt file, etc.).
List<KHRecord>? loadEncrypted(Uint8List encryptedBytes, String password) {
  try {
    final s = utf8.decode(encryptedBytes);
    final plaintext = decrypt(s, password);
    final parsed = jsonDecode(plaintext);
    if (parsed is List) {
      return parsed.cast<KHRecord>();
    }
  } catch (_) {
    // wrong password or corrupt data
  }
  return null;
}

/// Encrypts [records] with [password] and returns the raw bytes to write to disk.
Uint8List dumpEncrypted(List<KHRecord> records, String password) {
  final encrypted = encrypt(jsonEncode(records), password);
  return Uint8List.fromList(utf8.encode(encrypted));
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 3 — Unencrypted import  (mirrors import_unencrypted_keyholder_profile)
// ─────────────────────────────────────────────────────────────────────────────

/// Parses an unencrypted KeyHolder JSON export (a JSON array of arrays).
///
/// Returns the record list, or null if the data is not a valid KeyHolder file.
List<KHRecord>? importUnencryptedJson(String jsonString) {
  try {
    final parsed = jsonDecode(jsonString);
    if (parsed is! List) return null;
    for (final element in parsed) {
      if (element is! List) return null;
    }
    return parsed.cast<KHRecord>();
  } catch (_) {
    return null;
  }
}

/// Parses a KeyHolder CSV export.
///
/// CSV column order: name, username, password, date, time_tag
List<KHRecord> importUnencryptedCsv(String csvString) {
  final records = <KHRecord>[];
  for (final line in csvString.split('\n')) {
    if (line.trim().isEmpty) continue;
    final parts = line.split(',');
    if (parts.length < 5) continue;
    final timeTag = double.tryParse(parts[4]) ?? 0.0;
    records.add([parts[0], parts[1], parts[2], parts[3], timeTag]);
  }
  return records;
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 4 — Unencrypted export
// ─────────────────────────────────────────────────────────────────────────────

/// Serialises [records] to a KeyHolder JSON string ready for writing to a file.
String exportUnencryptedJson(List<KHRecord> records) {
  return jsonEncode(records);
}

/// Serialises [records] to a KeyHolder CSV string ready for writing to a file.
///
/// Column order: name, username, password, date, time_tag
String exportUnencryptedCsv(List<KHRecord> records) {
  final lines = <String>[];
  for (final record in records) {
    // record[4] is the numeric time_tag; the rest are strings
    lines.add('${record[0]},${record[1]},${record[2]},${record[3]},${record[4]}');
  }
  return lines.join('\n');
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 5 — Format conversions  (mirrors the converter functions)
// ─────────────────────────────────────────────────────────────────────────────

// ── Bitwarden ────────────────────────────────────────────────────────────────

/// Converts a KeyHolder record list to a Bitwarden-compatible JSON map.
Map<String, dynamic> keyholderToBitwarden(List<KHRecord> records) {
  final items = records.map((r) {
    return {
      'id': '',
      'organizationId': null,
      'folderId': null,
      'type': 1,
      'reprompt': 0,
      'name': r[0],
      'notes': null,
      'favorite': false,
      'login': {
        'username': r[1],
        'password': r[2],
        'totp': null,
      },
      'collectionIds': null,
    };
  }).toList();

  return {
    'encrypted': false,
    'folders': <dynamic>[],
    'items': items,
  };
}

/// Converts a Bitwarden JSON map to a KeyHolder record list.
///
/// Only login-type entries (type == 1) are imported, matching Python behaviour.
List<KHRecord> bitwardenToKeyholder(Map<String, dynamic> bitwarden) {
  final items = (bitwarden['items'] as List).cast<Map<String, dynamic>>();
  return [
    for (final item in items)
      if (item['type'] == 1)
        [
          item['name'] ?? '',
          item['login']?['username'] ?? '',
          item['login']?['password'] ?? '',
          '',
          0,
        ]
  ];
}

// ── Google Password Manager ───────────────────────────────────────────────────

/// Converts a Google Password Manager CSV string to a KeyHolder record list.
///
/// Google CSV columns: name, url, username, password, note
List<KHRecord> googleToKeyholder(String csvString) {
  // Skip the header line
  final firstNewline = csvString.indexOf('\n');
  if (firstNewline == -1) return [];
  final body = csvString.substring(firstNewline + 1);

  final records = <KHRecord>[];
  for (final line in body.split('\n')) {
    if (line.trim().isEmpty) continue;
    final parts = line.split(',');
    if (parts.length < 4) continue;
    records.add([parts[0], parts[2], parts[3], '', 0]);
  }
  return records;
}

/// Converts a KeyHolder record list to a Google Password Manager CSV string.
String keyholderToGoogle(List<KHRecord> records) {
  final lines = ['name,url,username,password,note'];
  for (final r in records) {
    lines.add('${r[0]},https://google.com/,${r[1]},${r[2]},');
  }
  return lines.join('\n');
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION 6 — Internal helpers
// ─────────────────────────────────────────────────────────────────────────────

String _bytesToHex(Uint8List bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

Uint8List _hexToBytes(String hex) {
  final result = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < result.length; i++) {
    result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}

bool _bytesEqual(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  // Constant-time comparison to avoid timing attacks
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}
