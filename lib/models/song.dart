import 'package:flutter/material.dart';
import 'package:audiotags/audiotags.dart';

import '../file_manip.dart';
import '../url_manip.dart';

enum SongType { online, local, nonexistent }

class Song{
  final String title, artist, address, album, genre;
  final int year;
  final SongType songType;
  const Song({required this.title, required this.artist, required this.address, required this.songType, this.album="single", this.genre="none", this.year=1984});
  Future<bool> isAvailable() async {
    switch(songType) {
      case .nonexistent:
        return false;
      case .local:
        return fileExists(address);
      case .online:
        return await checkAudioUrl(address)==UrlAudioCheckResult.ok;
    }
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'artist': artist,
    'address': address,
    'songType': songType.name, // enum -> string
    'album': album,
    'genre': genre,
    'year': year
  };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    title: json['title'] as String,
    artist: json['artist'] as String,
    address: json['address'] as String? ?? '',
    songType: SongType.values.byName(json['songType'] as String? ?? 'local'),
    album: json['album'] as String? ?? 'single',
    genre: json['genre'] as String? ?? 'none',
    year: json['year'] as int? ?? 1984
  );

  static Future<Song> fromFile(String fileName) async => await songFromFile(fileName);

  Future<Image?> artwork() async {
    if(songType != .local) return null;
    final tag = await AudioTags.read(address);
    final pictures = tag?.pictures;
    if (pictures != null && pictures.isNotEmpty) {
      return Image.memory(pictures.first.bytes);
    }
    return null;
  }
} 