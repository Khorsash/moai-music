import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class PlaybackController extends ChangeNotifier {
  String? _playingId;
  bool _isPaused = false;
  String? _playingPlaylistId;

  String? get playingId => _playingId;
  bool get isPaused => _isPaused;
  String? get playingPlaylistId => _playingPlaylistId;

  void play(String playlistId, String id) {
    if (_playingId == id && _isPaused) {
      _isPaused = false;
    } else {
      _playingId = id;
      _playingPlaylistId = playlistId;
      _isPaused = false;
      notifyListeners();
    } // tells every listening widget to rebuild
  }

  void pause() {
    _isPaused = true;
    notifyListeners();
  }

  void unpause() {
    _isPaused = false;
    notifyListeners();
  }

  void stop() {
    _playingId = null;
    _playingPlaylistId = null;
    _isPaused = false;
    notifyListeners();
  }
}