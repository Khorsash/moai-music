import 'package:flutter/material.dart';

class AddToPlaylistItem extends StatelessWidget {
  final String playlistName;
  final bool isSelected;
  final VoidCallback _onTap; 
  const AddToPlaylistItem({super.key, required this.playlistName, required this.isSelected, required this._onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.music_note),
        title: Text(playlistName),
        onTap: _onTap,
        trailing: Icon(
            isSelected ? Icons.library_add_check_rounded : Icons.library_add_outlined,
            color: isSelected ? Colors.blue : Colors.black
        ),
      )
    );
  }
}