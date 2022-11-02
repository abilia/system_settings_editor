import 'package:flutter/material.dart';

class OngoingTabLayout {
  final OngoingActivityLayout activity;
  final double height;
  final EdgeInsets padding;

  const OngoingTabLayout({
    this.height = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
    this.activity = const OngoingActivityLayout(),
  });
}

class OngoingActivityLayout {
  final double border, activeBorder;
  final Size arrowSize;
  final EdgeInsets padding, selectedPadding;

  final Radius arrowPointRadius;
  final OngoingCategoryDotLayout dot;

  const OngoingActivityLayout({
    this.activeBorder = 2,
    this.border = 1.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
    this.selectedPadding = const EdgeInsets.symmetric(vertical: 2),
    this.dot = const OngoingCategoryDotLayout(),
    this.arrowSize = const Size(32, 14),
    this.arrowPointRadius = const Radius.circular(4),
  });
}

class OngoingCategoryDotLayout {
  final double innerRadius, outerRadius, offset, selectedOffset;

  const OngoingCategoryDotLayout({
    this.innerRadius = 4,
    this.outerRadius = 5,
    this.offset = 3,
    this.selectedOffset = 5,
  });
}
