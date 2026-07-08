import 'dart:io';
import 'dart:convert';
import 'package:moai_music/models/models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:audiotags/audiotags.dart';

import 'constants.dart';


enum SongAddMode {keepPath, moveFile, copyFile}


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

bool hasAudioExtension(String path) {
  final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
  const audioExts = {'mp3', 'wav', 'flac', 'aac', 'm4a', 'ogg', 'opus', 'wma', 'aiff', 'alac'};
  return audioExts.contains(ext);
}

Future<bool> fileExists(String path) async {
  final file = File(path);
  return await file.exists();
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


Future<Song> songFromReadyPath(String filePath) async {
  final tag = await AudioTags.read(filePath);
  if(tag == null) return Song(title: "Untitled", artist: "Unknown", address: "", songType: SongType.nonexistent);
  return Song(title: tag.title ?? "Untitled", 
              artist: tag.trackArtist ?? ( tag.albumArtist ?? "Unknown"), 
              address: filePath, 
              songType: .local, 
              album: tag.album ?? "single", 
              genre: tag.genre ?? "none");  
}

Future<File> copyFile(String sourcePath, String destDir) async {
  final sourceFile = File(sourcePath);
  final fileName = sourceFile.uri.pathSegments.last; // or use p.basename(sourcePath)
  final destPath = '$destDir/$fileName';
  return await sourceFile.copy(destPath); // returns the new File
}

Future<String> moveToDirectory(String sourcePath, String destDir) async {
  final fileName = p.basename(sourcePath);
  final destPath = p.join(destDir, fileName);

  final sourceFile = File(sourcePath);
  try {
    final movedFile = await sourceFile.rename(destPath);
    return movedFile.path;
  } on FileSystemException {
    // fallback for cross-volume moves
    final copied = await sourceFile.copy(destPath);
    await sourceFile.delete();
    return copied.path;
  }
}

Future<List<String>> allAudioFilesIn(String dirPath) async {
  final Directory dir = Directory(dirPath);
  if(!await dir.exists()) return List.empty();
  return (await dir.list().toList())
          .whereType<File>()
          .where((f) => hasAudioExtension(f.path))
          .map((f) => f.path)
          .toList();
}

Future<Song> songFromFile(String filePath, SongAddMode mode) async {
  String destDir = (await getApplicationSupportDirectory()).path;
  String path = mode == .copyFile 
                ? (await copyFile(filePath, destDir)).path
                : (mode == .moveFile 
                   ? await moveToDirectory(filePath, destDir)
                   : filePath
                   );
  return songFromReadyPath(path);
}

// Future<List<Song>> songsFromDir(String dirPath, SongAddMode mode) async {
//   return (await allAudioFilesIn(dirPath)).map((path) async => await songFromFile(path, mode)).toList();
// }

Future<List<Song>> songsFromDir(String dirPath, SongAddMode mode) async {
  final paths = await allAudioFilesIn(dirPath);
  final futures = paths.map((path) => songFromFile(path, mode));
  return Future.wait(futures);
}