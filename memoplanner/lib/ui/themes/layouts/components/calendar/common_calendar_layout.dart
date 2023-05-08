import 'package:flutter/material.dart';

class CommonCalendarLayout {
  final double fullDayStackDistance, checkmarkFractional;

  final EdgeInsets fullDayPadding,
      fullDayButtonPadding,
      crossOverActivityPadding;

  const CommonCalendarLayout({
    this.fullDayStackDistance = 4,
    this.fullDayPadding = const EdgeInsets.all(12),
    this.crossOverActivityPadding = const EdgeInsets.all(5),
    this.checkmarkFractional = 2 / 3,
    this.fullDayButtonPadding = const EdgeInsets.fromLTRB(10, 4, 4, 4),
  });
}

class CommonCalendarLayoutMedium extends CommonCalendarLayout {
  const CommonCalendarLayoutMedium()
      : super(
          fullDayStackDistance: 4,
          fullDayPadding: const EdgeInsets.all(12),
          crossOverActivityPadding: const EdgeInsets.all(5),
          checkmarkFractional: 2 / 3,
          fullDayButtonPadding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
        );
}
