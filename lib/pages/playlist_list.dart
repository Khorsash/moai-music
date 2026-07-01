import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../controllers/contollers.dart';
import '../widgets/playlist_item.dart';

class PlaylistList extends StatefulWidget {
  const PlaylistList({super.key});
  @override
  PlaylistListState createState() => PlaylistListState();
}

class PlaylistListState extends State<PlaylistList> {
  void _addPlaylist() {
    context.push("/newPlaylist");
    
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
                // made push so user can go back to library with back button
                return PlaylistItem(playlistName: playlist.name, 
                                    onCLick: 
                                      () => context.push('/library/${playlist.id}'),);
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlaylist,
        child: Icon(Icons.add),
      ),
      );
  }
}