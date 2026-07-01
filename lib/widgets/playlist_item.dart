import 'package:flutter/material.dart';

class PlaylistItem extends StatelessWidget {
  final String playlistName;
  final VoidCallback _onCLick; 
  const PlaylistItem({super.key, required this.playlistName, required this._onCLick});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.music_note),
        title: Text(playlistName),
        onTap: _onCLick,
      )
    );
  }
}