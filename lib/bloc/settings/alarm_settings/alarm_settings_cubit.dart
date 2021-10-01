import 'package:bloc/bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

part 'alarm_settings_state.dart';

class AlarmSettingsCubit extends Cubit<AlarmSettings> {
  final GenericBloc genericBloc;

  AlarmSettingsCubit({
    required AlarmSettings alarmSettings,
    required this.genericBloc,
  }) : super(alarmSettings);

  void changeAlarmSettings(AlarmSettings newState) => emit(newState);
  void save() => genericBloc.add(GenericUpdated(state.memoplannerSettingData));
}
