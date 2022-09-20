import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'week_calendar_settings_state.dart';

class WeekCalendarSettingsCubit extends Cubit<WeekCalendarSettingsState> {
  final GenericCubit genericCubit;

  WeekCalendarSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericCubit,
  }) : super(WeekCalendarSettingsState.fromSettings(settingsState.settings.weekCalendar));

  void changeWeekCalendarSettings(WeekCalendarSettingsState newState) =>
      emit(newState);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
