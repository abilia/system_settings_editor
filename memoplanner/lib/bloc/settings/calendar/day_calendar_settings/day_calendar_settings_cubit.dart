import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class DayCalendarSettingsCubit extends Cubit<DayCalendarSettings> {
  final GenericCubit genericCubit;

  DayCalendarSettingsCubit({
    required DayCalendarSettings dayCalendarSettings,
    required this.genericCubit,
  }) : super(dayCalendarSettings);

  void changeSettings(DayCalendarSettings settings) => emit(settings);
  void save() => genericCubit.genericUpdated(state.memoplannerSettingData);
}
