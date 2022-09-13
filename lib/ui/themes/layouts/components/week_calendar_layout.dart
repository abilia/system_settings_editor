import 'package:flutter/material.dart';

class WeekCalendarLayout {
  final WeekDayColumnLayout selectedDay, notSelectedDay;

  final double dayDistance, headerHeight, activityDistance, categoryInset;

  final EdgeInsets crossOverDayHeadingPadding,
      crossOverActivityPadding,
      bodyPadding;

  final Radius columnRadius;

  const WeekCalendarLayout({
    this.dayDistance = 2,
    this.headerHeight = 88,
    this.activityDistance = 2,
    this.categoryInset = 0,
    this.columnRadius = const Radius.circular(8),
    this.crossOverDayHeadingPadding = const EdgeInsets.fromLTRB(3, 7, 3, 8),
    this.crossOverActivityPadding = const EdgeInsets.all(5),
    this.bodyPadding = const EdgeInsets.fromLTRB(2, 4, 2, 4),
    this.selectedDay = const WeekDayColumnLayout(
      everyDayFlex: 82,
      weekdaysFlex: 116,
      dayColumnBorderWidth: 2,
    ),
    this.notSelectedDay = const WeekDayColumnLayout(
      everyDayFlex: 48,
      weekdaysFlex: 64,
      dayColumnBorderWidth: 1,
    ),
  });
}

class WeekCalendarLayoutMedium extends WeekCalendarLayout {
  const WeekCalendarLayoutMedium()
      : super(
          selectedDay: const WeekDayColumnLayoutSelectedMedium(),
          notSelectedDay: const WeekDayColumnLayoutNotSelectedMedium(),
          dayDistance: 3,
          headerHeight: 132,
          activityDistance: 4,
          categoryInset: 24,
          crossOverDayHeadingPadding: const EdgeInsets.fromLTRB(6, 6, 6, 18),
          crossOverActivityPadding: const EdgeInsets.all(7),
          bodyPadding: const EdgeInsets.fromLTRB(3, 6, 3, 6),
        );
}

class WeekDayColumnLayout {
  final int everyDayFlex, weekdaysFlex;

  final double activityBorderWidth,
      currentActivityBorderWidth,
      dayColumnBorderWidth;

  final BorderRadius activityRadius;

  final EdgeInsets innerDayPadding;

  const WeekDayColumnLayout({
    required this.everyDayFlex,
    required this.weekdaysFlex,
    required this.dayColumnBorderWidth,
    this.activityBorderWidth = 1.5,
    this.currentActivityBorderWidth = 3,
    this.activityRadius = const BorderRadius.all(Radius.circular(8)),
    this.innerDayPadding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 4,
    ),
  });
}

class WeekDayColumnLayoutSelectedMedium extends WeekDayColumnLayout {
  const WeekDayColumnLayoutSelectedMedium()
      : super(
          everyDayFlex: 318,
          weekdaysFlex: 318,
          activityBorderWidth: 4,
          currentActivityBorderWidth: 6,
          dayColumnBorderWidth: 3,
          activityRadius: const BorderRadius.all(Radius.circular(20)),
          innerDayPadding: const EdgeInsets.symmetric(
            vertical: 9,
            horizontal: 8,
          ),
        );
}

class WeekDayColumnLayoutNotSelectedMedium extends WeekDayColumnLayout {
  const WeekDayColumnLayoutNotSelectedMedium()
      : super(
          everyDayFlex: 79,
          weekdaysFlex: 119,
          activityBorderWidth: 2,
          currentActivityBorderWidth: 6,
          dayColumnBorderWidth: 2,
          activityRadius: const BorderRadius.all(Radius.circular(12)),
          innerDayPadding: const EdgeInsets.symmetric(
            vertical: 9,
            horizontal: 6,
          ),
        );
}
