import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'general_calendar_settings_state.dart';

class GeneralCalendarSettingsCubit extends Cubit<GeneralCalendarSettingsState> {
  final GenericBloc genericBloc;

  GeneralCalendarSettingsCubit({
    MemoplannerSettingsState settingsState,
    this.genericBloc,
  }) : super(GeneralCalendarSettingsState.fromMemoplannerSettings(
            settingsState));

  void changeFunctionSettings(GeneralCalendarSettingsState newState) =>
      emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
