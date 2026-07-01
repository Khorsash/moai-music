import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../controllers/contollers.dart';
import '../models/models.dart';
import '../widgets/playlist_item.dart';

class PlaylistList extends StatefulWidget {
  const PlaylistList({super.key});
  @override
  PlaylistListState createState() => PlaylistListState();
}

class PlaylistListState extends State<PlaylistList> {
  int _counter = 1; 
  void _addPlaylist() {
    context.read<PlaylistsController>().addPlaylist('playlist$_counter');
    _counter++;
  }
  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistsController>();
    return Scaffold(
      appBar: AppBar(title: Text("Library"),),
      body: ListView.builder(
              itemCount: playlists.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists.playlists[index];
                return PlaylistItem(playlistName: playlist.name, onCLick: () => context.go('/library/${playlist.id}'),);
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlaylist,
        child: Icon(Icons.add),
      ),
      );
  }
}