import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class AddActivitySettingsCubit extends Cubit<AddActivitySettings> {
  final GenericCubit genericCubit;

  AddActivitySettingsCubit({
    required AddActivitySettings addActivitySettings,
    required this.genericCubit,
  }) : super(addActivitySettings);

  void change(AddActivitySettings state) => emit(state);
  void addGeneralSettings(GeneralAddActivitySettings settings) =>
      change(state.copyWith(general: settings));
  void addDefaultsSettings(DefaultsAddActivitySettings settings) =>
      change(state.copyWith(defaults: settings));
  void newActivityMode(AddActivityMode? mode) =>
      change(state.copyWith(mode: mode));
  void stepByStepSetting(StepByStepSettings settings) =>
      change(state.copyWith(stepByStep: settings));
  void editSettings(EditActivitySettings settings) =>
      change(state.copyWith(editActivity: settings));
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
