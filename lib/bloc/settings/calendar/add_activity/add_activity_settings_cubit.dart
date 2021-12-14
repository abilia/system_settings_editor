import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'add_activity_settings_state.dart';

class AddActivitySettingsCubit extends Cubit<AddActivitySettingsState> {
  final GenericBloc genericBloc;

  AddActivitySettingsCubit({
    required MemoplannerSettingsState settingsState,
    required this.genericBloc,
  }) : super(AddActivitySettingsState.fromMemoplannerSettings(settingsState));

  void changeAddActivitySettings(AddActivitySettingsState newState) =>
      emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
