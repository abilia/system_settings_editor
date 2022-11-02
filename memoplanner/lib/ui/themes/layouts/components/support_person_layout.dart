import 'package:flutter/material.dart';

class SupportPersonLayout {
  final EdgeInsets switchFieldPadding;
  final double iconSize;

  const SupportPersonLayout({
    this.switchFieldPadding = const EdgeInsets.only(left: 8, right: 8),
    this.iconSize = 36.0,
  });
}

class SupportPersonLayoutMedium extends SupportPersonLayout {
  const SupportPersonLayoutMedium()
      : super(
          switchFieldPadding: const EdgeInsets.only(left: 12, right: 12),
          iconSize: 54.0,
        );
}
