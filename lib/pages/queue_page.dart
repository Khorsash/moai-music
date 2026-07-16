import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QueuePage extends StatefulWidget {
  const QueuePage({super.key});

  @override
  State<StatefulWidget> createState() => QueuePageState();
}

class QueuePageState extends State<QueuePage> {

  
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey("player"),
      direction: DismissDirection.down,
      onDismissed: (direction) => context.pop(),
      child: Material(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          // child: 
        ),
      ),
    );
  }
}