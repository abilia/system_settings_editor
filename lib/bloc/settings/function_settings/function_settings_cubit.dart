import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class FunctionSettingsCubit extends Cubit<FunctionSettings> {
  final GenericCubit genericCubit;

  FunctionSettingsCubit({
    required FunctionSettings functionSettings,
    required this.genericCubit,
  }) : super(functionSettings);

  void changeFunctionSettings(FunctionSettings newState) => emit(newState);
  void changeDisplaySettings(DisplaySettings newState) =>
      emit(state.copyWith(display: newState));
  void changeScreensaverSettings(ScreensaverSettings newState) =>
      emit(state.copyWith(screensaver: newState));
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
