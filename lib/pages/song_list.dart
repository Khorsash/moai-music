import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moai_music/constants.dart';
import 'package:moai_music/file_manip.dart';
import 'package:provider/provider.dart';

import '../controllers/contollers.dart';
import '../models/song.dart';
import '../widgets/song_item.dart';


class SongList extends StatefulWidget {
  final String playlistId;
  const SongList({super.key, required this.playlistId});

  @override
  SongListState createState() => SongListState();
}

class SongListState extends State<SongList> {

  bool _selectionMode = false;
  Set<String> _selectedIds = {};
  final Map<String, Future<bool>> _availabilityCache = {};

  Future<bool> _availabilityFor(String id, Song song) {
    return _availabilityCache.putIfAbsent(id, () => song.isAvailable());
  }

  Future<(bool, Image?)> _songDataFor(String id, Song song) async {
    final available = await _availabilityFor(id, song);
    final artwork = await song.artwork();
    return (available, artwork);
  }

  Future<void> _addSongs(bool isAllSongsList) async {
    if(!isAllSongsList) {
      context.push("/library/${widget.playlistId}/addSongs");
      return;
    }

    final playlists = context.read<PlaylistsController>();
    final paths = await pickFiles();
    if(paths.isEmpty) return;
    if(!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false, // user can't tap outside to dismiss mid-import
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Importing songs...'),
          ],
        ),
      ),
    );
    await Future.delayed(Duration.zero);
    try {
      final mode = Platform.isAndroid ? SongAddMode.copyFile : SongAddMode.keepPath;
      final songs = await songsFromFiles(paths, mode);
      playlists.addSongs(songs);
    } finally {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void _addSongToPlaylists(String songId) {
    context.push("/addToPlaylist/$songId");
  }

  void _deleteItem(String id) {
    final playlists = context.read<PlaylistsController>();
    final playback = context.read<PlaybackController>();
    if (playback.playingId == id) playback.stop();
    playlists.removeSong(widget.playlistId, id);
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds = {id};
    });
  }

  void _enterSelectionModeWFS() {
    setState(() {
      _selectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _onSelectToggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  void _deleteSelected() {
    final playlists = context.read<PlaylistsController>();
    final playback = context.read<PlaybackController>();
    if (playback.playingId != null && _selectedIds.contains(playback.playingId)) {
      playback.stop();
    }
    playlists.removeSongs(widget.playlistId, _selectedIds);
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _enqueueItem(String songId) {
    final playback = context.read<PlaybackController>();
    playback.addToQueue(songId);
  }

  SongState _getState(String id, PlaybackController playback) {
    if (_selectionMode) return SongState.selectionMode;
    if (playback.playingId == id && playback.playingPlaylistId == widget.playlistId) {
      return playback.isPaused ? SongState.paused : SongState.playing;
    }
    return SongState.defaultState;
  }

  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistsController>();
    final playback = context.watch<PlaybackController>();
    final playlist = playlists.getPlaylist(widget.playlistId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectionMode
            ? '${_selectedIds.length} selected'
            : playlist.name),
        leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back)),
        actions: _selectionMode
          ? [
              IconButton(icon: Icon(Icons.close), onPressed: _exitSelectionMode),
              IconButton(icon: Icon(Icons.delete), onPressed: _deleteSelected),
            ]
          : [
              IconButton(icon: Icon(Icons.circle_outlined), onPressed: _enterSelectionModeWFS),
            ],
        
      ),

      body: playlist.songs.isEmpty
          ? Center(child: Text('No songs yet. Tap + to add one!'))
          : ListView.builder(
              itemCount: playlist.songs.length,
              itemBuilder: (context, index) {
                final id = playlist.songs[index];
                final song = playlists.getSong(id);
                return Dismissible(
                  key: ValueKey(id),
                  direction: _selectionMode
                      ? DismissDirection.none
                      : DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      _deleteItem(id);
                      return true;
                    } else {
                      _enqueueItem(id);
                      return false;
                    }
                  },
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.queue_music_rounded, color: Colors.white),
                  ),
                  child: FutureBuilder<(bool, Image?)>(
                    future: _songDataFor(id, song),
                    builder: (context, snapshot) {
                      final (isAvailable, artwork) = snapshot.data ?? (false, null);
                      return SongItem(
                        title: song.title,
                        subtitle: song.artist,
                        state: _getState(id, playback),
                        isSelected: _selectedIds.contains(id),
                        onPlayPause: () => playback.play(widget.playlistId, id),
                        onSelectToggle: () => _onSelectToggle(id),
                        onMenuAction: (action) {
                          switch (action) {
                            case 'queue':
                              _enqueueItem(id);
                              break;
                            case 'playlists':
                              _addSongToPlaylists(id);
                              break;
                            case 'select':
                              _enterSelectionMode(id);
                              break;
                            case 'delete':
                              _deleteItem(id);
                              break;
                          }
                        },
                        onLongPress: () {
                          if (!_selectionMode) _enterSelectionMode(id);
                        },
                        isPlayable: isAvailable,
                        artwork: artwork,
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async => await _addSongs(widget.playlistId == allSongsPlaylistName),
        child: Icon(Icons.add),
      ),
    );
  }
}