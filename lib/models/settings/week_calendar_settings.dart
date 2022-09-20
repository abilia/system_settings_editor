import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/models/settings/all.dart';

import 'package:seagull/models/settings/memoplanner_settings_enums.dart';

class WeekCalendarSettings extends Equatable {
  final bool showBrowseButtons,
      showWeekNumber,
      showYear,
      showClock;

  static const String showBrowseButtonsKey = 'week_caption_show_week_buttons',
      showWeekNumberKey = 'week_caption_show_week_number',
      showYearKey = 'week_caption_show_year',
      showClockKey = 'week_caption_show_clock',
      showFullWeekKey = 'week_display_show_full_week',
      showColorModeKey = 'week_display_show_color_mode';


  final int weekDisplayShowFullWeek, weekDisplayShowColorMode;

  const WeekCalendarSettings({
    this.showBrowseButtons = true,
    this.showWeekNumber = true,
    this.showYear = true,
    this.showClock = true,
    this.weekDisplayShowFullWeek = 0,
    this.weekDisplayShowColorMode = 1,
    Key? key,
  });

  WeekColor get weekColor => WeekColor.values[weekDisplayShowColorMode];

  WeekDisplayDays get weekDisplayDays =>
      WeekDisplayDays.values[weekDisplayShowFullWeek];

  factory WeekCalendarSettings.fromSettingsMap(Map<String, MemoplannerSettingData> settings) =>
      WeekCalendarSettings(
        showBrowseButtons: settings.parse(showBrowseButtonsKey, true),
        showWeekNumber: settings.parse(showWeekNumberKey, true),
        showYear: settings.parse(showYearKey, true),
        showClock: settings.parse(showClockKey, true),
        weekDisplayShowFullWeek: settings.parse(showFullWeekKey, 0),
        weekDisplayShowColorMode: settings.parse(showColorModeKey, 1),
      );

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
