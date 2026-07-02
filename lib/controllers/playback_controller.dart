// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart';


// class PlaybackController extends ChangeNotifier {
//   final _player = AudioPlayer();

//   String? _playingId;
//   bool _isPaused = false;
//   String? _playingPlaylistId;
//   LoopMode _loopState = LoopMode.off;
//   bool _shuffled = false;
//   Duration _position = Duration.zero;
//   Duration _duration = Duration.zero;

//   String? get playingId => _playingId;
//   bool get isPaused => _isPaused;
//   String? get playingPlaylistId => _playingPlaylistId;
//   LoopMode get loopState => _loopState;
//   bool get shuffled => _shuffled;
//   Duration get position => _position;
//   Duration get duration => _duration;

//   PlaybackController() {
//     _player.positionStream.listen((pos) {
//       _position = pos;
//       notifyListeners();
//     });

//     _player.durationStream.listen((dur) {
//       _duration = dur ?? Duration.zero;
//       notifyListeners();
//     });

//     _player.playerStateStream.listen((state) {
//       if (state.processingState == ProcessingState.completed) {
//         if (_loopState == LoopMode.one) {
//           _player.seek(Duration.zero);
//           _player.play();
//         } else {
//           next();
//         }
//       }
//     });
//   }

//   Future<void> play(String playlistId, String id, {String? filePath}) async {
//     if (_playingId == id && _isPaused) {
//       _isPaused = false;
//     } else {
//       _playingId = id;
//       _playingPlaylistId = playlistId;
//       _isPaused = false;
//       if (filePath != null) {
//         await _player.setFilePath(filePath); // fine to await — completes once loaded
//       }
//     }
//     _player.setAsset("assets/Sektor_Gaza_Life.mp3");
//     _player.play(); // fire-and-forget — don't await, it won't return until the song ends
//     notifyListeners();
//   }

//   void pause() {
//     _isPaused = true;
//     _player.pause(); // fine either way; not awaited here since nothing depends on it finishing
//     notifyListeners();
//   }

//   void unpause() {
//     _isPaused = false;
//     _player.play(); // same as above — don't await
//     notifyListeners();
//   }

//   Future<void> stop() async {
//     _playingId = null;
//     _playingPlaylistId = null;
//     _isPaused = false;
//     await _player.stop();
//     notifyListeners();
//   }

//   Future<void> setSongProgress(Duration target) async {
//     await _player.seek(target);
//   }


//   void toggleRepeat() {
//     switch(_loopState) {
//       case LoopMode.off:
//         _loopState = LoopMode.all;
//       case LoopMode.all:
//         _loopState = LoopMode.one;
//       case LoopMode.one:
//         _loopState = LoopMode.off;
//     }
//     notifyListeners();
//   }

//   void toggleShuffle() {
//     _shuffled = !_shuffled;
//     notifyListeners();
//   }

//   /// to be implemented
//   void next() {}
//   /// to be implemented
//   void previous() {}
//   /// to be implemented
//   double getSongProgress() {return 0.0;}
//   /// to be implemented
// }

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PlaybackController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  String? _playingId;
  bool _isPaused = false;
  String? _playingPlaylistId;
  LoopMode _loopState = LoopMode.off;
  bool _shuffled = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  String? get playingId => _playingId;
  bool get isPaused => _isPaused;
  String? get playingPlaylistId => _playingPlaylistId;
  LoopMode get loopState => _loopState;
  bool get shuffled => _shuffled;
  Duration get position => _position;
  Duration get duration => _duration;

  PlaybackController() {
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && _loopState != LoopMode.one) {
        next();
      }
    });

    _player.setLoopMode(_loopState);
  }

  Future<void> playTestAsset(String playlistId, String id) async {
    await _player.setAudioSource(
      AudioSource.asset(
        'assets/Sektor_Gaza_Life.mp3',
        tag: MediaItem(
          id: 'test',
          title: 'Sektor Gaza - Life',
          artist: 'Sektor Gaza',
        ),
      ),
    );
    _playingId = id;
    _playingPlaylistId = playlistId;
    _isPaused = false;
    _player.play();
    notifyListeners();
  }
  Future<void> play(String playlistId, String id, {String? filePath}) async {
    if (_playingId == id && _isPaused) {
      _isPaused = false;
    } else {
      _playingId = id;
      _playingPlaylistId = playlistId;
      _isPaused = false;
      if (filePath != null) {
        await _player.setFilePath(filePath);
      }
    }
    _isPaused = false;
    _player.play(); // fire-and-forget — this Future only resolves when playback stops
    notifyListeners();
  }

  void pause() {
    _isPaused = true;
    _player.pause();
    notifyListeners();
  }

  void unpause() {
    _isPaused = false;
    _player.play(); // fire-and-forget, same reason as above
    notifyListeners();
  }

  Future<void> stop() async {
    _playingId = null;
    _playingPlaylistId = null;
    _isPaused = false;
    await _player.stop();
    notifyListeners();
  }

  void toggleRepeat() {
    switch (_loopState) {
      case LoopMode.off:
        _loopState = LoopMode.all;
      case LoopMode.all:
        _loopState = LoopMode.one;
      case LoopMode.one:
        _loopState = LoopMode.off;
    }
    _player.setLoopMode(_loopState);
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

  Future<void> setSongProgress(Duration target) async {
    await _player.seek(target);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}