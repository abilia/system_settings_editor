// @dart=2.9

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'alarm_settings_state.dart';

class AlarmSettingsCubit extends Cubit<AlarmSettingsState> {
  final GenericBloc genericBloc;

  AlarmSettingsCubit({
    MemoplannerSettingsState settingsState,
    this.genericBloc,
  }) : super(AlarmSettingsState.fromMemoplannerSettings(settingsState));

  void changeAlarmSettings(AlarmSettingsState newState) => emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
