import 'package:equatable/equatable.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/models/all.dart';

class DisplaySettings extends Equatable {
  static const functionMenuDisplayWeekKey = 'function_menu_display_week',
      functionMenuDisplayMonthKey = 'function_menu_display_month',
      functionMenuDisplayNewActivityKey = 'function_menu_display_new_activity',
      functionMenuDisplayNewTimerKey = 'function_menu_display_new_timer',
      functionMenuDisplayMenuKey = 'function_menu_display_menu';

  final bool week,
      month,
      newActivity,
      newTimer,
      menuValue,
      allMenuItemsDisabled;

  bool get onlyDayCalendar => !week && !month;
  bool get menu => menuValue && !allMenuItemsDisabled;

  int get weekCalendarTabIndex => 1;
  int get monthCalendarTabIndex => 2;
  int get menuTabIndex => 3;
  int get photoAlbumTabIndex => 4;
  int get calendarCount =>
      (Config.isMP ? photoAlbumTabIndex : menuTabIndex) + 1;

  bool get bottomBar => newActivity || newTimer || week || month || menu;

  const DisplaySettings({
    this.week = true,
    this.month = true,
    this.newActivity = true,
    this.newTimer = true,
    this.menuValue = true,
    this.allMenuItemsDisabled = false,
  });

  DisplaySettings copyWith({
    bool? week,
    bool? month,
    bool? newActivity,
    bool? newTimer,
    bool? menuValue,
  }) =>
      DisplaySettings(
        week: week ?? this.week,
        month: month ?? this.month,
        newActivity: newActivity ?? this.newActivity,
        newTimer: newTimer ?? this.newTimer,
        menuValue: menuValue ?? this.menuValue,
      );

  factory DisplaySettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      DisplaySettings(
        week: settings.getBool(functionMenuDisplayWeekKey),
        month: settings.getBool(functionMenuDisplayMonthKey),
        newActivity: settings.getBool(functionMenuDisplayNewActivityKey),
        newTimer: settings.getBool(functionMenuDisplayNewTimerKey),
        menuValue: settings.getBool(functionMenuDisplayMenuKey),
        allMenuItemsDisabled:
            MenuSettings.fromSettingsMap(settings).allDisabled,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: week,
          identifier: functionMenuDisplayWeekKey,
        ),
        MemoplannerSettingData.fromData(
          data: month,
          identifier: functionMenuDisplayMonthKey,
        ),
        MemoplannerSettingData.fromData(
          data: newActivity,
          identifier: functionMenuDisplayNewActivityKey,
        ),
        MemoplannerSettingData.fromData(
          data: newTimer,
          identifier: functionMenuDisplayNewTimerKey,
        ),
        MemoplannerSettingData.fromData(
          data: menuValue,
          identifier: functionMenuDisplayMenuKey,
        ),
      ];

  @override
  List<Object> get props => [
        week,
        month,
        newActivity,
        newTimer,
        menuValue,
        allMenuItemsDisabled,
      ];
}
