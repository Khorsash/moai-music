import 'package:flutter/material.dart';
import 'package:moai_music/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:moai_music/models/models.dart';
import 'package:moai_music/file_manip.dart';



class PlaylistsController extends ChangeNotifier {
  Map<String, Song> _allSongsAdded = {};
  Map<String, Playlist> _playlists = {};
  final _uuid = Uuid();

  Map<String, Playlist> get playlists => _playlists;

  PlaylistsController() {
    _allSongsAdded = loadAllSaved();
    _playlists = loadPlaylists(_allSongsAdded);
  }


  Playlist getPlaylist(String id) {
    return _playlists.containsKey(id) ? _playlists[id]! : Playlist(name: "THIS PLAYLIST DOESN'T EXIST", songs: List<String>.empty());
  }

  Song getSong(String songId) {
    return _allSongsAdded.containsKey(songId) 
            ? _allSongsAdded[songId]! 
            : Song(title: "Untitled", artist: "Unknown", address: "", songType: SongType.nonexistent);
  }
      // getPlaylist(playlistId).songs.firstWhere((p) => p.id == songId);

  String addPlaylist(String name) {
    String playlistId = _uuid.v4();
    _playlists[playlistId] = Playlist(name: name, songs: []);
    savePlaylists(playlists);
    notifyListeners();
    return playlistId;
  }

  void addSong(Song song) {
    final songId = _uuid.v4();
    _allSongsAdded[songId] = song;
    saveAllSaved(_allSongsAdded);
    addToPlaylist(allSongsPlaylistName, songId);
    notifyListeners();
  }

  bool addToPlaylist(String playlistId, String songId) {
    if(!_playlists.containsKey(playlistId)) return false;
    if(_playlists[playlistId]!.songs.contains(songId)) return false;
    _playlists[playlistId]!.songs.add(songId);
    if(playlistId != allSongsPlaylistName) savePlaylists(_playlists);
    notifyListeners();
    return true;
  }

  void removeSong(String playlistId, String songId) {
    if(!_playlists.containsKey(playlistId)) return;
    _playlists[playlistId]!.songs.removeWhere((s) => s == songId);
    savePlaylists(_playlists);
    notifyListeners();
  }

  void removeSongs(String playlistId, Iterable<String> selectedIds) {
    if(!_playlists.containsKey(playlistId)) return;
    _playlists[playlistId]!.songs.removeWhere((s) => selectedIds.contains(s));
    savePlaylists(_playlists);
    notifyListeners();
  }

  
}