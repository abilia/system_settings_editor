import 'package:equatable/equatable.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'activity_view_settings_state.dart';

class ActivityViewSettingsCubit extends Cubit<ActivityViewSettingsState> {
  final GenericCubit genericCubit;

  ActivityViewSettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericCubit,
  }) : super(ActivityViewSettingsState.fromSettings(
            settingsState.settings.activityView));

  void changeSettings(ActivityViewSettingsState newState) => emit(newState);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
