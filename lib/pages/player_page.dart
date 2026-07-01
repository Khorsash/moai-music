import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';

import '../models/models.dart';
import '../controllers/contollers.dart';
import '../widgets/album_cover_player.dart';


class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  PlayerPageState createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {


  @override
  Widget build(BuildContext context) {

    final playback = context.watch<PlaybackController>();
    if(playback.playingId == null) return Text("nothing to show");
    final playlists = context.watch<PlaylistsController>();

    Playlist playlist = playlists.getPlaylist(playback.playingPlaylistId!);
    Song song = playlists.getSongFrom(playback.playingPlaylistId!, playback.playingId!);
    double? progress;

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
              AppBar(
                leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.keyboard_arrow_down)),
                centerTitle: true,
                //Text("Playing ${playlist.name}", style: TextStyle(fontSize: 16),),
                title: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Playing ",
                              style: const TextStyle(fontSize: 16),
                            ),
                            TextSpan(
                              text: playlist.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
              ),
              // FIXME: Set actual album cover or null if there's no one
              AlbumCoverPlayer(image: null),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
              ),
              const SizedBox(height: 20),

              //FIXME: to be replaced with actual song progress
              Slider(
                value: progress ?? playback.getSongProgress(),
                min: 0,
                max: 1.0,
                onChanged: (value) => setState(() => progress = value),
                onChangeEnd: (value) {
                  setState(() => progress = null);
                },
              ),
              
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: () => playback.toggleShuffle(), 
                            icon: Icon(playback.shuffled 
                                        ? Icons.shuffle_outlined 
                                        : Icons.shuffle_on_outlined),
                            style: ButtonStyle(
                              iconColor: WidgetStatePropertyAll(playback.shuffled  
                                ? Colors.black 
                                : Colors.blue),
                              iconSize: WidgetStatePropertyAll(25),
                            ),
                  ),
                  IconButton(onPressed: () => playback.previous(), 
                            icon: Icon(Icons.skip_previous),
                            style: ButtonStyle(
                              iconSize: WidgetStatePropertyAll(40),
                            ),
                  ),
                  IconButton(onPressed: () => {playback.isPaused ? playback.unpause() : playback.pause()}, 
                            icon: Icon(playback.isPaused ? Icons.play_circle : Icons.pause_circle),
                            style: ButtonStyle(
                              iconSize: WidgetStatePropertyAll(60),
                            ),                
                  ),
                  IconButton(onPressed: () => playback.next(),
                            icon: Icon(Icons.skip_next),
                            style: ButtonStyle(
                              iconSize: WidgetStatePropertyAll(40),
                            ),
                  ),
                  IconButton(onPressed: () => playback.toggleRepeat(), 
                            icon: Icon(playback.loopState == LoopMode.off
                                        ? Icons.repeat_outlined 
                                        : (playback.loopState == LoopMode.all
                                          ? Icons.repeat_on_outlined
                                          : Icons.repeat_one_on_outlined)),
                            style: ButtonStyle(
                              iconColor: WidgetStatePropertyAll(playback.loopState == LoopMode.off 
                                ? Colors.black 
                                : Colors.blue),
                              iconSize: WidgetStatePropertyAll(25),
                            ),
                  ),  
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// child: ClipRRect(
//   borderRadius: BorderRadius.circular(12),
//   child: Image.file(albumArtFile, fit: BoxFit.cover),
// )