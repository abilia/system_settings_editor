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

  void change(AddActivitySettingsState newState) => emit(newState);
  void addActivitySetting(AddActivitySettings settings) =>
      change(state.copyWith(addActivitySetting: settings));
  void newActivityMode(NewActivityMode? mode) =>
      change(state.copyWith(newActivityMode: mode));
  void stepByStepSetting(StepByStepSettings setting) =>
      change(state.copyWith(stepByStepSetting: setting));
  void editSettings(EditActivitySettings setting) =>
      change(state.copyWith(editActivitySetting: setting));
  void defaultAlarmType(AlarmType? alarmType) => change(state.copyWith(
      defaultAlarm: state.defaultAlarm.copyWith(type: alarmType)));
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
