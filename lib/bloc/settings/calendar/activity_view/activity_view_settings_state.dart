part of 'activity_view_settings_cubit.dart';

class ActivityViewSettingsState extends Equatable {
  final bool alarm, delete, edit, quarterHour, timeOnQuarterHour;

  const ActivityViewSettingsState._({
    required this.alarm,
    required this.delete,
    required this.edit,
    required this.quarterHour,
    required this.timeOnQuarterHour,
  });

  factory ActivityViewSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      ActivityViewSettingsState._(
        alarm: state.displayAlarmButton,
        delete: state.displayDeleteButton,
        edit: state.displayEditButton,
        quarterHour: state.displayQuarterHour,
        timeOnQuarterHour: state.displayTimeLeft,
      );

  ActivityViewSettingsState copyWith({
    bool? alarm,
    bool? delete,
    bool? edit,
    bool? quarterHour,
    bool? timeOnQuarterHour,
  }) =>
      ActivityViewSettingsState._(
        alarm: alarm ?? this.alarm,
        delete: delete ?? this.delete,
        edit: edit ?? this.edit,
        quarterHour: quarterHour ?? this.quarterHour,
        timeOnQuarterHour: timeOnQuarterHour ?? this.timeOnQuarterHour,
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
