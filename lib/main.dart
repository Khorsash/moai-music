import 'package:flutter/material.dart';
import 'package:moai_music/file_manip.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
    GoRoute(
      path: '/player',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const PlayerPage(),
        opaque: false,
        barrierColor: Colors.transparent,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    ),
  ],
);


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  AppPaths.init();
  if (Platform.isLinux || Platform.isWindows) {
    JustAudioMediaKit.ensureInitialized(
      linux: true,
      windows: true,
    );
  } else {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidNotificationClickStartsActivity: true,
      androidStopForegroundOnPause: true,
    );
  }
  // runApp(
  //   MultiProvider(
  //     providers: [
  //       ChangeNotifierProvider(create: (_) => PlaylistsController()),
  //       ChangeNotifierProvider(create: (_) => PlaybackController()),
  //     ],
  //     child: const MoaiMusic(),
  //   ),
  // );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlaylistsController()),
        ChangeNotifierProxyProvider<PlaylistsController, PlaybackController>(
          create: (context) => PlaybackController(
            getSong: context.read<PlaylistsController>().getSong,
            getPlaylist: context.read<PlaylistsController>().getPlaylist,
          ),
          update: (context, playlistsController, previous) =>
              previous ??
              PlaybackController(
                getSong: playlistsController.getSong,
                getPlaylist: playlistsController.getPlaylist,
              ),
        ),
      ],
      child: const MoaiMusic(),
    ),
  );
  await Permission.notification.request();
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
