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

  void changeAddActivitySettings(AddActivitySettingsState newState) =>
      emit(newState);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
