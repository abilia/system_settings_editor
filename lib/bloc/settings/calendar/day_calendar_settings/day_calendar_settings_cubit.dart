import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'day_calendar_settings_state.dart';

class DayCalendarSettingsCubit extends Cubit<DayCalendarSettingsState> {
  final GenericCubit genericCubit;

  DayCalendarSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericCubit,
  }) : super(DayCalendarSettingsState.fromMemoplannerSettings(settingsState));

  void changeDayCalendarSettings(DayCalendarSettingsState newState) =>
      emit(newState);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
