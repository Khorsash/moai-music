import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final List<Song> songs; // or a real Song model later

  Playlist({required this.id, required this.name, required this.songs});
}