import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'function_settings_state.dart';

class FunctionSettingsCubit extends Cubit<FunctionSettingsState> {
  final GenericBloc genericBloc;

  FunctionSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericBloc,
  }) : super(FunctionSettingsState.fromMemoplannerSettings(settingsState));

  void changeFunctionSettings(FunctionSettingsState newState) => emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
