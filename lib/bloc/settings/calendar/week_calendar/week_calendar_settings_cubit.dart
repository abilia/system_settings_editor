import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'week_calendar_settings_state.dart';

class WeekCalendarSettingsCubit extends Cubit<WeekCalendarSettingsState> {
  final GenericBloc genericBloc;

  WeekCalendarSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericBloc,
  }) : super(WeekCalendarSettingsState.fromMemoplannerSettings(settingsState));

  void changeWeekCalendarSettings(WeekCalendarSettingsState newState) =>
      emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
