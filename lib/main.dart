import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'controllers/contollers.dart';
import 'pages/pages.dart';


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
        GoRoute(
          path: '/newPlaylist',
          builder: (context, state) => NewPlaylistPage(),
        )
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
      child: MoaiMusic(),
    ),
  );
}



class MoaiMusic extends StatelessWidget {
  const MoaiMusic({super.key});

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
