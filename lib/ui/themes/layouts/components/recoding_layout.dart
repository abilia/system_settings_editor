import 'package:flutter/material.dart';

class RecordingLayout {
  final double trackHeight, thumbRadius;
  final EdgeInsets padding;

  const RecordingLayout({
    this.trackHeight = 4,
    this.thumbRadius = 12,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 32,
    ),
  });
}
