import 'package:flutter/painting.dart';

class InfoRowLayout {
  final double progressIndicatorStrokeWidth,
      iconSize,
      borderWidth,
      borderRadius;
  final EdgeInsets titlePadding, contentPadding;

  const InfoRowLayout({
    this.progressIndicatorStrokeWidth = 3,
    this.iconSize = 24,
    this.borderWidth = 1,
    this.borderRadius = 12,
    this.titlePadding = const EdgeInsets.symmetric(horizontal: 8),
    this.contentPadding = const EdgeInsets.all(8),
  });
}

class InfoRowLayoutMedium extends InfoRowLayout {
  const InfoRowLayoutMedium({
    super.progressIndicatorStrokeWidth = 4,
    super.iconSize = 32,
    super.borderWidth = 1,
    super.borderRadius = 20,
    super.titlePadding = const EdgeInsets.symmetric(horizontal: 12),
    super.contentPadding = const EdgeInsets.all(12),
  });
}
