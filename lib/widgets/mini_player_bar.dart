import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/contollers.dart';
import '../models/song.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  Widget _buildLeading(Image? artwork) {
    return AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: artwork ?? const Icon(Icons.music_note),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    // only rebuilds when the playing song itself changes — position/duration
    // ticks and unrelated playlist mutations are ignored entirely.
    final playingId = context.select<PlaybackController, String?>((p) => p.playingId);

    if (playingId == null) {
      return const SizedBox.shrink();
    }

    final song = context.select<PlaylistsController, Song>((p) => p.getSong(playingId));
    final isPaused = context.select<PlaybackController, bool>((p) => p.isPaused);
    final playback = context.read<PlaybackController>();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: () => context.push("/player"),
        leading: FutureBuilder(
          future: song.artwork(),
          builder: (context, snapshot) => _buildLeading(snapshot.data),
        ),
        title: Text(song.title),
        subtitle: Text(song.artist),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: isPaused ? playback.unpause : playback.pause,
            ),
          ],
        ),
      ),
    );
  }
}