part of 'activity_view_settings_cubit.dart';

class ActivityViewSettingsState extends Equatable {
  final bool alarm, delete, edit, quarterHour, timeOnQuarterHour;

  ActivityViewSettingsState._(
    this.alarm,
    this.delete,
    this.edit,
    this.quarterHour,
    this.timeOnQuarterHour,
  );

  factory ActivityViewSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      ActivityViewSettingsState._(
        state.displayDeleteButton,
        state.displayEditButton,
        state.displayAlarmButton,
        state.displayQuarterHour,
        state.displayTimeLeft,
      );

  ActivityViewSettingsState copyWith({
    bool? alarm,
    bool? delete,
    bool? edit,
    bool? quarterHour,
    bool? timeOnQuarterHour,
  }) =>
      ActivityViewSettingsState._(
        alarm ?? this.alarm,
        delete ?? this.delete,
        edit ?? this.edit,
        quarterHour ?? this.quarterHour,
        timeOnQuarterHour ?? this.timeOnQuarterHour,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: alarm,
          identifier: MemoplannerSettings.displayAlarmButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: delete,
          identifier: MemoplannerSettings.displayDeleteButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: edit,
          identifier: MemoplannerSettings.displayEditButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: quarterHour,
          identifier: MemoplannerSettings.displayQuarterHourKey,
        ),
        MemoplannerSettingData.fromData(
          data: timeOnQuarterHour,
          identifier: MemoplannerSettings.displayTimeLeftKey,
        ),
      ];

  @override
  List<Object> get props => [
        alarm,
        delete,
        edit,
        quarterHour,
        timeOnQuarterHour,
      ];
}
