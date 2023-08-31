import 'dart:async';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

class DayPartCubit extends Cubit<DayPart> {
  DayPartCubit(
    this.settingsBloc,
    this.clockCubit,
  ) : super(
          clockCubit.state.dayPart(settingsBloc.state.calendar.dayParts),
        ) {
    _clockSubscription = clockCubit.stream.listen(_conditionChanged);
    _dayPartsSubscription = settingsBloc.stream
        .map((state) => state.calendar.dayParts)
        .listen(_conditionChanged);
  }
  final ClockCubit clockCubit;
  final MemoplannerSettingsBloc settingsBloc;
  late final StreamSubscription _clockSubscription, _dayPartsSubscription;

  void _conditionChanged([condition]) {
    final now = condition is DateTime ? condition : clockCubit.state;
    final dayParts = condition is DayParts
        ? condition
        : settingsBloc.state.calendar.dayParts;
    emit(now.dayPart(dayParts));
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    await _dayPartsSubscription.cancel();
    await super.close();
  }
}
