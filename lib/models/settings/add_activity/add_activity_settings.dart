import 'package:equatable/equatable.dart';
import 'package:seagull/models/all.dart';

class AddActivitySettings extends Equatable {
  final StepByStepSettings stepByStep;
  final EditActivitySettings editActivity;
  final GeneralAddActivitySettings general;
  final DefaultsAddActivitySettings defaults;

  const AddActivitySettings({
    this.stepByStep = const StepByStepSettings(),
    this.editActivity = const EditActivitySettings(),
    this.general = const GeneralAddActivitySettings(),
    this.defaults = const DefaultsAddActivitySettings(),
  });

  AddActivitySettings copyWith({
    StepByStepSettings? stepByStep,
    EditActivitySettings? editActivity,
    GeneralAddActivitySettings? general,
    DefaultsAddActivitySettings? defaults,
  }) =>
      AddActivitySettings(
        stepByStep: stepByStep ?? this.stepByStep,
        editActivity: editActivity ?? this.editActivity,
        general: general ?? this.general,
        defaults: defaults ?? this.defaults,
      );

  factory AddActivitySettings.fromSettingsMap(
          Map<String, MemoplannerSettingData> settings) =>
      AddActivitySettings(
        stepByStep: StepByStepSettings.fromSettingsMap(settings),
        editActivity: EditActivitySettings.fromSettingsMap(settings),
        general: GeneralAddActivitySettings.fromSettingsMap(settings),
        defaults: DefaultsAddActivitySettings.fromSettingsMap(settings),
      );

  List<MemoplannerSettingData> get memoplannerSettingData => [
        ...stepByStep.memoplannerSettingData,
        ...editActivity.memoplannerSettingData,
        ...general.memoplannerSettingData,
        ...defaults.memoplannerSettingData,
      ];

  @override
  List<Object> get props => [
        stepByStep,
        editActivity,
        general,
        defaults,
      ];
}
