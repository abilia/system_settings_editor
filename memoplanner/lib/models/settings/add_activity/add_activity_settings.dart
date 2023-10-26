import 'package:equatable/equatable.dart';
import 'package:memoplanner/models/all.dart';

class AddActivitySettings extends Equatable {
  static const addActivityTypeAdvancedKey = 'add_activity_type_advanced';

  final StepByStepSettings stepByStep;
  final EditActivitySettings editActivity;
  final GeneralAddActivitySettings general;
  final DefaultsAddActivitySettings defaults;
  final AddActivityMode mode;

  bool get basicActivityOption =>
      (mode == AddActivityMode.editView && editActivity.template) ||
      (mode == AddActivityMode.stepByStep && stepByStep.template);

  bool get newActivityOption =>
      (mode == AddActivityMode.editView &&
          (editActivity.title || editActivity.image)) ||
      (mode == AddActivityMode.stepByStep &&
          (stepByStep.title || stepByStep.image));

  const AddActivitySettings({
    this.stepByStep = const StepByStepSettings(),
    this.editActivity = const EditActivitySettings(),
    this.general = const GeneralAddActivitySettings(),
    this.defaults = const DefaultsAddActivitySettings(),
    this.mode = AddActivityMode.editView,
  });

  AddActivitySettings copyWith({
    StepByStepSettings? stepByStep,
    EditActivitySettings? editActivity,
    GeneralAddActivitySettings? general,
    DefaultsAddActivitySettings? defaults,
    AddActivityMode? mode,
  }) =>
      AddActivitySettings(
        stepByStep: stepByStep ?? this.stepByStep,
        editActivity: editActivity ?? this.editActivity,
        general: general ?? this.general,
        defaults: defaults ?? this.defaults,
        mode: mode ?? this.mode,
      );

  factory AddActivitySettings.fromSettingsMap(
          Map<String, GenericSettingData> settings) =>
      AddActivitySettings(
        stepByStep: StepByStepSettings.fromSettingsMap(settings),
        editActivity: EditActivitySettings.fromSettingsMap(settings),
        general: GeneralAddActivitySettings.fromSettingsMap(settings),
        defaults: DefaultsAddActivitySettings.fromSettingsMap(settings),
        mode: settings.getBool(addActivityTypeAdvancedKey)
            ? AddActivityMode.editView
            : AddActivityMode.stepByStep,
      );

  List<GenericSettingData> get memoplannerSettingData => [
        ...stepByStep.memoplannerSettingData,
        ...editActivity.memoplannerSettingData,
        ...general.memoplannerSettingData,
        ...defaults.memoplannerSettingData,
        MemoplannerSettingData(
          data: mode == AddActivityMode.editView,
          identifier: addActivityTypeAdvancedKey,
        ),
      ];

  @override
  List<Object> get props => [
        stepByStep,
        editActivity,
        general,
        defaults,
        mode,
      ];
}
