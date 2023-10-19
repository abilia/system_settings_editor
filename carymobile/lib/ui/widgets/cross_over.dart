import 'package:flutter/material.dart';

class CrossOver extends StatelessWidget {
  const CrossOver({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Image.asset('assets/graphics/cross.png'),
    );
  }
}
