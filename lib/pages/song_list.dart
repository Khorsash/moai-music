import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/contollers.dart';
import '../models/models.dart';
import '../widgets/song_item.dart';


class SongList extends StatefulWidget {
  final String playlistId;
  const SongList({super.key, required this.playlistId});

  @override
  SongListState createState() => SongListState();
}

class SongListState extends State<SongList> {
  int _counter = 1;

  bool _selectionMode = false;
  Set<String> _selectedIds = {};

  void _addItem() {
    final playlists = context.read<PlaylistsController>();
    playlists.addSong(widget.playlistId, Song(
      id: 'song_$_counter',
      title: 'Item #$_counter',
      artist: 'This is item number $_counter',
    ));
    _counter++;
  }

  void _removeItem(String id) {
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

  SongState _getState(String id, PlaybackController playback) {
    if (_selectionMode) return SongState.selectionMode;
    if (playback.playingId == id) {
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
          ? Center(child: Text('No items yet. Tap + to add one!'))
          : ListView.builder(
              itemCount: playlist.songs.length,
              itemBuilder: (context, index) {
                final song = playlist.songs[index];
                final id = song.id;
                return Dismissible(
                  key: ValueKey(id),
                  direction: _selectionMode
                      ? DismissDirection.none
                      : DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      _removeItem(id);
                      return true;
                    } else {
                      print('queued!');
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
                  child: SongItem(
                    title: song.title,
                    subtitle: song.artist,
                    state: _getState(id, playback),
                    isSelected: _selectedIds.contains(id),
                    onPlayPause: () => playback.play(widget.playlistId, id),
                    onSelectToggle: () => _onSelectToggle(id),
                    onMoreTap: () { /* open settings */ },
                    onLongPress: () {
                      if (!_selectionMode) _enterSelectionMode(id);
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}