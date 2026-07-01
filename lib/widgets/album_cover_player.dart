import 'package:flutter/material.dart';

class AlbumCoverPlayer extends StatelessWidget {
  final Image? image;
  const AlbumCoverPlayer({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
              child: AspectRatio(
                aspectRatio: 1,
                child: image == null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.music_note, size: 64, color: Colors.grey),
                    )
                  : ClipRRect (
                      borderRadius: BorderRadius.circular(12),
                      child: image,
                    )
              ),
            ),
    );
  }
}