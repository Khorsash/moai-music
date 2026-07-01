import 'package:flutter/material.dart';
import 'package:flutter_test1/models/playlist.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../controllers/contollers.dart';


class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  PlayerPageState createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {


  @override
  Widget build(BuildContext context) {

    final playback = context.read<PlaybackController>();
    if(playback.playingId == null) return Text("nothing to show");
    final playlists = context.read<PlaylistsController>();

    Playlist playlist = playlists.getPlaylist(playback.playingPlaylistId!);


    return Dismissible(
      key: const ValueKey("player"),
      direction: DismissDirection.down,
      onDismissed: (direction) => context.pop(),
      child: Material( 
        // color: Theme.of(context).scaffoldBackgroundColor, // or your player's actual bg
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AppBar(
                leading: IconButton(onPressed: () => context.pop(), icon: Icon(Icons.keyboard_arrow_up)),
                centerTitle: true,
                title: Text("Playing ${playlist.name}", style: TextStyle(fontSize: 16),),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.music_note, size: 64, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              Expanded(
                child: Row(
                  children: [
                    IconButton(onPressed: () => {}, icon: Icon(Icons.shuffle_outlined)),
                    IconButton(onPressed: () => {}, icon: Icon(Icons.skip_previous)),
                    IconButton(onPressed: () => {}, icon: Icon(Icons.shuffle_outlined)),
                    IconButton(onPressed: () => {}, icon: Icon(Icons.skip_next)),
                    IconButton(onPressed: () => {}, icon: Icon(Icons.repeat_outlined)),
                  ]
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//   @override
//   Widget build(BuildContext context) {
//     return Dismissible(
//       key: const ValueKey("player"),
//       direction: DismissDirection.down,
//       onDismissed: (direction) => context.pop(),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(
//                   maxWidth: 400, // cap size on wide screens (desktop/tablet)
//                   maxHeight: 400,
//                 ),
//                 child: AspectRatio(
//                   aspectRatio: 1,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.music_note, size: 64, color: Colors.grey),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 50),
//             Row(children: []),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Padding(
//   padding: EdgeInsets.symmetric(horizontal: 24),
//   child: AspectRatio(
//     aspectRatio: 1,  // 1:1 square
//     child: Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[300],  // placeholder color
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Icon(Icons.music_note, size: 64, color: Colors.grey),  // placeholder icon
//     ),
//   ),
// ),

// child: ClipRRect(
//   borderRadius: BorderRadius.circular(12),
//   child: Image.file(albumArtFile, fit: BoxFit.cover),
// )