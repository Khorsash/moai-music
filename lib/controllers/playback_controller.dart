import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../models/models.dart';

class PlaybackController extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final List<String> _playlistQueue = [];
  final List<String> _userQueue = [];
  final List<String> _historyQueue = [];
  final Song Function(String songId) _getSong;
  final List<String> Function(String playlistId) _getPlaylist;
  final bool Function(String playlistId) _consumeChanged;
  final bool Function(String songId) _songExists;


  String? _playingId;
  bool _isPaused = false;
  String? _playingPlaylistId;
  LoopMode _loopState = LoopMode.off;
  bool _shuffled = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isCurrentFromUserQueue = false;
  bool _isChangingSong = false;

  String? get playingId => _playingId;
  bool get isPaused => _isPaused;
  String? get playingPlaylistId => _playingPlaylistId;
  LoopMode get loopState => _loopState;
  bool get shuffled => _shuffled;
  Duration get position => _position;
  Duration get duration => _duration;
  bool isQueueEmpty() => _userQueue.isEmpty && _playlistQueue.isEmpty && _playingId == null;
  List<String> get userQueue => _userQueue;
  List<String> get playlistQueue => _playlistQueue;

  PlaybackController({
    required this._getSong,
    required this._getPlaylist,
    required this._consumeChanged,
    required this._songExists
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

  void addToQueue(String songId) {
    if(_songExists(songId)) {
      _userQueue.add(songId);
    }
    notifyListeners();
  }

  void deleteFromQueue(int i) {
    if(i>=_userQueue.length) {
      _playlistQueue.removeAt(i-_userQueue.length);
    } else {
      _userQueue.removeAt(i);
    }
    notifyListeners();
  }

  Future<void> skipToQueueSong(int i) async {
    String songId;
    if(i>=_userQueue.length) {
      for(int j=0; j<i-_userQueue.length; j++) {
        _historyQueue.add(_playlistQueue.removeAt(0));
      }
      songId = _playlistQueue.removeAt(0);
    } else {
      songId = _userQueue.removeAt(i);
    }
    _isCurrentFromUserQueue = _userQueue.isNotEmpty;
    await play(_playingPlaylistId!, songId, redirectNext: true, queueGoing: true);
  }

  void moveSongInQueue(int ip, int np) {
    if(ip == np) return;
    String songId = ip >= _userQueue.length 
                    ? _playlistQueue.removeAt(ip-_userQueue.length)
                    : _userQueue.removeAt(ip);
    if(np >= _userQueue.length+1 || _userQueue.isEmpty) {_playlistQueue.insert(np-_userQueue.length, songId);}
    else {_userQueue.insert(np, songId);}
    notifyListeners();
  }

  Future<void> play(String playlistId, String songId, {bool redirectNext=true, bool queueGoing=false}) async {
    if(playlistId != _playingPlaylistId || !queueGoing) {
      _historyQueue.clear();
      _rebuildQueue(playlistId, startAfter: songId);
    }
    if (_playingId == songId && _isPaused) {
      _isPaused = false;
    } else {
      _playingId = songId;
      _playingPlaylistId = playlistId;
      _isPaused = false;
      final Song song = _getSong(_playingId!);
      try {
        if(await song.isAvailable()) {
          final MediaItem tag = MediaItem(id: songId, title: song.title, artist: song.artist);
          await _player.setAudioSource(
            song.songType == .local 
            ? AudioSource.file(song.address, tag: tag)
            : AudioSource.uri(Uri.parse(song.address), tag: tag)
          );
        } else {
          _skipBad(redirectNext);
          return;
        }
      } catch(e) {
        _skipBad(redirectNext);
        return;
      }
    }
    _isPaused = false;
    _player.play(); 
    notifyListeners(); 
  }


  void onPlaylistUpdated() {
    if (_playingPlaylistId == null) return;
    if (!_consumeChanged(_playingPlaylistId!)) return;

    _rebuildQueue(_playingPlaylistId!);
    notifyListeners();
  }

  void _rebuildQueue(String playlistId, {String? startAfter}) {
    final List<String> songs = [..._getPlaylist(playlistId)];
    if (shuffled) songs.shuffle();

    if (startAfter != null) {
      final idx = songs.indexOf(startAfter);

      if (idx != -1 && !shuffled) {
        songs.removeRange(0, idx + 1); 
      }
      else {
        songs.removeAt(idx);
      }
    }

    _playlistQueue
      ..clear()
      ..addAll(songs);
  }

  void pause() {
    _isPaused = true;
    _player.pause();
    notifyListeners();
  }

  void unpause() {
    _isPaused = false;
    _player.play();
    notifyListeners();
  }

  void togglePause() {
    if(_isPaused) {unpause();}
    else {pause();}
  }

  Future<void> _skipBad(bool redirectNext) async {
    if (redirectNext) {
        await _next();
      } else {
        await _previous();
      }
  }

  Future<void> stop() async {
    _playingId = null;
    _playingPlaylistId = null;
    _isPaused = false;
    _historyQueue.clear();
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
    _player.setLoopMode(_loopState == LoopMode.one ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  void toggleShuffle() {
    _shuffled = !_shuffled;
    if(_playingId == null || _playingPlaylistId == null) return;
    _historyQueue.clear();
    if (_shuffled) {
        _playlistQueue.shuffle();
    } else {
      _rebuildQueue(_playingPlaylistId!, startAfter: playingId);
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (_isChangingSong) return;
    _isChangingSong = true;
    try {
      await _next();
    } finally {
      _isChangingSong = false;
    }
  }

  Future<void> previous() async {
    if (_isChangingSong) return;
    _isChangingSong = true;
    try {
      await _previous();
    } finally {
      _isChangingSong = false;
    }
  }

  Future<void> _next() async {
    if(playingPlaylistId == null) return;
    if(_playlistQueue.isEmpty && _userQueue.isEmpty && _loopState == .off ) {
      await stop();
      notifyListeners();
      return;
    }
    if(_playlistQueue.isEmpty && _userQueue.isEmpty) {
      _rebuildQueue(_playingPlaylistId!);
    }
    if(!_isCurrentFromUserQueue) _historyQueue.add(_playingId!);
    _isCurrentFromUserQueue = _userQueue.isNotEmpty;
    await play(playingPlaylistId!, _userQueue.isNotEmpty ? _userQueue.removeAt(0) : _playlistQueue.removeAt(0), redirectNext: true, queueGoing: true);
  }


  Future<void> _previous() async {
    if(playingPlaylistId == null || _playingId == null) return;
    if(_historyQueue.isEmpty) {
      await setSongProgress(Duration.zero);
    } else {
      _playlistQueue.insert(0, _playingId!);
      await play(_playingPlaylistId!, _historyQueue.removeLast(), redirectNext: _historyQueue.isEmpty, queueGoing: true);
    }
  }

  Future<void> setSongProgress(Duration target) async {
    await _player.seek(target);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}