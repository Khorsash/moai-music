import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/mini_player_bar.dart';

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
      case 2:
        context.push('/queue');
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
              BottomNavigationBarItem(icon: Icon(Icons.queue_music), label: 'Queue'),
            ],
          ),
        ],
      ),
    );
  }
}