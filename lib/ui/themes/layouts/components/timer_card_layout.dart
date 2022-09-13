import 'package:flutter/material.dart';

class TimerCardLayout {
  final double minHeight;
  final Size wheelSize;
  final EdgeInsets wheelPadding;

  const TimerCardLayout({
    this.minHeight = 76,
    this.wheelSize = const Size.square(44),
    this.wheelPadding = const EdgeInsets.symmetric(vertical: 4),
  });
}
