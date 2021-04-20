part of 'day_calendar_settings_cubit.dart';

class DayCalendarSettingsState extends Equatable {
  final bool showBrowseButtons, showWeekday, showDayPeriod, showDate, showClock;

  DayCalendarSettingsState._({
    @required this.showBrowseButtons,
    @required this.showWeekday,
    @required this.showDayPeriod,
    @required this.showDate,
    @required this.showClock,
  });

  factory DayCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      DayCalendarSettingsState._(
        showBrowseButtons: state.dayCaptionShowDayButtons,
        showWeekday: state.activityDisplayWeekDay,
        showDayPeriod: state.activityDisplayDayPeriod,
        showDate: state.activityDisplayDate,
        showClock: state.activityDisplayClock,
      );

  DayCalendarSettingsState copyWith({
    bool showBrowseButtons,
    bool showWeekday,
    bool showDayPeriod,
    bool showDate,
    bool showClock,
  }) =>
      DayCalendarSettingsState._(
        showBrowseButtons: showBrowseButtons ?? this.showBrowseButtons,
        showWeekday: showWeekday ?? this.showWeekday,
        showDayPeriod: showDayPeriod ?? this.showDayPeriod,
        showDate: showDate ?? this.showDate,
        showClock: showClock ?? this.showClock,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showBrowseButtons,
          identifier: MemoplannerSettings.functionMenuDisplayWeekKey,
        ),
      ];

  @override
  List<Object> get props => [
        showBrowseButtons,
      ];
}
