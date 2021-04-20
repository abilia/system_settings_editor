part of 'day_calendar_settings_cubit.dart';

class DayCalendarSettingsState extends Equatable {
  final bool displayWeek;

  DayCalendarSettingsState._({
    this.displayWeek,
  });

  factory DayCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      DayCalendarSettingsState._(
        displayWeek: state.displayWeekCalendar,
      );

  DayCalendarSettingsState copyWith({
    bool displayWeek,
  }) =>
      DayCalendarSettingsState._(
        displayWeek: displayWeek ?? this.displayWeek,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: displayWeek,
          identifier: MemoplannerSettings.functionMenuDisplayWeekKey,
        ),
      ];

  @override
  List<Object> get props => [
        displayWeek,
      ];
}
