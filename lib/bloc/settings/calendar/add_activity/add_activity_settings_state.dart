part of 'add_activity_settings_cubit.dart';

class AddActivitySettingsState extends Equatable {
  final bool allowPassedStartTime,
      addRecurringActivity,
      showEndTime,
      showAlarm,
      showSilentAlarm,
      showNoAlarm;

  final AddTabEditViewSettingsState addTabEditViewSettingsState;
  final StepByStepSettingsState stepByStepSettingsState;
  final DefaultsTabSettingsState defaultsTabSettingsState;

  AddActivitySettingsState._({
    required this.allowPassedStartTime,
    required this.addRecurringActivity,
    required this.showEndTime,
    required this.showAlarm,
    required this.showSilentAlarm,
    required this.showNoAlarm,
    required this.addTabEditViewSettingsState,
    required this.stepByStepSettingsState,
    required this.defaultsTabSettingsState,
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
        addTabEditViewSettingsState:
            AddTabEditViewSettingsState.fromMemoplannerSettings(state),
        stepByStepSettingsState:
            StepByStepSettingsState.fromMemoplannerSettings(state),
        defaultsTabSettingsState:
            DefaultsTabSettingsState.fromMemoplannerSettings(state),
      );

  AddActivitySettingsState copyWith({
    bool? allowPassedStartTime,
    bool? addRecurringActivity,
    bool? showEndTime,
    bool? showAlarm,
    bool? showSilentAlarm,
    bool? showNoAlarm,
    AddTabEditViewSettingsState? addTabEditViewSettingsState,
    StepByStepSettingsState? stepByStepSettingsState,
    DefaultsTabSettingsState? defaultsTabSettingsState,
  }) =>
      AddActivitySettingsState._(
        allowPassedStartTime: allowPassedStartTime ?? this.allowPassedStartTime,
        addRecurringActivity: addRecurringActivity ?? this.addRecurringActivity,
        showEndTime: showEndTime ?? this.showEndTime,
        showAlarm: showAlarm ?? this.showAlarm,
        showSilentAlarm: showSilentAlarm ?? this.showSilentAlarm,
        showNoAlarm: showNoAlarm ?? this.showNoAlarm,
        addTabEditViewSettingsState:
            addTabEditViewSettingsState ?? this.addTabEditViewSettingsState,
        stepByStepSettingsState:
            stepByStepSettingsState ?? this.stepByStepSettingsState,
        defaultsTabSettingsState:
            defaultsTabSettingsState ?? this.defaultsTabSettingsState,
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
        ...addTabEditViewSettingsState.memoplannerSettingData,
        ...stepByStepSettingsState.memoplannerSettingData,
        ...defaultsTabSettingsState.memoplannerSettingData,
      ];

  @override
  List<Object> get props => [
        allowPassedStartTime,
        addRecurringActivity,
        showEndTime,
        showAlarm,
        showSilentAlarm,
        showNoAlarm,
        addTabEditViewSettingsState,
        stepByStepSettingsState,
        defaultsTabSettingsState,
      ];
}

class AddTabEditViewSettingsState extends Equatable {
  final NewActivityMode newActivityMode;
  final bool selectDate, selectType, showBasicActivities;

  AddTabEditViewSettingsState._({
    required this.newActivityMode,
    required this.selectDate,
    required this.selectType,
    required this.showBasicActivities,
  });

  factory AddTabEditViewSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      AddTabEditViewSettingsState._(
        newActivityMode: state.addActivityType,
        selectDate: state.activityDateEditable,
        selectType: state.activityTypeEditable,
        showBasicActivities: state.advancedActivityTemplate,
      );

  AddTabEditViewSettingsState copyWith({
    NewActivityMode? newActivityMode,
    bool? selectDate,
    bool? selectType,
    bool? showBasicActivities,
  }) =>
      AddTabEditViewSettingsState._(
        newActivityMode: newActivityMode ?? this.newActivityMode,
        selectDate: selectDate ?? this.selectDate,
        selectType: selectType ?? this.selectType,
        showBasicActivities: showBasicActivities ?? this.showBasicActivities,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: newActivityMode == NewActivityMode.editView,
          identifier: MemoplannerSettings.addActivityTypeAdvancedKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectDate,
          identifier: MemoplannerSettings.activityDateEditableKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectType,
          identifier: MemoplannerSettings.activityTypeEditableKey,
        ),
        MemoplannerSettingData.fromData(
          data: showBasicActivities,
          identifier: MemoplannerSettings.advancedActivityTemplateKey,
        ),
      ];

  @override
  List<Object> get props => [
        newActivityMode,
        selectDate,
        selectType,
        showBasicActivities,
      ];
}

class StepByStepSettingsState extends Equatable {
  final bool showBasicActivities,
      selectName,
      selectImage,
      setDate,
      selectType,
      selectCheckable,
      selectAvailableFor,
      selectDeleteAfter,
      selectAlarm,
      selectChecklist,
      selectNote,
      selectReminder;

  StepByStepSettingsState._({
    required this.showBasicActivities,
    required this.selectName,
    required this.selectImage,
    required this.setDate,
    required this.selectType,
    required this.selectCheckable,
    required this.selectAvailableFor,
    required this.selectDeleteAfter,
    required this.selectAlarm,
    required this.selectChecklist,
    required this.selectNote,
    required this.selectReminder,
  });

  factory StepByStepSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      StepByStepSettingsState._(
        showBasicActivities: state.wizardTemplateStep,
        selectAlarm: state.wizardAlarmStep,
        selectAvailableFor: state.wizardAvailabilityType,
        selectChecklist: state.wizardChecklistStep,
        selectDeleteAfter: state.wizardRemoveAfterStep,
        selectImage: state.wizardImageStep,
        selectName: state.wizardTitleStep,
        selectNote: state.wizardNotesStep,
        selectReminder: state.wizardRemindersStep,
        selectType: state.wizardTypeStep,
        selectCheckable: state.wizardCheckableStep,
        setDate: state.wizardDatePickerStep,
      );

  StepByStepSettingsState copyWith({
    bool? showBasicActivities,
    bool? selectName,
    bool? selectImage,
    bool? setDate,
    bool? selectType,
    bool? selectCheckable,
    bool? selectAvailableFor,
    bool? selectDeleteAfter,
    bool? selectAlarm,
    bool? selectChecklist,
    bool? selectNote,
    bool? selectReminder,
  }) =>
      StepByStepSettingsState._(
        showBasicActivities: showBasicActivities ?? this.showBasicActivities,
        selectName: selectName ?? this.selectName,
        selectImage: selectImage ?? this.selectImage,
        setDate: setDate ?? this.setDate,
        selectType: selectType ?? this.selectType,
        selectCheckable: selectCheckable ?? this.selectCheckable,
        selectAvailableFor: selectAvailableFor ?? this.selectAvailableFor,
        selectDeleteAfter: selectDeleteAfter ?? this.selectDeleteAfter,
        selectAlarm: selectAlarm ?? this.selectAlarm,
        selectChecklist: selectChecklist ?? this.selectChecklist,
        selectNote: selectNote ?? this.selectNote,
        selectReminder: selectReminder ?? this.selectReminder,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: showBasicActivities,
          identifier: MemoplannerSettings.wizardTemplateStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectName,
          identifier: MemoplannerSettings.wizardTitleStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectImage,
          identifier: MemoplannerSettings.wizardImageStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: setDate,
          identifier: MemoplannerSettings.wizardDatePickerStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectType,
          identifier: MemoplannerSettings.wizardTypeStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectCheckable,
          identifier: MemoplannerSettings.wizardCheckableStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectAvailableFor,
          identifier: MemoplannerSettings.wizardAvailabilityTypeKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectDeleteAfter,
          identifier: MemoplannerSettings.wizardRemoveAfterStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectAlarm,
          identifier: MemoplannerSettings.wizardAlarmStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectChecklist,
          identifier: MemoplannerSettings.wizardChecklistStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectNote,
          identifier: MemoplannerSettings.wizardNotesStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: selectReminder,
          identifier: MemoplannerSettings.wizardRemindersStepKey,
        ),
      ];

  @override
  List<Object> get props => [
        showBasicActivities,
        selectName,
        selectImage,
        setDate,
        selectType,
        selectCheckable,
        selectAvailableFor,
        selectDeleteAfter,
        selectAlarm,
        selectChecklist,
        selectNote,
        selectReminder,
      ];
}

class DefaultsTabSettingsState extends Equatable {
  final AlarmType alarmType;
  final bool alarmOnlyAtStartTime;

  DefaultsTabSettingsState._({
    required this.alarmType,
    required this.alarmOnlyAtStartTime,
  });

  factory DefaultsTabSettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) {
    final alarm = Alarm.fromInt(state.defaultAlarmTypeSetting);
    return DefaultsTabSettingsState._(
      alarmType: alarm.type,
      alarmOnlyAtStartTime: alarm.onlyStart,
    );
  }

  DefaultsTabSettingsState copyWith({
    AlarmType? alarmType,
    bool? alarmOnlyAtStartTime,
  }) =>
      DefaultsTabSettingsState._(
        alarmType: alarmType ?? this.alarmType,
        alarmOnlyAtStartTime: alarmOnlyAtStartTime ?? this.alarmOnlyAtStartTime,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: Alarm(type: alarmType, onlyStart: alarmOnlyAtStartTime).toInt,
          identifier: MemoplannerSettings.activityDefaultAlarmTypeKey,
        ),
      ];

  @override
  List<Object> get props => [
        alarmType,
        alarmOnlyAtStartTime,
      ];
}
