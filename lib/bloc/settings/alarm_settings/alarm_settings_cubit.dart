import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class AlarmSettingsCubit extends Cubit<AlarmSettings> {
  final GenericCubit genericCubit;

  AlarmSettingsCubit({
    required AlarmSettings alarmSettings,
    required this.genericCubit,
  }) : super(alarmSettings);

  void changeAlarmSettings(AlarmSettings newState) => emit(newState);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
