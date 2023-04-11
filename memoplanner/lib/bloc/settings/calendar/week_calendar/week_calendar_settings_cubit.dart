import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class WeekCalendarSettingsCubit extends Cubit<WeekCalendarSettings> {
  final GenericCubit genericCubit;

  WeekCalendarSettingsCubit({
    required WeekCalendarSettings weekCalendarSettings,
    required this.genericCubit,
  }) : super(weekCalendarSettings);

  void changeWeekCalendarSettings(WeekCalendarSettings weekCalendarSettings) =>
      emit(weekCalendarSettings);
  Future<void> save() =>
      genericCubit.genericUpdated(state.memoplannerSettingData);
}
