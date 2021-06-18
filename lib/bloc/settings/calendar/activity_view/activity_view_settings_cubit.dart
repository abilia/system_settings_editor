// @dart=2.9

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'activity_view_settings_state.dart';

class ActivityViewSettingsCubit extends Cubit<ActivityViewSettingsState> {
  final GenericBloc genericBloc;

  ActivityViewSettingsCubit({
    MemoplannerSettingsState settingsState,
    this.genericBloc,
  }) : super(ActivityViewSettingsState.fromMemoplannerSettings(settingsState));

  void changeSettings(ActivityViewSettingsState newState) => emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
