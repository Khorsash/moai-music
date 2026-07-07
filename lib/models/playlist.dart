class Playlist {
  final String name;
  final List<String> songs; // or a real Song model later

  Playlist({required this.name, required this.songs});

  Map<String, dynamic> toJson() => {
    'name': name,
    'songIds': songs,
  };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
    name: json['name'] as String,
    songs: (json['songIds'] as List).cast<String>(),
  );
}