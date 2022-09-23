import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class WeekCalendarSettingsCubit extends Cubit<WeekCalendarSettings> {
  final GenericCubit genericCubit;

  WeekCalendarSettingsCubit({
    required WeekCalendarSettings weekCalendarSettings,
    required this.genericCubit,
  }) : super(weekCalendarSettings);

  void changeWeekCalendarSettings(WeekCalendarSettings weekCalendarSettings) =>
      emit(weekCalendarSettings);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
