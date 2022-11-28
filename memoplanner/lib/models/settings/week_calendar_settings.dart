import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memoplanner/models/generic/generic.dart';
import 'package:memoplanner/models/settings/all.dart';

class WeekCalendarSettings extends Equatable {
  final bool showBrowseButtons, showWeekNumber, showYear, showClock;

  static const String showBrowseButtonsKey = 'week_caption_show_week_buttons',
      showWeekNumberKey = 'week_caption_show_week_number',
      showYearKey = 'week_caption_show_year',
      showClockKey = 'week_caption_show_clock',
      showFullWeekKey = 'week_display_show_full_week',
      showColorModeKey = 'week_display_show_color_mode';

  final WeekDisplayDays weekDisplayDays;
  final WeekColor weekColor;

  const WeekCalendarSettings({
    this.showBrowseButtons = true,
    this.showWeekNumber = true,
    this.showYear = true,
    this.showClock = true,
    this.weekDisplayDays = WeekDisplayDays.everyDay,
    this.weekColor = WeekColor.columns,
    Key? key,
  });

  factory WeekCalendarSettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      WeekCalendarSettings(
        showBrowseButtons: settings.parse(showBrowseButtonsKey, true),
        showWeekNumber: settings.parse(showWeekNumberKey, true),
        showYear: settings.parse(showYearKey, true),
        showClock: settings.parse(showClockKey, true),
        weekDisplayDays: WeekDisplayDays.values[settings.parse(
          showFullWeekKey,
          WeekDisplayDays.everyDay.index,
        )],
        weekColor: WeekColor.values[settings.parse(
          showColorModeKey,
          WeekColor.columns.index,
        )],
      );

  WeekCalendarSettings copyWith({
    bool? showBrowseButtons,
    bool? showWeekNumber,
    bool? showYear,
    bool? showClock,
    WeekDisplayDays? weekDisplayDays,
    WeekColor? weekColor,
  }) =>
      WeekCalendarSettings(
        showBrowseButtons: showBrowseButtons ?? this.showBrowseButtons,
        showWeekNumber: showWeekNumber ?? this.showWeekNumber,
        showYear: showYear ?? this.showYear,
        showClock: showClock ?? this.showClock,
        weekDisplayDays: weekDisplayDays ?? this.weekDisplayDays,
        weekColor: weekColor ?? this.weekColor,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showBrowseButtons,
          identifier: WeekCalendarSettings.showBrowseButtonsKey,
        ),
        MemoplannerSettingData.fromData(
          data: showWeekNumber,
          identifier: WeekCalendarSettings.showWeekNumberKey,
        ),
        MemoplannerSettingData.fromData(
          data: showYear,
          identifier: WeekCalendarSettings.showYearKey,
        ),
        MemoplannerSettingData.fromData(
          data: showClock,
          identifier: WeekCalendarSettings.showClockKey,
        ),
        MemoplannerSettingData.fromData(
          data: weekDisplayDays.index,
          identifier: WeekCalendarSettings.showFullWeekKey,
        ),
        MemoplannerSettingData.fromData(
          data: weekColor.index,
          identifier: WeekCalendarSettings.showColorModeKey,
        ),
      ];

  @override
  List<Object> get props => [
        showBrowseButtons,
        showWeekNumber,
        showYear,
        showClock,
        weekDisplayDays,
        weekColor,
      ];
}