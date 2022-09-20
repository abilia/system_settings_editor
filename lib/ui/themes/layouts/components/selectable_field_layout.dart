import 'package:flutter/material.dart';

class SelectableFieldLayout {
  final double position,
      size,
      height,
      textLeftPadding,
      textRightPadding,
      textTopPadding;
  final EdgeInsets padding;
  final EdgeInsets boxPadding;

  const SelectableFieldLayout({
    this.height = 48,
    this.position = -6,
    this.size = 24,
    this.textLeftPadding = 12,
    this.textRightPadding = 26,
    this.textTopPadding = 10,
    this.padding = const EdgeInsets.all(4),
    this.boxPadding = const EdgeInsets.all(3),
  });
}
