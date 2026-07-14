import 'package:flutter/material.dart';


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
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
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
      ),
    );
  }
}