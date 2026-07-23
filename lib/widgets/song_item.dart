import 'package:flutter/material.dart';
import 'playing_bars.dart';

enum SongState { defaultState, playing, paused, selectionMode }

class SongItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final SongState state;
  final bool isSelected;
  final VoidCallback onPlayPause;
  final VoidCallback onSelectToggle;
  final ValueChanged<String> onMenuAction;
  final VoidCallback onLongPress;
  final bool isPlayable;
  final Image? artwork;
  final bool isUserAdd;
  final Widget? dragHandle;

  const SongItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.isSelected,
    required this.onPlayPause,
    required this.onSelectToggle,
    required this.onMenuAction,
    required this.onLongPress,
    required this.isPlayable,
    required this.artwork,
    this.isUserAdd = false,
    this.dragHandle
  });

  Widget _buildForeground() {
    switch (state) {
      case SongState.selectionMode:
        return Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? Colors.blue : Colors.black,
        );
      case SongState.playing:
        return PlayingBars();
      case SongState.paused:
        return Icon(Icons.pause, color: Colors.blue);
      default:
        return DecoratedBox(
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(4),
            // color: Colors.black.withValues(alpha: 0),
          )
        );
    }
  }

  Color? _getBackgroundColor() {
    switch (state) {
      case SongState.playing: case SongState.paused:
        return Colors.blue.withValues(alpha: 0.08);
      case SongState.selectionMode:
        return isSelected ? Colors.blue.withValues(alpha: 0.15) : null;
      default:
        return null; // transparent, no card look
    }
  }

  Color? _getTitleColor() {
    switch(state) {
      case SongState.playing: case SongState.paused:
        return Colors.lightBlue;
      default:
        return isUserAdd ? Colors.green : Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: _getBackgroundColor() ?? Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: state == SongState.selectionMode ? onSelectToggle : onPlayPause,
          onLongPress: onLongPress,
          leading: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                artwork != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: artwork,
                    )
                  : DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.black.withValues(alpha: 0.25),
                        ),
                        child: Icon(Icons.music_note, color: Colors.grey),
                    ),
                _buildForeground(),
              ],
            ),
          ),
          title: Text(title, style: TextStyle(color: _getTitleColor()),),
          subtitle: Text(subtitle),
          trailing: state == SongState.selectionMode
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: onMenuAction,
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'queue',
                          child: ListTile(
                            leading: Icon(Icons.queue_music_rounded),
                            title: Text('Add to queue'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'playlists',
                          child: ListTile(
                            leading: Icon(Icons.library_add_outlined),
                            title: Text('Add to playlist'),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'select',
                          child: ListTile(
                            leading: Icon(Icons.check_circle_outline),
                            title: Text('Select'),
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
                    if (dragHandle != null) dragHandle!,
                  ]
                )
        ),
      ),
    );
  }
}
