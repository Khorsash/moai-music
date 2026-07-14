import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/contollers.dart';
import '../models/song.dart';
import '../widgets/song_add_item.dart';


class SongAddList extends StatefulWidget {
  final String playlistId;
  const SongAddList({super.key, required this.playlistId});

  @override
  SongAddListState createState() => SongAddListState();
}

class SongAddListState extends State<SongAddList> {

  final Map<String, Future<Image?>> _songDataCache = {};

  Future<Image?> _songDataFor(String id, Song song) {
    return _songDataCache.putIfAbsent(id, 
                                      () async => await song.artwork(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSongsIds = context.select<PlaylistsController, List<String>>(
      (p) => p.allSongsAdded.keys.toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Add songs"),
        leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.arrow_back)),
        
      ),
      
      body: allSongsIds.isEmpty
        ? Center(child: Text('No songs added to app yet.'))
        : ListView.builder(
            itemCount: allSongsIds.length,
            itemBuilder: (context, index) {
              final id = allSongsIds[index];
              // read is fine here — not building UI off it directly,
              // just fetching the Song object to pass along
              final song = context.read<PlaylistsController>().getSong(id);

              return FutureBuilder(
                future: _songDataFor(id, song),
                builder: (context, snapshot) {
                  // scoped per-row: only THIS row rebuilds when its own
                  // membership in this playlist changes
                  final isSelected = context.select<PlaylistsController, bool>(
                    (p) => p.playlistContains(widget.playlistId, id),
                  );
                  final playlists = context.read<PlaylistsController>();

                  return SongAddItem(
                    title: song.title,
                    subtitle: song.artist,
                    isSelected: isSelected,
                    artwork: snapshot.data,
                    onTap: () {
                      if (isSelected) {
                        playlists.removeSong(widget.playlistId, id);
                      } else {
                        playlists.addToPlaylist(widget.playlistId, id);
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