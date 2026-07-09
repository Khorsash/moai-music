import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import '../controllers/contollers.dart';
import '../widgets/album_cover_player.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  PlayerPageState createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {
  Duration? _dragPosition;
  bool _closing = false;
  

  @override
  Widget build(BuildContext context) {
    final playingId = context.select<PlaybackController, String?>((p) => p.playingId);

    if (playingId == null) {
      if (!_closing) {
        _closing = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
      }
      return const Center();
    }

    return Dismissible(
      key: const ValueKey("player"),
      direction: DismissDirection.down,
      onDismissed: (direction) => context.pop(),
      child: Material(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _PlayerAppBar(),
              const _SongInfo(),
              const SizedBox(height: 20),
              _ProgressSlider(
                dragPosition: _dragPosition,
                onDragChanged: (v) => setState(() => _dragPosition = v),
                onDragEnd: (v) {
                  setState(() => _dragPosition = null);
                  context.read<PlaybackController>().setSongProgress(v);
                },
              ),
              const SizedBox(height: 20),
              const _PlaybackControls(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rebuilds only when the current playlist changes.
class _PlayerAppBar extends StatelessWidget {
  const _PlayerAppBar();

  @override
  Widget build(BuildContext context) {
    final playlistId = context.select<PlaybackController, String?>((p) => p.playingPlaylistId);
    final playlists = context.watch<PlaylistsController>();
    final playlistName = playlistId != null ? playlists.getPlaylist(playlistId).name : '';

    return AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.keyboard_arrow_down),
      ),
      centerTitle: true,
      title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // const TextSpan(text: "Playing ", style: TextStyle(fontSize: 16)),
            // TextSpan(
            //   text: playlistName,
            //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            Text("Playing", style: TextStyle(fontSize: 16)),
            Text(playlistName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
          ],
        
      ),
    );
  }
}

/// Rebuilds only when the current track (song or playlist) changes.
class _SongInfo extends StatelessWidget {
  const _SongInfo();

  @override
  Widget build(BuildContext context) {
    final ids = context.select<PlaybackController, String?>(
      (p) => p.playingId,
    );
    final playlists = context.watch<PlaylistsController>();
    final song = playlists.getSong(ids!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FutureBuilder(
          future: song.artwork(), 
          builder: (context, snapshot) =>
            AlbumCoverPlayer(image: snapshot.data), 
        ),
        SizedBox(height: 10),
        Text(
          song.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          song.artist,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// The one widget expected to rebuild every second — isolated here so
/// nothing else on the page pays that cost.
class _ProgressSlider extends StatelessWidget {
  final Duration? dragPosition;
  final ValueChanged<Duration> onDragChanged;
  final ValueChanged<Duration> onDragEnd;

  const _ProgressSlider({
    required this.dragPosition,
    required this.onDragChanged,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final position = context.select<PlaybackController, Duration>((p) => p.position);
    final duration = context.select<PlaybackController, Duration>((p) => p.duration);

    final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
    final valueMs = (dragPosition ?? position).inMilliseconds.toDouble().clamp(0.0, maxMs);

    return Slider(
      value: valueMs,
      min: 0,
      max: maxMs,
      onChanged: (v) => onDragChanged(Duration(milliseconds: v.round())),
      onChangeEnd: (v) => onDragEnd(Duration(milliseconds: v.round())),
    );
  }
}

/// Rebuilds only when isPaused / shuffled / loopState change.
class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls();

  @override
  Widget build(BuildContext context) {
    final playback = context.read<PlaybackController>();
    final shuffled = context.select<PlaybackController, bool>((p) => p.shuffled);
    final isPaused = context.select<PlaybackController, bool>((p) => p.isPaused);
    final loopState = context.select<PlaybackController, LoopMode>((p) => p.loopState);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: playback.toggleShuffle,
          icon: Icon(shuffled ? Icons.shuffle_on_outlined : Icons.shuffle_outlined),
          style: ButtonStyle(
            iconColor: WidgetStatePropertyAll(shuffled ? Colors.blue : Colors.black),
            iconSize: const WidgetStatePropertyAll(25),
          ),
        ),
        IconButton(
          onPressed: playback.previous,
          icon: const Icon(Icons.skip_previous),
          style: const ButtonStyle(iconSize: WidgetStatePropertyAll(40)),
        ),
        IconButton(
          onPressed: () {
            if (isPaused) {
              playback.unpause();
            } else {
              playback.pause();
            }
          },
          icon: Icon(isPaused ? Icons.play_circle : Icons.pause_circle),
          style: const ButtonStyle(iconSize: WidgetStatePropertyAll(60)),
        ),
        IconButton(
          onPressed: playback.next,
          icon: const Icon(Icons.skip_next),
          style: const ButtonStyle(iconSize: WidgetStatePropertyAll(40)),
        ),
        IconButton(
          onPressed: playback.toggleRepeat,
          icon: Icon(
            loopState == LoopMode.off
                ? Icons.repeat_outlined
                : (loopState == LoopMode.all
                    ? Icons.repeat_on_outlined
                    : Icons.repeat_one_on_outlined),
          ),
          style: ButtonStyle(
            iconColor: WidgetStatePropertyAll(loopState == LoopMode.off ? Colors.black : Colors.blue),
            iconSize: const WidgetStatePropertyAll(25),
          ),
        ),
      ],
    );
  }
}