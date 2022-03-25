part of 'add_activity_settings_cubit.dart';

class AddActivitySettingsState extends Equatable {
  final bool allowPassedStartTime,
      addRecurringActivity,
      showEndTime,
      showAlarm,
      showSilentAlarm,
      showNoAlarm;

  final AddTabEditViewSettingsState addTabEditViewSettingsState;
  final WizardStepsSettings stepByStepSettingsState;
  final Alarm defaultAlarm;

  const AddActivitySettingsState._({
    required this.allowPassedStartTime,
    required this.addRecurringActivity,
    required this.showEndTime,
    required this.showAlarm,
    required this.showSilentAlarm,
    required this.showNoAlarm,
    required this.addTabEditViewSettingsState,
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
        addTabEditViewSettingsState:
            AddTabEditViewSettingsState.fromMemoplannerSettings(state),
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
    AddTabEditViewSettingsState? addTabEditViewSettingsState,
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
        addTabEditViewSettingsState:
            addTabEditViewSettingsState ?? this.addTabEditViewSettingsState,
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
        ...addTabEditViewSettingsState.memoplannerSettingData,
        ...stepByStepSettingsState.memoplannerSettingData,
        defaultAlarm.memoplannerSettingData,
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
        defaultAlarm,
      ];
}

class AddTabEditViewSettingsState extends Equatable {
  final NewActivityMode newActivityMode;
  final bool selectDate, selectType, showBasicActivities;

  const AddTabEditViewSettingsState._({
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

extension StepByStepSettingsState on WizardStepsSettings {
  WizardStepsSettings copyWith({
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
      WizardStepsSettings(
        template: showBasicActivities ?? template,
        title: selectName ?? title,
        image: selectImage ?? image,
        datePicker: setDate ?? datePicker,
        type: selectType ?? type,
        checkable: selectCheckable ?? checkable,
        availability: selectAvailableFor ?? availability,
        removeAfter: selectDeleteAfter ?? removeAfter,
        alarm: selectAlarm ?? alarm,
        checklist: selectChecklist ?? checklist,
        notes: selectNote ?? notes,
        reminders: selectReminder ?? reminders,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        MemoplannerSettingData.fromData(
          data: template,
          identifier: WizardStepsSettings.wizardTemplateStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: title,
          identifier: WizardStepsSettings.wizardTitleStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: image,
          identifier: WizardStepsSettings.wizardImageStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: datePicker,
          identifier: WizardStepsSettings.wizardDatePickerStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: type,
          identifier: WizardStepsSettings.wizardTypeStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: checkable,
          identifier: WizardStepsSettings.wizardCheckableStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: availability,
          identifier: WizardStepsSettings.wizardAvailabilityTypeKey,
        ),
        MemoplannerSettingData.fromData(
          data: removeAfter,
          identifier: WizardStepsSettings.wizardRemoveAfterStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: alarm,
          identifier: WizardStepsSettings.wizardAlarmStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: checklist,
          identifier: WizardStepsSettings.wizardChecklistStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: notes,
          identifier: WizardStepsSettings.wizardNotesStepKey,
        ),
        MemoplannerSettingData.fromData(
          data: reminders,
          identifier: WizardStepsSettings.wizardRemindersStepKey,
        ),
      ];
}

extension on Alarm {
  MemoplannerSettingData get memoplannerSettingData =>
      MemoplannerSettingData.fromData(
        data: toInt,
        identifier: MemoplannerSettings.activityDefaultAlarmTypeKey,
      );
}
