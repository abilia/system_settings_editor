import 'package:flutter/material.dart';

class IconTextButtonStyle {
  final Size minimumSize, maximumSize;
  final EdgeInsets padding;
  final double iconTextSpacing;

  const IconTextButtonStyle({
    this.minimumSize = const Size(172, 64),
    this.maximumSize = const Size(double.infinity, 64),
    this.iconTextSpacing = 8,
    this.padding = const EdgeInsets.only(right: 8),
  });
}
