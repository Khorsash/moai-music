import 'package:flutter/material.dart';

enum SongState { defaultState, playing, paused, selectionMode }

class SongAddItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Image? artwork;

  const SongAddItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.artwork
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: onTap,
          onLongPress: onTap,
          leading: SizedBox(
            width: 40,
            height: 40,
            child: artwork != null
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
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(
            isSelected ? Icons.library_add_check_rounded : Icons.library_add_outlined,
            color: isSelected ? Colors.blue : Colors.black
          )
        ),
      ),
    );
  }
}