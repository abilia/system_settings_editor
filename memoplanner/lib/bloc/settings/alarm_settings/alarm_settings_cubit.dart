import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class AlarmSettingsCubit extends Cubit<AlarmSettings> {
  final GenericCubit genericCubit;

  AlarmSettingsCubit({
    required AlarmSettings alarmSettings,
    required this.genericCubit,
  }) : super(alarmSettings);

  void changeAlarmSettings(AlarmSettings newState) => emit(newState);
  Future<void> save() =>
      genericCubit.genericUpdated(state.memoplannerSettingData);
}
