import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class NightMode extends Cubit<bool> {
  final DayPartCubit dayPart;
  final MemoplannerSettingsBloc settings;
  final DayPickerBloc picker;
  final TimepillarCubit timepillarCubit;
  NightMode({
    required this.dayPart,
    required this.settings,
    required this.picker,
    required this.timepillarCubit,
  }) : super(false) {
    dayPart.stream.listen((event) => _onChange());
    picker.stream.listen((event) => _onChange());
    settings.stream.listen((event) => _onChange());
    timepillarCubit.stream.listen((event) => _onChange());
  }

  void _onChange() {
    final isAgenda = settings.state.dayCalendar.viewOptions.calendarType ==
        DayCalendarType.list;
    final showNightCalendar = timepillarCubit.state.showNightCalendar;
    emit(
      dayPart.state.isNight &&
          picker.state.isToday &&
          (isAgenda || showNightCalendar),
    );
  }
}
