part of 'week_calendar_settings_cubit.dart';

class WeekCalendarSettingsState extends Equatable {
  final bool showBrowseButtons, showWeekNumber, showYear, showClock;

  final WeekDisplayDays weekDisplayDays;
  final WeekColor weekColor;

  const WeekCalendarSettingsState._({
    required this.showBrowseButtons,
    required this.showWeekNumber,
    required this.showYear,
    required this.showClock,
    required this.weekDisplayDays,
    required this.weekColor,
  });

  factory WeekCalendarSettingsState.fromSettings(
    WeekCalendarSettings settings,
  ) =>
      WeekCalendarSettingsState._(
        showBrowseButtons: settings.showBrowseButtons,
        showWeekNumber: settings.showWeekNumber,
        showYear: settings.showYear,
        showClock: settings.showClock,
        weekDisplayDays: settings.weekDisplayDays,
        weekColor: settings.weekColor,
      );

  WeekCalendarSettingsState copyWith({
    bool? showBrowseButtons,
    bool? showWeekNumber,
    bool? showYear,
    bool? showClock,
    WeekDisplayDays? weekDisplayDays,
    WeekColor? weekColor,
  }) =>
      WeekCalendarSettingsState._(
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
          identifier: MemoplannerSettings.weekCaptionShowBrowseButtonsKey,
        ),
        MemoplannerSettingData.fromData(
          data: showWeekNumber,
          identifier: MemoplannerSettings.weekCaptionShowWeekNumberKey,
        ),
        MemoplannerSettingData.fromData(
          data: showYear,
          identifier: MemoplannerSettings.weekCaptionShowYearKey,
        ),
        MemoplannerSettingData.fromData(
          data: showClock,
          identifier: MemoplannerSettings.weekCaptionShowClockKey,
        ),
        MemoplannerSettingData.fromData(
          data: weekDisplayDays.index,
          identifier: MemoplannerSettings.weekDisplayShowFullWeekKey,
        ),
        MemoplannerSettingData.fromData(
          data: weekColor.index,
          identifier: MemoplannerSettings.weekDisplayShowColorModeKey,
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
