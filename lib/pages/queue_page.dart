import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moai_music/widgets/widgets.dart';
import 'package:provider/provider.dart';

import '../controllers/contollers.dart';
import '../models/models.dart';


class QueuePage extends StatefulWidget {
  const QueuePage({super.key});
  

  @override
  State<StatefulWidget> createState() => QueuePageState();
}

class QueuePageState extends State<QueuePage> {
  bool _closing = false;
  bool _dismissed = false;

  final Map<String, Future<bool>> _availabilityCache = {};

  Future<bool> _availabilityFor(String id, Song song) {
    return _availabilityCache.putIfAbsent(id, () => song.isAvailable());
  }

  Future<(bool, Image?)> _songDataFor(String id, Song song) async {
    final available = await _availabilityFor(id, song);
    final artwork = await song.artwork();
    return (available, artwork);
  }


  void _addSongToPlaylists(String songId) {
    context.push("/addToPlaylist/$songId");
  }

  SongState _getState(String id, PlaybackController playback) {
    if (playback.playingId == id) {
      return playback.isPaused ? SongState.paused : SongState.playing;
    }
    return SongState.defaultState;
  }
  
  @override
  Widget build(BuildContext context) {
    final isQueueEmpty = context.select<PlaybackController, bool>((p) => p.isQueueEmpty());

    if(isQueueEmpty || _dismissed) {
      if (!_closing) {
        _closing = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.pop();
        });
      }
      return const Center();
    }
    final playback = context.watch<PlaybackController>();
    final userQueue = playback.userQueue; //context.select<PlaybackController, List<String>>((p) => p.userQueue);
    final playlistQueue = playback.playlistQueue; //context.select<PlaybackController, List<String>>((p) => p.playlistQueue);

    final List<String> combined = [];
    combined.addAll(userQueue);
    combined.addAll(playlistQueue);

    
    return Dismissible(
      key: const ValueKey("queue"),
      direction: DismissDirection.down,
      onDismissed: (direction) { 
        _dismissed = true;
        context.pop(); 
      },
      child: Material(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Column(
            children: [
              AppBar(
                title: Text("Queue"),
                leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.keyboard_arrow_down)),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  // itemBuilder:(context, index) {
                  //   bool isUserAdd = index < userQueue.length;
                  //   String id = combined[index];
                  //   Song song = context.select<PlaylistsController, Song>((p) => p.getSong(id));

                  //   return FutureBuilder<(bool, Image?)>(
                  //         future: _songDataFor(id, song),
                  //         builder: (context, snapshot) {
                  //           final (isAvailable, artwork) = snapshot.data ?? (false, null);
                  //           return SongItem(
                  //             title: song.title, 
                  //             subtitle: song.artist, 
                  //             state: _getState(id, playback), 
                  //             isSelected: false, 
                  //             onPlayPause: () => playback.skipToQueueSong(index), 
                  //             onSelectToggle: () {}, 
                  //             onMenuAction: (action) {
                  //               switch (action) {
                  //                 case 'queue':
                  //                   playback.addToQueue(id);
                  //                   break;
                  //                 case 'playlists':
                  //                   _addSongToPlaylists(id);
                  //                   break;
                  //                 case 'delete':
                  //                   playback.deleteFromQueue(index);
                  //                   break;
                  //               }
                  //             },
                  //             onLongPress: () {}, 
                  //             isPlayable: isAvailable, 
                  //             artwork: artwork,
                  //             isUserAdd: isUserAdd,
                  //           );
                  //         }
                  //   );
                  // },
                  itemBuilder:(context, index) {
                    bool isUserAdd = index < userQueue.length;
                    String id = combined[index];

                    return Builder(
                      key: ValueKey(id+index.toString()),
                      builder: (context) {
                        Song song = context.select<PlaylistsController, Song>((p) => p.getSong(id));

                        return FutureBuilder<(bool, Image?)>(
                          future: _songDataFor(id, song),
                          builder: (context, snapshot) {
                            final (isAvailable, artwork) = snapshot.data ?? (false, null);
                            return SongItem(
                              title: song.title,
                              subtitle: song.artist,
                              state: _getState(id, playback),
                              isSelected: false,
                              onPlayPause: () => playback.skipToQueueSong(index),
                              onSelectToggle: () {},
                              onMenuAction: (action) {
                                switch (action) {
                                  case 'queue':
                                    playback.addToQueue(id);
                                    break;
                                  case 'playlists':
                                    _addSongToPlaylists(id);
                                    break;
                                  case 'delete':
                                    playback.deleteFromQueue(index);
                                    break;
                                }
                              },
                              onLongPress: () {},
                              isPlayable: isAvailable,
                              artwork: artwork,
                              isUserAdd: isUserAdd,
                            );
                          },
                        );
                      },
                    );
                  },
                  itemCount: combined.length,
                  onReorderItem: (oldIndex, newIndex) => playback.moveSongInQueue(oldIndex, newIndex),
                )
              ),
            ]
          )
        ),
      ),
    );
  }
}