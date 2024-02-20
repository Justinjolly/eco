import 'package:flutter/material.dart';

class SplitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("New Split Card"),
      ),
    );
  }
}
