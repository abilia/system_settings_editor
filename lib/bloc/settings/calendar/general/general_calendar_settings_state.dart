part of 'general_calendar_settings_cubit.dart';

class GeneralCalendarSettingsState extends Equatable {
  final ClockType clockType;
  GeneralCalendarSettingsState._(
    this.clockType,
  );

  factory GeneralCalendarSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      GeneralCalendarSettingsState._(
        state.clockType,
      );

  GeneralCalendarSettingsState copyWith({
    ClockType clockType,
  }) =>
      GeneralCalendarSettingsState._(
        clockType ?? this.clockType,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: clockType.index,
          identifier: MemoplannerSettings.settingClockTypeKey,
        ),
      ];

  @override
  List<Object> get props => [
        clockType,
      ];
}
