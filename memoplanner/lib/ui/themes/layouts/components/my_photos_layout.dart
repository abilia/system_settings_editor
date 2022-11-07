import 'package:flutter/material.dart';

class MyPhotosLayout {
  final double? childAspectRatio;
  final double fullScreenImageBorderRadius;
  final int crossAxisCount;
  final EdgeInsets fullScreenImagePadding;

  const MyPhotosLayout({
    this.childAspectRatio,
    this.fullScreenImageBorderRadius = 12,
    this.crossAxisCount = 3,
    this.fullScreenImagePadding = const EdgeInsets.all(12),
  });
}

class MyPhotosLayoutMedium extends MyPhotosLayout {
  const MyPhotosLayoutMedium()
      : super(
          crossAxisCount: 3,
          fullScreenImageBorderRadius: 20,
          childAspectRatio: 240 / 168,
          fullScreenImagePadding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        );
}
