import 'dart:async';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class DayPartCubit extends Cubit<DayPart> {
  DayPartCubit(
    this.settingsBloc,
    this.clockBloc,
  ) : super(
          clockBloc.state.dayPart(settingsBloc.state.calendar.dayParts),
        ) {
    _clockSubscription = clockBloc.stream.listen(_conditionChanged);
    _daypartsSubscription = settingsBloc.stream
        .map((state) => state.calendar.dayParts)
        .listen(_conditionChanged);
  }
  final ClockBloc clockBloc;
  final MemoplannerSettingsBloc settingsBloc;
  late final StreamSubscription _clockSubscription, _daypartsSubscription;

  void _conditionChanged([condition]) {
    final now = condition is DateTime ? condition : clockBloc.state;
    final dayParts = condition is DayParts
        ? condition
        : settingsBloc.state.calendar.dayParts;
    emit(now.dayPart(dayParts));
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    await _daypartsSubscription.cancel();
    await super.close();
  }
}
