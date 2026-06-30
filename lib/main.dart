import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';


const allSongsPlaylistName = 'all-downloaded';

final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainInterface(child: child),
      routes: [
        GoRoute(path: '/', builder: (context, state) => HomePage()),

        GoRoute(
          path: '/library',
          builder: (context, state) => PlaylistList(), // you'll build this
          routes: [
            GoRoute(
              path: ':playlistId',
              builder: (context, state) {
                final playlistId = state.pathParameters['playlistId']!;
                return SongList(playlistId: playlistId);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaybackController()),
        ChangeNotifierProvider(create: (_) => PlaylistsController()),
      ],
      child: MyApp(),
    ),
  );
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
    );
  }
}



// {
//       'id': 'song_$_counter',
//       'title': 'Item #$_counter',
//       'subtitle': 'This is item number $_counter',
//     }
class Song{
  final String id, title, artist;
  const Song({required this.id, required this.title, required this.artist});
}

class Playlist {
  final String id;
  final String name;
  final List<Song> songs; // or a real Song model later

  Playlist({required this.id, required this.name, required this.songs});
}

class PlaylistsController extends ChangeNotifier {
  final List<Playlist> _playlists = [
    Playlist(id: allSongsPlaylistName, name: 'All Downloaded', songs: []),
  ];

  List<Playlist> get playlists => _playlists;

  Playlist getPlaylist(String id) =>
      _playlists.firstWhere((p) => p.id == id);

  Song getSongFrom(String playlistId, String songId) =>
      getPlaylist(playlistId).songs.firstWhere((p) => p.id == songId);

  void addPlaylist(String name) {
    _playlists.add(Playlist(id: name, name: name, songs: []));
    notifyListeners();
  }

  void addSong(String playlistId, Song song) {
    getPlaylist(playlistId).songs.add(song);
    notifyListeners();
  }

  void removeSong(String playlistId, String songId) {
    getPlaylist(playlistId).songs.removeWhere((s) => s.id == songId);
    notifyListeners();
  }

  void removeSongs(String playlistId, Iterable<String> selectedIds) {
    getPlaylist(playlistId).songs.removeWhere((s) => selectedIds.contains(s.id));
    notifyListeners();
  }

  
}


// PlaybackController.dart
class PlaybackController extends ChangeNotifier {
  String? _playingId;
  bool _isPaused = false;
  String? _playingPlaylistId;

  String? get playingId => _playingId;
  bool get isPaused => _isPaused;
  String? get playingPlaylistId => _playingPlaylistId;

  void play(String playlistId, String id) {
    if (_playingId == id && _isPaused) {
      _isPaused = false;
    } else {
      _playingId = id;
      _playingPlaylistId = playlistId;
      _isPaused = false;
      notifyListeners();
    } // tells every listening widget to rebuild
  }

  void pause() {
    _isPaused = true;
    notifyListeners();
  }

  void unpause() {
    _isPaused = false;
    notifyListeners();
  }

  void stop() {
    _playingId = null;
    _playingPlaylistId = null;
    _isPaused = false;
    notifyListeners();
  }
}

// _______________________________________________________________________________________
// _______________________________________________________________________________________


class PlayingBars extends StatefulWidget {
  const PlayingBars({super.key});

  @override
  State<PlayingBars> createState() => _PlayingBarsState();
}

class _PlayingBarsState extends State<PlayingBars> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + (i * 150)), // stagger speeds
      )..repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _controllers.map((controller) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Container(
              width: 3,
              height: 6 + (controller.value * 14), // bar height animates 6–20px
              margin: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// _______________________________________________________________________________________
// _______________________________________________________________________________________


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


// ── SCREEN ────────────────────────────────────────────────────────────────────

class MainInterface extends StatelessWidget {
  final Widget child;
  const MainInterface({super.key, required this.child});

  int _indexForLocation(String location) {
    if (location.startsWith('/library')) return 1;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/library');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexForLocation(location);

    return Scaffold(
      body: child,  // ← the current route's page renders here

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MiniPlayerBar(),
          BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) => _onTap(context, index),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: 'Library'),
            ],
          ),
        ],
      ),
    );
  }
}


class HomePage extends StatefulWidget {
    const HomePage({super.key});
    @override
    HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TOP BAR
      appBar: AppBar(
        title: Text('Home page'),
      ),
    );
  }
}


class PlaylistList extends StatefulWidget {
  const PlaylistList({super.key});
  @override
  PlaylistListState createState() => PlaylistListState();
}

class PlaylistListState extends State<PlaylistList> {
  int _counter = 1; 
  void _addPlaylist() {
    context.read<PlaylistsController>().addPlaylist('playlist$_counter');
    _counter++;
  }
  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistsController>();
    return Scaffold(
      appBar: AppBar(title: Text("Library"),),
      body: ListView.builder(
              itemCount: playlists.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists.playlists[index];
                return PlaylistItem(playlistName: playlist.name, onCLick: () => context.go('/library/${playlist.id}'),);
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPlaylist,
        child: Icon(Icons.add),
      ),
      );
  }
}

class SongList extends StatefulWidget {
  final String playlistId;
  const SongList({super.key, required this.playlistId});

  @override
  SongListState createState() => SongListState();
}

class SongListState extends State<SongList> {
  int _counter = 1;

  bool _selectionMode = false;
  Set<String> _selectedIds = {};

  void _addItem() {
    final playlists = context.read<PlaylistsController>();
    playlists.addSong(widget.playlistId, Song(
      id: 'song_$_counter',
      title: 'Item #$_counter',
      artist: 'This is item number $_counter',
    ));
    _counter++;
  }

  void _removeItem(String id) {
    final playlists = context.read<PlaylistsController>();
    final playback = context.read<PlaybackController>();
    if (playback.playingId == id) playback.stop();
    playlists.removeSong(widget.playlistId, id);
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _selectionMode = true;
      _selectedIds = {id};
    });
  }

  void _enterSelectionModeWFS() {
    setState(() {
      _selectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _onSelectToggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) _selectionMode = false;
    });
  }

  void _deleteSelected() {
    final playlists = context.read<PlaylistsController>();
    final playback = context.read<PlaybackController>();
    if (playback.playingId != null && _selectedIds.contains(playback.playingId)) {
      playback.stop();
    }
    playlists.removeSongs(widget.playlistId, _selectedIds);
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  SongState _getState(String id, PlaybackController playback) {
    if (_selectionMode) return SongState.selectionMode;
    if (playback.playingId == id) {
      return playback.isPaused ? SongState.paused : SongState.playing;
    }
    return SongState.defaultState;
  }

  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistsController>();
    final playback = context.watch<PlaybackController>();
    final playlist = playlists.getPlaylist(widget.playlistId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectionMode
            ? '${_selectedIds.length} selected'
            : playlist.name),
        leading: _selectionMode
            ? IconButton(icon: Icon(Icons.close), onPressed: _exitSelectionMode)
            : IconButton(icon: Icon(Icons.circle_outlined), onPressed: _enterSelectionModeWFS),
        actions: _selectionMode
            ? [IconButton(icon: Icon(Icons.delete), onPressed: _deleteSelected)]
            : null,
      ),

      body: playlist.songs.isEmpty
          ? Center(child: Text('No items yet. Tap + to add one!'))
          : ListView.builder(
              itemCount: playlist.songs.length,
              itemBuilder: (context, index) {
                final song = playlist.songs[index];
                final id = song.id;
                return Dismissible(
                  key: ValueKey(id),
                  direction: _selectionMode
                      ? DismissDirection.none
                      : DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      _removeItem(id);
                      return true;
                    } else {
                      print('queued!');
                      return false;
                    }
                  },
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(Icons.queue_music_rounded, color: Colors.white),
                  ),
                  child: SongItem(
                    title: song.title,
                    subtitle: song.title,
                    state: _getState(id, playback),
                    isSelected: _selectedIds.contains(id),
                    onPlayPause: () => playback.play(widget.playlistId, id),
                    onSelectToggle: () => _onSelectToggle(id),
                    onMoreTap: () { /* open settings */ },
                    onLongPress: () {
                      if (!_selectionMode) _enterSelectionMode(id);
                    },
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: Icon(Icons.add),
      ),
    );
  }
}

class AddToPlaylistButton extends StatelessWidget {
  const AddToPlaylistButton({super.key});
  @override
  Widget build(BuildContext context){
    return IconButton(onPressed: () => {}, icon: Icon(Icons.add_circle));
  }
}

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final playback = context.watch<PlaybackController>();
    final playlists = context.watch<PlaylistsController>();

    if (playback.playingId == null) {
      return SizedBox.shrink();
    }

    Song song = playlists.getSongFrom(playback.playingPlaylistId!, playback.playingId!);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(Icons.music_note),
        title: Text(song.title),       
        subtitle: Text(song.artist),   
        trailing: Row(
          mainAxisSize: MainAxisSize.min,  // ← add this
          children: [
            IconButton(
              icon: Icon(playback.isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: () {
                if (playback.playingId == null) return;
                if (playback.isPaused) {
                  playback.unpause();
                } else {
                  playback.pause();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

