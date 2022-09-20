import 'package:flutter/material.dart';

class SelectPictureLayout {
  final double imageSize, imageSizeLarge, padding, paddingLarge;
  final EdgeInsets removeButtonPadding;

  const SelectPictureLayout({
    this.imageSize = 84,
    this.imageSizeLarge = 119,
    this.padding = 4,
    this.paddingLarge = 5.67,
    this.removeButtonPadding = const EdgeInsets.fromLTRB(8, 6, 8, 6),
  });
}
