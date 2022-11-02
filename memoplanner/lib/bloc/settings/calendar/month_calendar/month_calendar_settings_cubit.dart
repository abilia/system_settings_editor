import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class MonthCalendarSettingsCubit extends Cubit<MonthCalendarSettings> {
  final GenericCubit genericCubit;

  MonthCalendarSettingsCubit({
    required MonthCalendarSettings monthCalendarSettings,
    required this.genericCubit,
  }) : super(monthCalendarSettings);

  void changeMonthCalendarSettings(MonthCalendarSettings settings) =>
      emit(settings);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
