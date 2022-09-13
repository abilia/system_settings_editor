import 'package:flutter/material.dart';

class NavigationBarLayout {
  final double height, spaceBetweeen;
  final EdgeInsets padding;

  const NavigationBarLayout({
    this.height = 84,
    this.spaceBetweeen = 8,
    this.padding = const EdgeInsets.only(
      left: 12,
      top: 8,
      right: 12,
      bottom: 12,
    ),
  });
}

class NavigationBarLayoutMedium extends NavigationBarLayout {
  const NavigationBarLayoutMedium()
      : super(
          height: 128,
          spaceBetweeen: 12,
          padding:
              const EdgeInsets.only(left: 18, top: 12, right: 18, bottom: 20),
        );
}
