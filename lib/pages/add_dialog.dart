import 'package:flutter/material.dart';


class AddDialog extends StatefulWidget {
  const AddDialog({super.key});

  @override
  State<StatefulWidget> createState() => AddDialogState();
}

class AddDialogState extends State<AddDialog> {


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .all(8),
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        children: [
          Row(
            children: [
              
            ],
          )
        ],
      ),
    );
  }
}