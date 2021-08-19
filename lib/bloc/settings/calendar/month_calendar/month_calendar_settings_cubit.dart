import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'month_calendar_settings_state.dart';

class MonthCalendarSettingsCubit extends Cubit<MonthCalendarSettingsState> {
  final GenericBloc genericBloc;

  MonthCalendarSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericBloc,
  }) : super(MonthCalendarSettingsState.fromMemoplannerSettings(settingsState));

  void changeMonthCalendarSettings(MonthCalendarSettingsState newState) =>
      emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
