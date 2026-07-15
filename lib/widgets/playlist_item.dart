import 'package:flutter/material.dart';

class PlaylistItem extends StatelessWidget {
  final String playlistName;
  final VoidCallback _onCLick; 
  final ValueChanged<String> onMenuAction;
  const PlaylistItem({super.key, required this.playlistName, required this._onCLick, required this.onMenuAction});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.music_note),
        title: Text(playlistName),
        onTap: _onCLick,
        trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: onMenuAction,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'play',
                      child: ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text('Play'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'addtoqueue',
                      child: ListTile(
                        leading: Icon(Icons.queue_music),
                        title: Text('Add to Queue'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
      )
    );
  }
}