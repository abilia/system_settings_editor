import 'package:flutter/material.dart';

class MonthCalendarDayLayout {
  final double radius,
      radiusHighlighted,
      borderWidth,
      borderWidthHighlighted,
      headerHeight,
      headingFontSize,
      fullDayActivityFontSize,
      hasActivitiesDotRadius;

  final EdgeInsets viewPadding,
      viewPaddingHighlighted,
      viewMargin,
      viewMarginHighlighted,
      headerPadding,
      containerPadding,
      crossOverPadding,
      hasActivitiesDotPadding,
      hasActivitiesDotPaddingCompact,
      activityTextContentPadding;

  const MonthCalendarDayLayout({
    this.radius = 8,
    this.radiusHighlighted = 10,
    this.borderWidth = 1,
    this.borderWidthHighlighted = 4,
    this.headerHeight = 24,
    this.headingFontSize = 14,
    this.fullDayActivityFontSize = 12,
    this.hasActivitiesDotRadius = 3,
    this.viewPadding = const EdgeInsets.all(4),
    this.viewPaddingHighlighted = const EdgeInsets.all(6),
    this.viewMargin = const EdgeInsets.all(2),
    this.viewMarginHighlighted = const EdgeInsets.all(0),
    this.headerPadding = const EdgeInsets.only(left: 4, top: 7, right: 4),
    this.containerPadding =
        const EdgeInsets.only(left: 5, top: 3, right: 5, bottom: 5),
    this.crossOverPadding = const EdgeInsets.all(3),
    this.hasActivitiesDotPadding = const EdgeInsets.all(0),
    this.hasActivitiesDotPaddingCompact = const EdgeInsets.all(0),
    this.activityTextContentPadding = const EdgeInsets.all(3),
  });
}

class MonthCalendarDayLayoutMedium extends MonthCalendarDayLayout {
  const MonthCalendarDayLayoutMedium()
      : super(
          radius: 12,
          radiusHighlighted: 14,
          borderWidth: 2,
          borderWidthHighlighted: 6,
          headerHeight: 28,
          headingFontSize: 20,
          hasActivitiesDotRadius: 5,
          viewMargin: const EdgeInsets.all(4),
          viewMarginHighlighted: const EdgeInsets.all(1),
          viewPadding: const EdgeInsets.all(0),
          viewPaddingHighlighted: const EdgeInsets.all(3),
          headerPadding: const EdgeInsets.only(left: 6, right: 6, top: 6),
          containerPadding:
              const EdgeInsets.only(left: 6, right: 6, top: 4, bottom: 6),
          hasActivitiesDotPadding: const EdgeInsets.only(right: 2, top: 2),
          hasActivitiesDotPaddingCompact:
              const EdgeInsets.only(right: 8, top: 8),
          activityTextContentPadding: const EdgeInsets.all(4),
        );
}
