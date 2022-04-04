part of 'add_activity_settings_cubit.dart';

class AddActivitySettingsState extends Equatable {
  final AddActivitySettings addActivitySetting;
  final NewActivityMode newActivityMode;
  final EditActivitySettings editActivitySetting;
  final StepByStepSettings stepByStepSetting;
  final Alarm defaultAlarm;

  const AddActivitySettingsState._({
    required this.addActivitySetting,
    required this.newActivityMode,
    required this.editActivitySetting,
    required this.stepByStepSetting,
    required this.defaultAlarm,
  });

  factory AddActivitySettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      AddActivitySettingsState._(
        addActivitySetting: state.settings.addActivity,
        newActivityMode: state.addActivityType,
        editActivitySetting: state.settings.editActivity,
        stepByStepSetting: state.settings.stepByStep,
        defaultAlarm: Alarm.fromInt(state.defaultAlarmTypeSetting),
      );

  AddActivitySettingsState copyWith({
    AddActivitySettings? addActivitySetting,
    NewActivityMode? newActivityMode,
    EditActivitySettings? editActivitySetting,
    StepByStepSettings? stepByStepSetting,
    Alarm? defaultAlarm,
  }) =>
      AddActivitySettingsState._(
        addActivitySetting: addActivitySetting ?? this.addActivitySetting,
        newActivityMode: newActivityMode ?? this.newActivityMode,
        editActivitySetting: editActivitySetting ?? this.editActivitySetting,
        stepByStepSetting: stepByStepSetting ?? this.stepByStepSetting,
        defaultAlarm: defaultAlarm ?? this.defaultAlarm,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        ...addActivitySetting.memoplannerSettingData,
        MemoplannerSettingData.fromData(
          data: newActivityMode == NewActivityMode.editView,
          identifier: MemoplannerSettings.addActivityTypeAdvancedKey,
        ),
        ...editActivitySetting.memoplannerSettingData,
        ...stepByStepSetting.memoplannerSettingData,
        MemoplannerSettingData.fromData(
          data: defaultAlarm.toInt,
          identifier: MemoplannerSettings.activityDefaultAlarmTypeKey,
        ),
      ];

  @override
  List<Object> get props => [
        addActivitySetting,
        newActivityMode,
        editActivitySetting,
        stepByStepSetting,
        defaultAlarm,
      ];
}
