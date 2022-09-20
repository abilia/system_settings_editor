import 'package:flutter/material.dart';

class PickFieldLayout {
  final double height;
  final Size leadingSize;
  final EdgeInsets padding, leadingPadding, imagePadding;

  const PickFieldLayout({
    this.height = 56,
    this.leadingSize = const Size(48, 48),
    this.padding = const EdgeInsets.only(left: 12, right: 12),
    this.imagePadding = const EdgeInsets.only(right: 8),
    this.leadingPadding = const EdgeInsets.only(right: 12),
  });
}
