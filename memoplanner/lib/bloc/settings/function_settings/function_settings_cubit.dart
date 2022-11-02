import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class FunctionSettingsCubit extends Cubit<FunctionsSettings> {
  final GenericCubit genericCubit;

  FunctionSettingsCubit({
    required FunctionsSettings functionSettings,
    required this.genericCubit,
  }) : super(functionSettings);

  void changeFunctionSettings(FunctionsSettings newState) => emit(newState);
  void changeDisplaySettings(DisplaySettings newState) =>
      emit(state.copyWith(display: newState));
  void changeTimeoutSettings(TimeoutSettings newState) =>
      emit(state.copyWith(timeout: newState));
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
