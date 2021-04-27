part of 'week_calendar_settings_cubit.dart';

class WeekCalendarSettingsState extends Equatable {
  final bool showBrowseButtons, showWeekNumber, showYear, showClock;

  WeekCalendarSettingsState._({
    @required this.showBrowseButtons,
    @required this.showWeekNumber,
    @required this.showYear,
    @required this.showClock,
  });

  factory WeekCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      WeekCalendarSettingsState._(
        showBrowseButtons: state.dayCaptionShowDayButtons,
        showWeekNumber: state.activityDisplayWeekDay,
        showYear: state.activityDisplayDayPeriod,
        showClock: state.activityDisplayClock,
      );

  WeekCalendarSettingsState copyWith({
    bool showBrowseButtons,
    bool showWeekNumber,
    bool showYear,
    bool showClock,
  }) =>
      WeekCalendarSettingsState._(
        showBrowseButtons: showBrowseButtons ?? this.showBrowseButtons,
        showWeekNumber: showWeekNumber ?? this.showWeekNumber,
        showYear: showYear ?? this.showYear,
        showClock: showClock ?? this.showClock,
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
      ];

  @override
  List<Object> get props => [
        showBrowseButtons,
        showWeekNumber,
        showYear,
        showClock,
      ];
}
