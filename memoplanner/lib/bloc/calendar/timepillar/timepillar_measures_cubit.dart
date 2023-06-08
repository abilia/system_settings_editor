import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class TimepillarMeasuresCubit extends Cubit<TimepillarMeasures> {
  final TimepillarCubit? _timepillarCubit;
  final DayCalendarViewCubit? _dayCalendarViewCubit;
  StreamSubscription? _timepillarSubscription;
  StreamSubscription? _dayCalendarViewSubscription;
  // Makes animated page transitions possible in DayCalendar
  late TimepillarMeasures previousState = state;

  TimepillarMeasuresCubit({
    required TimepillarCubit timepillarCubit,
    required DayCalendarViewCubit dayCalendarViewCubit,
  })  : _timepillarCubit = timepillarCubit,
        _dayCalendarViewCubit = dayCalendarViewCubit,
        super(TimepillarMeasures(
          timepillarCubit.state.interval,
          dayCalendarViewCubit.state.timepillarZoom.zoomValue,
        )) {
    _timepillarSubscription = timepillarCubit.stream.listen((state) {
      _onConditionsChanged();
    });
    _dayCalendarViewSubscription = dayCalendarViewCubit.stream.listen((state) {
      _onConditionsChanged();
    });
  }

  TimepillarMeasuresCubit.fixed({
    required TimepillarMeasures state,
  })  : _timepillarCubit = null,
        _dayCalendarViewCubit = null,
        super(state);

  void _onConditionsChanged() {
    final interval = _timepillarCubit?.state.interval;
    final zoom = _dayCalendarViewCubit?.state.timepillarZoom.zoomValue;
    if (interval != null && zoom != null) {
      previousState = state;
      emit(TimepillarMeasures(interval, zoom));
    }
  }

  @override
  Future<void> close() async {
    await _timepillarSubscription?.cancel();
    await _dayCalendarViewSubscription?.cancel();
    return super.close();
  }
}
