import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class DayCalendarSettingsCubit extends Cubit<DayCalendarSettings> {
  final GenericCubit genericCubit;

  DayCalendarSettingsCubit({
    required DayCalendarSettings dayCalendarSettings,
    required this.genericCubit,
  }) : super(dayCalendarSettings);

  void changeSettings(DayCalendarSettings settings) => emit(settings);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
