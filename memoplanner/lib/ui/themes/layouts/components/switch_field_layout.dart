import 'package:flutter/material.dart';

class SwitchFieldLayout {
  final double height;
  final EdgeInsets padding;
  final SwitchLayout switchLayout;

  const SwitchFieldLayout({
    this.height = 56,
    this.padding = const EdgeInsets.only(left: 12.0, right: 16.0),
    this.switchLayout = const SwitchLayout(),
  });
}

class SwitchLayout {
  final double height, width, thumbSize;

  const SwitchLayout({
    this.width = 34,
    this.height = 14,
    this.thumbSize = 20,
  });
}
