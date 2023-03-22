import 'package:flutter/material.dart';

class TimerCardLayout {
  final Size smallWheelSize, largeWheelSize;
  final EdgeInsets wheelPadding, textPadding, imagePadding;
  final Radius borderRadius;

  const TimerCardLayout({
    this.smallWheelSize = const Size.square(24),
    this.largeWheelSize = const Size.square(44),
    this.wheelPadding = const EdgeInsets.symmetric(vertical: 4),
    this.textPadding = EdgeInsets.zero,
    this.imagePadding = EdgeInsets.zero,
    this.borderRadius = const Radius.circular(10),
  });
}
