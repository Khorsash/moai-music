import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/playlists_controller.dart';



class NewPlaylistPage extends StatefulWidget {
  const NewPlaylistPage({super.key});

  @override
  NewPlaylistPageState createState() => NewPlaylistPageState();
}

class NewPlaylistPageState extends State<NewPlaylistPage> {

  final tcontroller = TextEditingController();
  

  @override
  void dispose() {
    tcontroller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    tcontroller.text = "New Playlist";
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,  // shrink to content
          crossAxisAlignment: CrossAxisAlignment.center,  // buttons align with field
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 150, maxWidth: 300),
              child: TextField(
                controller: tcontroller,
                style: TextStyle(
                  fontSize: 24
                ),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: "Playlist Name",
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // buttons on the right
              children: [
                TextButton(
                  child: Text("Cancel", style: TextStyle(fontSize: 20),),
                  
                  onPressed: () => context.pop(),
                  
                ),
                TextButton(
                  child: Text("Confirm", style: TextStyle(fontSize: 20),),
                  onPressed: () {
                    final playlists = context.read<PlaylistsController>();
                    final id = playlists.addPlaylist(tcontroller.text);
                    context.go('/library/$id');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}