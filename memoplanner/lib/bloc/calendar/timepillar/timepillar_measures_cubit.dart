import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

class TimepillarMeasuresCubit extends Cubit<TimepillarMeasures> {
  final TimepillarCubit? _timepillarCubit;
  final MemoplannerSettingsBloc? _memoplannerSettingsBloc;
  StreamSubscription? _timepillarSubscription;
  StreamSubscription? _memoplannerSubscription;
  // Makes animated page transitions possible in DayCalendar
  late TimepillarMeasures previousState = state;

  TimepillarMeasuresCubit({
    required TimepillarCubit timepillarCubit,
    required MemoplannerSettingsBloc memoplannerSettingsBloc,
  })  : _timepillarCubit = timepillarCubit,
        _memoplannerSettingsBloc = memoplannerSettingsBloc,
        super(TimepillarMeasures(
            timepillarCubit.state.interval,
            memoplannerSettingsBloc
                .state.dayCalendar.viewOptions.timepillarZoom.zoomValue)) {
    _timepillarSubscription = timepillarCubit.stream.listen((state) {
      _onConditionsChanged();
    });
    _memoplannerSubscription = memoplannerSettingsBloc.stream.listen((state) {
      _onConditionsChanged();
    });
  }

  TimepillarMeasuresCubit.fixed({
    required TimepillarMeasures state,
  })  : _timepillarCubit = null,
        _memoplannerSettingsBloc = null,
        super(state);

  void _onConditionsChanged() {
    final interval = _timepillarCubit?.state.interval;
    final zoom = _memoplannerSettingsBloc
        ?.state.dayCalendar.viewOptions.timepillarZoom.zoomValue;
    if (interval != null && zoom != null) {
      previousState = state;
      emit(TimepillarMeasures(interval, zoom));
    }
  }

  @override
  Future<void> close() async {
    await _timepillarSubscription?.cancel();
    await _memoplannerSubscription?.cancel();
    return super.close();
  }
}
