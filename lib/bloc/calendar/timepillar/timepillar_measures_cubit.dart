import 'dart:async';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class TimepillarMeasuresCubit extends Cubit<TimepillarMeasures> {
  final TimepillarCubit? _timepillarCubit;
  final MemoplannerSettingBloc? _memoplannerSettingsBloc;
  StreamSubscription? _timepillarSubscription;
  StreamSubscription? _memoplannerSubscription;
  //Makes animated page transitions possible in DayCalendar
  TimepillarMeasures? previousState;

  TimepillarMeasuresCubit({
    required TimepillarCubit timepillarCubit,
    required MemoplannerSettingBloc memoplannerSettingsBloc,
  })  : _timepillarCubit = timepillarCubit,
        _memoplannerSettingsBloc = memoplannerSettingsBloc,
        super(TimepillarMeasures(timepillarCubit.state.interval,
            memoplannerSettingsBloc.state.timepillarZoom.zoomValue)) {
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
    final zoom = _memoplannerSettingsBloc?.state.timepillarZoom.zoomValue;
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
