import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/models.dart';

class PlaybackController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final Song Function(String songId) _getSong;
  final Playlist Function(String playlistId) _getPlaylist;

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

  PlaybackController({
    required this._getSong,
    required this._getPlaylist,
  }) {
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
  Future<void> play(String playlistId, String songId) async {
    if (_playingId == songId && _isPaused) {
      _isPaused = false;
    } else {
      _playingId = songId;
      _playingPlaylistId = playlistId;
      _isPaused = false;
      final Song song = _getSong(_playingId!);
      final MediaItem tag = MediaItem(id: songId, title: song.title, artist: song.artist);
      if(await song.isAvailable()) {
        await _player.setAudioSource(
          song.songType == .local 
          ? AudioSource.file(song.address, tag: tag)
          : AudioSource.uri(Uri.parse(song.address), tag: tag)
        );
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