import 'package:flutter/material.dart';

void main() {
  runApp(
    HandiCal(),
  );
}

class HandiCal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HandiScreen(),
    );
  }
}

class HandiScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Handi!"),
      ),
    );
  }
}
