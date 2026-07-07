import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/contollers.dart';
import '../models/song.dart';


class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackController>();
    final playlists = context.watch<PlaylistsController>();

    if (playback.playingId == null) {
      return SizedBox.shrink();
    }

    Song song = playlists.getSong(playback.playingId!);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: () => context.push("/player"),
        leading: Icon(Icons.music_note),
        title: Text(song.title),       
        subtitle: Text(song.artist),   
        trailing: Row(
          mainAxisSize: MainAxisSize.min,  // ← add this
          children: [
            IconButton(
              icon: Icon(playback.isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: () {
                if (playback.playingId == null) return;
                if (playback.isPaused) {
                  playback.unpause();
                } else {
                  playback.pause();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}