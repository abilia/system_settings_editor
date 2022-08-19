part of 'add_activity_settings_cubit.dart';

class AddActivitySettingsState extends Equatable {
  final GeneralAddActivitySettings generalSettings;
  final DefaultsAddActivitySettings defaultsSettings;
  final EditActivitySettings editActivitySettings;
  final StepByStepSettings stepByStepSettings;
  final NewActivityMode newActivityMode;

  const AddActivitySettingsState._({
    required this.generalSettings,
    required this.defaultsSettings,
    required this.editActivitySettings,
    required this.stepByStepSettings,
    required this.newActivityMode,
  });

  factory AddActivitySettingsState.fromMemoplannerSettings(
    MemoplannerSettingsState state,
  ) =>
      AddActivitySettingsState._(
        generalSettings: state.settings.addActivity.general,
        defaultsSettings: state.settings.addActivity.defaults,
        editActivitySettings: state.settings.addActivity.editActivity,
        stepByStepSettings: state.settings.addActivity.stepByStep,
        newActivityMode: state.addActivityType,
      );

  AddActivitySettingsState copyWith({
    GeneralAddActivitySettings? generalSettings,
    DefaultsAddActivitySettings? defaultsSettings,
    EditActivitySettings? editActivitySettings,
    StepByStepSettings? stepByStepSettings,
    NewActivityMode? newActivityMode,
  }) =>
      AddActivitySettingsState._(
        generalSettings: generalSettings ?? this.generalSettings,
        defaultsSettings: defaultsSettings ?? this.defaultsSettings,
        editActivitySettings: editActivitySettings ?? this.editActivitySettings,
        stepByStepSettings: stepByStepSettings ?? this.stepByStepSettings,
        newActivityMode: newActivityMode ?? this.newActivityMode,
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        ...generalSettings.memoplannerSettingData,
        ...defaultsSettings.memoplannerSettingData,
        ...editActivitySettings.memoplannerSettingData,
        ...stepByStepSettings.memoplannerSettingData,
        MemoplannerSettingData.fromData(
          data: newActivityMode == NewActivityMode.editView,
          identifier: MemoplannerSettings.addActivityTypeAdvancedKey,
        ),
      ];

  @override
  List<Object> get props => [
        generalSettings,
        defaultsSettings,
        editActivitySettings,
        stepByStepSettings,
        newActivityMode,
      ];
}
