import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'add_activity_settings_state.dart';

class AddActivitySettingsCubit extends Cubit<AddActivitySettingsState> {
  final GenericCubit genericCubit;

  AddActivitySettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericCubit,
  }) : super(AddActivitySettingsState.fromMemoplannerSettings(settingsState));

  void change(AddActivitySettingsState state) => emit(state);
  void addGeneralSettings(GeneralAddActivitySettings settings) =>
      change(state.copyWith(generalSettings: settings));
  void addDefaultsSettings(DefaultsAddActivitySettings settings) =>
      change(state.copyWith(defaultsSettings: settings));
  void newActivityMode(NewActivityMode? mode) =>
      change(state.copyWith(newActivityMode: mode));
  void stepByStepSetting(StepByStepSettings settings) =>
      change(state.copyWith(stepByStepSettings: settings));
  void editSettings(EditActivitySettings settings) =>
      change(state.copyWith(editActivitySettings: settings));
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
