import 'package:flutter/material.dart';

class CommonCalendarLayout {
  final double fullDayStackDistance, goToNowButtonTop;

  final EdgeInsets fullDayPadding, fullDayButtonPadding;

  const CommonCalendarLayout({
    this.fullDayStackDistance = 4,
    this.goToNowButtonTop = 32,
    this.fullDayPadding = const EdgeInsets.all(12),
    this.fullDayButtonPadding = const EdgeInsets.fromLTRB(10, 4, 4, 4),
  });
}
