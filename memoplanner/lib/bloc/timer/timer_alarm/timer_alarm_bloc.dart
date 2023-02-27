import 'dart:async';
import 'dart:collection';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/logging/all.dart';

import 'package:memoplanner/models/all.dart';
import 'package:seagull_clock/ticker.dart';

part 'timer_alarm_state.dart';
part 'timer_alarm_event.dart';

class TimerAlarmBloc extends Bloc<TimerAlarmEvent, TimerAlarmState> {
  static const timerLifespan = Duration(hours: 24);
  final Ticker ticker;
  late final StreamSubscription _secondStreamSubscription;
  late final StreamSubscription _minuteStreamSubscription;
  late final StreamSubscription _timerSubscription;

  TimerAlarmBloc({
    required this.ticker,
    required TimerCubit timerCubit,
  }) : super(_timersToState(timerCubit.state.timers, ticker.time)) {
    _timerSubscription = timerCubit.stream
        .map((event) => event.timers)
        .listen((timers) => add(_TimersChanged(timers)));
    _secondStreamSubscription = ticker.seconds
        .where((time) =>
            state.ongoingQueue.isNotEmpty &&
            time.isAfter(state.ongoingQueue.first.end))
        .listen((_) => add(const _TimerAlarmFired()));
    _minuteStreamSubscription =
        ticker.minutes.listen((time) => add(_MinuteChanged(time)));
    on<TimerAlarmEvent>(_onEvent, transformer: sequential());
  }

  void _onEvent(TimerAlarmEvent event, Emitter emit) {
    if (event is _TimersChanged) {
      emit(_timersToState(event.timers, ticker.time));
    }
    if (event is _MinuteChanged) {
      emit(_timersToState(state.timers.map((e) => e.timer), event.time));
    }

    if (event is _TimerAlarmFired) {
      final first = state.ongoingQueue.removeFirst();
      emit(
        TimerAlarmState.sort(
          List.from(state.timers)
            ..remove(first)
            ..add(first.toPast()),
          TimerAlarm(first.timer),
        ),
      );
    }
  }

  static TimerAlarmState _timersToState(
    Iterable<AbiliaTimer> timers,
    DateTime time,
  ) {
    final deadline = time.subtract(timerLifespan);
    return TimerAlarmState.sort(
      timers
          .where((t) => t.startTime.isAfter(deadline))
          .map((e) => e.toOccasion(time)),
    );
  }

  @override
  Future<void> close() async {
    await _secondStreamSubscription.cancel();
    await _minuteStreamSubscription.cancel();
    await _timerSubscription.cancel();
    return super.close();
  }
}
