import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moai_music/constants.dart';
import 'package:provider/provider.dart';

import '../controllers/contollers.dart';
import '../widgets/add_to_playlist_item.dart';


class AddToPlaylistList extends StatefulWidget {
  final String songId;
  const AddToPlaylistList({super.key, required this.songId});

  @override
  AddToPlaylistListState createState() => AddToPlaylistListState();
}

class AddToPlaylistListState extends State<AddToPlaylistList> {

  // final Map<String, Future<Image?>> _songDataCache = {};

  @override
  Widget build(BuildContext context) {
    final allPlaylistsIds = context.select<PlaylistsController, List<String>>(
      (p) => p.playlists.keys.toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Add to playlist"),
        leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back)),
        
      ),
      
      body: allPlaylistsIds.length <= 1
        ? Center(child: Text('No playlists created in app yet.'))
        : ListView.builder(
            itemCount: allPlaylistsIds.length,
            itemBuilder: (context, index) {
              final id = allPlaylistsIds[index];
              final playlist = context.read<PlaylistsController>().getPlaylist(id);

              return Builder(
                builder: (context) {
                  final isSelected = context.select<PlaylistsController, bool>(
                    (p) => p.playlistContains(id, widget.songId),
                  );
                  final playlists = context.read<PlaylistsController>();

                  return AddToPlaylistItem(
                    playlistName: playlist.name,
                    isSelected: isSelected,
                    onTap: id == allSongsPlaylistName
                        ? () {}
                        : () {
                            if (isSelected) {
                              playlists.removeSong(id, widget.songId);
                            } else {
                              playlists.addToPlaylist(id, widget.songId);
                            }
                          },
                  );
                },
              );
            },
          ),
    ); 
  }
}
