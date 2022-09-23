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

  factory ActivityViewSettingsState.fromSettings(
    ActivityViewSettings state,
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
          identifier: ActivityViewSettings.displayAlarmButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: delete,
          identifier: ActivityViewSettings.displayDeleteButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: edit,
          identifier: ActivityViewSettings.displayEditButtonKey,
        ),
        MemoplannerSettingData.fromData(
          data: quarterHour,
          identifier: ActivityViewSettings.displayQuarterHourKey,
        ),
        MemoplannerSettingData.fromData(
          data: timeOnQuarterHour,
          identifier: ActivityViewSettings.displayTimeLeftKey,
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
