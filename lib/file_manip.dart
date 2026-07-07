import 'dart:io';
import 'dart:convert';
import 'package:moai_music/models/models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'constants.dart';

class AppPaths {
  static String downloadedSongsPath = "";
  static File songsFile = File("");
  static File playlistsFile = File("");
  


  static Future<void> init() async {
    var dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    final savePath = dir.path;

    dir = Directory(p.join(savePath, "downloaded_songs"));
    if(!(await dir.exists())) await dir.create(recursive: true, );
    downloadedSongsPath = dir.path;

    songsFile = File(p.join(savePath, "songs.json"));
    if(!(await songsFile.exists())) await songsFile.create(recursive: true);

    playlistsFile = File(p.join(savePath, "playlists.json"));
    if(!(await playlistsFile.exists())) await playlistsFile.create(recursive: true);

  }
}

Map<String, Playlist> defaultPlaylists() {
  return <String, Playlist>{allSongsPlaylistName: Playlist(name: 'All Downloaded', songs: [])};
}

bool fileExists(String path) {
  final file = File(path);
  return file.existsSync();
}

bool dirExists(String path) {
  final dir = Directory(path);
  return dir.existsSync();
}

Map<String, Song> loadAllSaved() {
  try {
    final decoded = jsonDecode(AppPaths.songsFile.readAsStringSync()) as Map<String, dynamic>;
    return decoded.map(
      (id, songJson) => MapEntry(id, Song.fromJson(songJson as Map<String, dynamic>)));
  } catch(e) {
    return <String, Song>{};
  }
}

void saveAllSaved(Map<String, Song> songs) {
  final jsonMap = songs.map((id, song) => MapEntry(id, song.toJson()));
  AppPaths.songsFile.writeAsString(jsonEncode(jsonMap));
}


Map<String, Playlist> loadPlaylists(Map<String, Song> songs) {
  try {
    final decoded = jsonDecode(AppPaths.playlistsFile.readAsStringSync()) as Map<String, dynamic>;
    Map<String, Playlist> playlists =  decoded.map(
      (id, songJson) => MapEntry(id, Playlist.fromJson(songJson as Map<String, dynamic>)));
    playlists.putIfAbsent(
      allSongsPlaylistName,
      () => Playlist(name: 'All Downloaded', songs: []),
    );
    playlists[allSongsPlaylistName]!.songs
      ..clear()
      ..addAll(songs.keys);
    return playlists;
  } catch(e) {
    return defaultPlaylists();
  }
}

void savePlaylists(Map<String, Playlist> playlists) {
  if(playlists.containsKey(allSongsPlaylistName)) playlists[allSongsPlaylistName]!.songs.clear();
  final jsonMap = playlists.map((id, playlist) => MapEntry(id, playlist.toJson()));
  AppPaths.playlistsFile.writeAsString(jsonEncode(jsonMap));
}



