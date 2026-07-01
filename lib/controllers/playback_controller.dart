import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';


class PlaybackController extends ChangeNotifier {
  String? _playingId;
  bool _isPaused = false;
  String? _playingPlaylistId;
  LoopMode _loopState = LoopMode.off;
  bool _shuffled = false;

  String? get playingId => _playingId;
  bool get isPaused => _isPaused;
  String? get playingPlaylistId => _playingPlaylistId;
  LoopMode get loopState => _loopState;
  bool get shuffled => _shuffled;


  void play(String playlistId, String id) {
    if (_playingId == id && _isPaused) {
      _isPaused = false;
    } else {
      _playingId = id;
      _playingPlaylistId = playlistId;
      _isPaused = false;
    } // tells every listening widget to rebuild
    notifyListeners();
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
  void toggleRepeat() {
    switch(_loopState) {
      case LoopMode.off:
        _loopState = LoopMode.all;
      case LoopMode.all:
        _loopState = LoopMode.one;
      case LoopMode.one:
        _loopState = LoopMode.off;
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffled = !_shuffled;
    notifyListeners();
  }

  /// to be implemented
  void next() {}
  /// to be implemented
  void previous() {}
  /// to be implemented
  double getSongProgress() {return 0.0;}
  /// to be implemented
  void setSongProgress() {}
}