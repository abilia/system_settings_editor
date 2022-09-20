import 'package:flutter/material.dart';

class ThemeLayout {
  final double circleRadius;
  final EdgeInsets inputPadding;

  const ThemeLayout({
    this.circleRadius = 24,
    this.inputPadding =
        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  });
}
