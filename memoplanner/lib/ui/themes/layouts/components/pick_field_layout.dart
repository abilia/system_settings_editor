import 'package:flutter/material.dart';

class PickFieldLayout {
  final double height;
  final double iconSize;
  final Size leadingSize;
  final double bottomPadding;
  final EdgeInsets padding, leadingPadding, imagePadding, verticalPadding;
  final EdgeInsets withExtrasPadding;

  const PickFieldLayout({
    this.height = 56,
    this.iconSize = 24,
    this.bottomPadding = 12,
    this.leadingSize = const Size(48, 48),
    this.padding = const EdgeInsets.only(left: 12, right: 12),
    this.imagePadding = const EdgeInsets.only(right: 8),
    this.leadingPadding = const EdgeInsets.only(right: 12),
    this.verticalPadding = const EdgeInsets.symmetric(vertical: 16),
    this.withExtrasPadding =
        const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 16),
  });
}

class PickFieldLayoutMedium extends PickFieldLayout {
  const PickFieldLayoutMedium()
      : super(
          padding: const EdgeInsets.only(left: 18, right: 18),
          imagePadding: const EdgeInsets.only(left: 0, right: 12),
          leadingPadding: const EdgeInsets.only(right: 18),
          height: 88,
          iconSize: 32,
          bottomPadding: 16,
          leadingSize: const Size(72, 72),
          verticalPadding: const EdgeInsets.symmetric(vertical: 24),
          withExtrasPadding:
              const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 24),
        );
}
