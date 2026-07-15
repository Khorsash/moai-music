import 'package:flutter/material.dart';
import 'package:moai_music/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:moai_music/models/models.dart';
import 'package:moai_music/file_manip.dart';



class PlaylistsController extends ChangeNotifier {
  Map<String, Song> _allSongsAdded = {};
  Map<String, Playlist> _playlists = {};
  final _uuid = Uuid();
  final Set<String> _changedPlaylistIds = {};

  Map<String, Playlist> get playlists => _playlists;
  Map<String, Song> get allSongsAdded => _allSongsAdded;

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

  bool songExists(String songId) => _allSongsAdded.containsKey(songId);

  bool playlistExists(String playlistId) => _playlists.containsKey(playlistId);

  bool playlistContains(String playlistId, String songId) {
    if(!playlistExists(playlistId) || !songExists(songId)) return false;
    return _playlists[playlistId]!.contains(songId);
  }

  List<String> getPlaylistAsIdlist(String id) {
    return getPlaylist(id).songs;
  }
      // getPlaylist(playlistId).songs.firstWhere((p) => p.id == songId);

  void _markChanged(String playlistId) {
    _changedPlaylistIds.add(playlistId);
  }

  bool consumeChanged(String playlistId) {
    return _changedPlaylistIds.remove(playlistId);
  }

  String addPlaylist(String name) {
    String playlistId = _uuid.v4();
    _playlists[playlistId] = Playlist(name: name, songs: []);
    savePlaylists(playlists);
    notifyListeners();
    return playlistId;
  }


  void addSong(Song song) {
    if(song.songType == .nonexistent) return;
    final songId = _uuid.v4();
    _allSongsAdded[songId] = song;
    saveAllSaved(_allSongsAdded);
    addToPlaylist(allSongsPlaylistName, songId);
  }
  
  void addSongs(List<Song> songs) {
    final validSongs = songs.where((s) => s.songType != SongType.nonexistent);
    if (validSongs.isEmpty) return;

    for (final song in validSongs) {
      final songId = _uuid.v4();
      _allSongsAdded[songId] = song;
      _playlists[allSongsPlaylistName]!.songs.add(songId);
    }

    saveAllSaved(_allSongsAdded);
    savePlaylists(_playlists);
    _markChanged(allSongsPlaylistName);
    notifyListeners();
  }


  bool addToPlaylist(String playlistId, String songId) {
    if(!_playlists.containsKey(playlistId)) return false;
    if(_playlists[playlistId]!.songs.contains(songId)) return false;
    _playlists[playlistId]!.songs.add(songId);
    savePlaylists(_playlists);
    _markChanged(playlistId);
    notifyListeners();
    return true;
  }

  void removeSong(String playlistId, String songId) {
    if(!_playlists.containsKey(playlistId)) return;
    _playlists[playlistId]!.songs.removeWhere((s) => s == songId);
    if(playlistId != allSongsPlaylistName) { 
      savePlaylists(_playlists); 
    } else {
      _allSongsAdded.remove(songId);
      for(String pId in _playlists.keys.where((p) => p != allSongsPlaylistName)) {
        removeSong(pId, songId);
      }
      saveAllSaved(_allSongsAdded);
    }
    _markChanged(playlistId);
    notifyListeners();
  }

  void removeSongs(String playlistId, Iterable<String> selectedIds) {
    if(!_playlists.containsKey(playlistId)) return;
    _playlists[playlistId]!.songs.removeWhere((s) => selectedIds.contains(s));
    if(playlistId != allSongsPlaylistName) {
      savePlaylists(_playlists);
    } else {
      _allSongsAdded.removeWhere((id, song) => selectedIds.contains(id));
      for(String pId in _playlists.keys.where((p) => p != allSongsPlaylistName)) {
        removeSongs(pId, selectedIds);
      }
      saveAllSaved(_allSongsAdded);
    }
    _markChanged(playlistId);
    notifyListeners();
  }

  void removePlaylist(String playlistId) {
    if(!playlistExists(playlistId) || playlistId == allSongsPlaylistName) return;
    _playlists.remove(playlistId);
    savePlaylists(_playlists);
    notifyListeners();
  }
}