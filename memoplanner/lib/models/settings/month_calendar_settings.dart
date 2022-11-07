import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memoplanner/models/generic/generic.dart';
import 'package:memoplanner/models/settings/all.dart';

class MonthCalendarSettings extends Equatable {
  static const String monthCaptionShowMonthButtonsKey =
          'month_caption_show_month_buttons',
      monthCaptionShowYearKey = 'month_caption_show_year',
      monthCaptionShowClockKey = 'month_caption_show_clock',
      calendarMonthViewShowColorsKey = 'calendar_month_view_show_colors';

  final bool showBrowseButtons, showYear, showClock;

  final int colorTypeIndex;

  WeekColor get monthWeekColor => WeekColor.values[colorTypeIndex];

  const MonthCalendarSettings({
    this.showBrowseButtons = true,
    this.showYear = true,
    this.showClock = true,
    this.colorTypeIndex = 1,
    Key? key,
  });

  factory MonthCalendarSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      MonthCalendarSettings(
        showBrowseButtons: settings.getBool(
          monthCaptionShowMonthButtonsKey,
        ),
        showYear: settings.getBool(
          monthCaptionShowYearKey,
        ),
        showClock: settings.getBool(
          monthCaptionShowClockKey,
        ),
        colorTypeIndex: settings.parse(
          calendarMonthViewShowColorsKey,
          WeekColor.columns.index,
        ),
      );

  MonthCalendarSettings copyWith({
    bool? showBrowseButtons,
    bool? showYear,
    bool? showClock,
    int? colorTypeIndex,
  }) =>
      MonthCalendarSettings(
        showBrowseButtons: showBrowseButtons ?? this.showBrowseButtons,
        showYear: showYear ?? this.showYear,
        showClock: showClock ?? this.showClock,
        colorTypeIndex: colorTypeIndex ?? this.colorTypeIndex,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showBrowseButtons,
          identifier: monthCaptionShowMonthButtonsKey,
        ),
        MemoplannerSettingData.fromData(
          data: showYear,
          identifier: monthCaptionShowYearKey,
        ),
        MemoplannerSettingData.fromData(
          data: showClock,
          identifier: monthCaptionShowClockKey,
        ),
        MemoplannerSettingData.fromData(
          data: colorTypeIndex,
          identifier: calendarMonthViewShowColorsKey,
        ),
      ];

  @override
  List<Object> get props => [
        showBrowseButtons,
        showYear,
        showClock,
        colorTypeIndex,
      ];
}
