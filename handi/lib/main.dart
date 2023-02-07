import 'package:flutter/material.dart';

void main() {
  runApp(
    const HandiApp(),
  );
}

class HandiApp extends StatelessWidget {
  const HandiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Handi!'),
        ),
      ),
    );
  }
}
