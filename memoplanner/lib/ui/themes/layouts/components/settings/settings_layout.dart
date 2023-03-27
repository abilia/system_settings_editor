import 'package:flutter/material.dart';

class SettingsLayout {
  final double clockHeight,
      clockWidth,
      previewTimePillarWidth,
      intervalStepperWidth,
      monthPreviewHeight,
      monthPreviewHeaderHeight,
      weekCalendarHeight,
      weekCalendarHeadingHeight,
      weekdayHeight,
      permissionsDotPosition,
      permissionsDotRadius;

  final EdgeInsets monthDaysPadding, weekdaysPadding;

  const SettingsLayout({
    this.clockHeight = 90,
    this.clockWidth = 72,
    this.previewTimePillarWidth = 138,
    this.intervalStepperWidth = 230,
    this.monthPreviewHeight = 96,
    this.monthPreviewHeaderHeight = 32,
    this.weekCalendarHeight = 148,
    this.weekCalendarHeadingHeight = 44,
    this.weekdayHeight = 86,
    this.permissionsDotPosition = 8,
    this.permissionsDotRadius = 6,
    this.monthDaysPadding = const EdgeInsets.only(left: 4.0, right: 4),
    this.weekdaysPadding = const EdgeInsets.symmetric(horizontal: 2.0),
  });
}

class SettingsLayoutMedium extends SettingsLayout {
  const SettingsLayoutMedium()
      : super(
          clockHeight: 135,
          clockWidth: 108,
          previewTimePillarWidth: 207,
          intervalStepperWidth: 345,
          monthPreviewHeight: 144,
          monthPreviewHeaderHeight: 48,
          weekCalendarHeight: 222,
          weekCalendarHeadingHeight: 66,
          weekdayHeight: 129,
          permissionsDotPosition: 12,
          monthDaysPadding: const EdgeInsets.only(left: 6, right: 6),
          weekdaysPadding: const EdgeInsets.symmetric(horizontal: 3),
        );
}
