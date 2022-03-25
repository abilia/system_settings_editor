part of 'add_activity_settings_cubit.dart';

class AddActivitySettingsState extends Equatable {
  final bool allowPassedStartTime,
      addRecurringActivity,
      showEndTime,
      showAlarm,
      showSilentAlarm,
      showNoAlarm;

  final NewActivityMode newActivityMode;
  final EditActivitySettings editActivitySettings;
  final WizardStepsSettings stepByStepSettingsState;
  final Alarm defaultAlarm;

  const AddActivitySettingsState._({
    required this.allowPassedStartTime,
    required this.addRecurringActivity,
    required this.showEndTime,
    required this.showAlarm,
    required this.showSilentAlarm,
    required this.showNoAlarm,
    required this.newActivityMode,
    required this.editActivitySettings,
    required this.stepByStepSettingsState,
    required this.defaultAlarm,
  });

  factory AddActivitySettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      AddActivitySettingsState._(
        allowPassedStartTime: state.activityTimeBeforeCurrent,
        addRecurringActivity: state.activityRecurringEditable,
        showEndTime: state.activityEndTimeEditable,
        showAlarm: state.activityDisplayAlarmOption,
        showSilentAlarm: state.activityDisplaySilentAlarmOption,
        showNoAlarm: state.activityDisplayNoAlarmOption,
        newActivityMode: state.addActivityType,
        editActivitySettings: state.settings.editActivity,
        stepByStepSettingsState: state.settings.wizard,
        defaultAlarm: Alarm.fromInt(state.defaultAlarmTypeSetting),
      );

  AddActivitySettingsState copyWith({
    bool? allowPassedStartTime,
    bool? addRecurringActivity,
    bool? showEndTime,
    bool? showAlarm,
    bool? showSilentAlarm,
    bool? showNoAlarm,
    NewActivityMode? newActivityMode,
    EditActivitySettings? editActivitySettings,
    WizardStepsSettings? stepByStepSettingsState,
    Alarm? defaultAlarm,
  }) =>
      AddActivitySettingsState._(
        allowPassedStartTime: allowPassedStartTime ?? this.allowPassedStartTime,
        addRecurringActivity: addRecurringActivity ?? this.addRecurringActivity,
        showEndTime: showEndTime ?? this.showEndTime,
        showAlarm: showAlarm ?? this.showAlarm,
        showSilentAlarm: showSilentAlarm ?? this.showSilentAlarm,
        showNoAlarm: showNoAlarm ?? this.showNoAlarm,
        newActivityMode: newActivityMode ?? this.newActivityMode,
        editActivitySettings: editActivitySettings ?? this.editActivitySettings,
        stepByStepSettingsState:
            stepByStepSettingsState ?? this.stepByStepSettingsState,
        defaultAlarm: defaultAlarm ?? this.defaultAlarm,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: allowPassedStartTime,
          identifier: MemoplannerSettings.activityTimeBeforeCurrentKey,
        ),
        MemoplannerSettingData.fromData(
          data: addRecurringActivity,
          identifier: MemoplannerSettings.activityRecurringEditableKey,
        ),
        MemoplannerSettingData.fromData(
          data: showEndTime,
          identifier: MemoplannerSettings.activityEndTimeEditableKey,
        ),
        MemoplannerSettingData.fromData(
          data: showAlarm,
          identifier: MemoplannerSettings.activityDisplayAlarmOptionKey,
        ),
        MemoplannerSettingData.fromData(
          data: showSilentAlarm,
          identifier: MemoplannerSettings.activityDisplaySilentAlarmOptionKey,
        ),
        MemoplannerSettingData.fromData(
          data: showNoAlarm,
          identifier: MemoplannerSettings.activityDisplayNoAlarmOptionKey,
        ),
        MemoplannerSettingData.fromData(
          data: newActivityMode == NewActivityMode.editView,
          identifier: MemoplannerSettings.addActivityTypeAdvancedKey,
        ),
        ...editActivitySettings.memoplannerSettingData,
        ...stepByStepSettingsState.memoplannerSettingData,
        MemoplannerSettingData.fromData(
          data: defaultAlarm.toInt,
          identifier: MemoplannerSettings.activityDefaultAlarmTypeKey,
        ),
      ];

  @override
  List<Object> get props => [
        allowPassedStartTime,
        addRecurringActivity,
        showEndTime,
        showAlarm,
        showSilentAlarm,
        showNoAlarm,
        editActivitySettings,
        stepByStepSettingsState,
        defaultAlarm,
      ];
}
