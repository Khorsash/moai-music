import 'package:flutter/material.dart';

import '../file_manip.dart';
import '../url_manip.dart';

enum SongType { online, local, nonexistent }

class Song{
  final String title, artist, address;
  final SongType songType;
  const Song({required this.title, required this.artist, required this.address, required this.songType});
  Future<bool> isAvailable() async {
    return (songType==SongType.local 
            ? fileExists(address) 
            : await checkAudioUrl(address)==UrlAudioCheckResult.ok)
           && songType!=SongType.nonexistent;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    'address': address,
    'songType': songType.name, // enum -> string
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    title: json['title'] as String,
    artist: json['artist'] as String,
    address: json['address'] as String? ?? '',
    songType: SongType.values.byName(json['songType'] as String? ?? 'local'),
  );

  Image? artwork() {
    
    return null;
  }
} 