import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

part 'day_calendar_settings_state.dart';

class DayCalendarSettingsCubit extends Cubit<DayCalendarSettingsState> {
  final GenericBloc genericBloc;

  DayCalendarSettingsCubit({
    MemoplannerSettingsState settingsState,
    this.genericBloc,
  }) : super(DayCalendarSettingsState.fromMemoplannerSettings(settingsState));

  void changeDayCalendarSettings(DayCalendarSettingsState newState) =>
      emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
