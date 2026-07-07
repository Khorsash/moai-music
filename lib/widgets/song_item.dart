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
  final VoidCallback onMoreTap;
  final VoidCallback onLongPress;
  final bool isPlayable;

  const SongItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.state,
    required this.isSelected,
    required this.onPlayPause,
    required this.onSelectToggle,
    required this.onMoreTap,
    required this.onLongPress,
    required this.isPlayable
  });

  Widget _buildLeading() {
    switch (state) {
      case SongState.selectionMode:
        return Icon(
          isSelected ? Icons.check_circle : Icons.circle_outlined,
          color: isSelected ? Colors.blue : Colors.grey,
        );
      case SongState.playing:
        return PlayingBars();
      default:
        return Icon(Icons.music_note, color: Colors.grey);
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
        return Colors.grey;
      default:
        return Colors.black;
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
          leading: _buildLeading(),
          title: Text(title, style: TextStyle(color: _getTitleColor()),),
          subtitle: Text(subtitle),
          trailing: state == SongState.selectionMode
              ? null
              : IconButton(icon: Icon(Icons.more_vert), onPressed: onMoreTap),
        ),
      ),
    );
  }
}
