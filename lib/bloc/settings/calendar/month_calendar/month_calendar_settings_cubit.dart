import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'month_calendar_settings_state.dart';

class MonthCalendarSettingsCubit extends Cubit<MonthCalendarSettingsState> {
  final GenericCubit genericCubit;

  MonthCalendarSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericCubit,
  }) : super(MonthCalendarSettingsState.fromMemoplannerSettings(settingsState));

  void changeMonthCalendarSettings(MonthCalendarSettingsState newState) =>
      emit(newState);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
