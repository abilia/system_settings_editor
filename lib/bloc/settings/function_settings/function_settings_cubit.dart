import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'function_settings_state.dart';

class FunctionSettingsCubit extends Cubit<FunctionSettingsState> {
  final GenericCubit genericCubit;

  FunctionSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericCubit,
  }) : super(FunctionSettingsState.fromMemoplannerSettings(settingsState));

  void changeFunctionSettings(FunctionSettingsState newState) => emit(newState);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
