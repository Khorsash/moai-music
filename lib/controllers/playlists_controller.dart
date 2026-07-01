import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../constants.dart';



class PlaylistsController extends ChangeNotifier {
  final List<Playlist> _playlists = [
    Playlist(id: allSongsPlaylistName, name: 'All Downloaded', songs: []),
  ];

  final _uuid = Uuid();

  List<Playlist> get playlists => _playlists;

  Playlist getPlaylist(String id) =>
      _playlists.firstWhere((p) => p.id == id);

  Song getSongFrom(String playlistId, String songId) =>
      getPlaylist(playlistId).songs.firstWhere((p) => p.id == songId);

  String addPlaylist(String name) {
    String playlistId = _uuid.v4();
    _playlists.add(Playlist(id: playlistId, name: name, songs: []));
    notifyListeners();
    return playlistId;
  }

  void addSong(String playlistId, Song song) {
    getPlaylist(playlistId).songs.add(song);
    notifyListeners();
  }

  void removeSong(String playlistId, String songId) {
    getPlaylist(playlistId).songs.removeWhere((s) => s.id == songId);
    notifyListeners();
  }

  void removeSongs(String playlistId, Iterable<String> selectedIds) {
    getPlaylist(playlistId).songs.removeWhere((s) => selectedIds.contains(s.id));
    notifyListeners();
  }

  
}