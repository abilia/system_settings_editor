import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final TimerDb timerDb;
  final Ticker ticker;

  TimerCubit({
    required this.timerDb,
    required this.ticker,
  }) : super(TimerState());

  Future<void> addTimer(AbiliaTimer timer) async {
    await timerDb.insert(timer);
    emit(TimerState(timers: [...state.timers, timer]));
  }

  Future<void> deleteTimer(AbiliaTimer timer) async {
    final result = await timerDb.delete(timer);
    if (result > 0) {
      emit(TimerState(timers: List.of(state.timers)..remove(timer)));
    }
  }

  Future<void> loadTimers() async {
    final timers = await timerDb.getAllTimers();
    emit(TimerState(timers: timers));
  }

  Future<void> pauseTimer(AbiliaTimer timer) =>
      _update(timer.pause(ticker.time));

  Future<void> startTimer(AbiliaTimer timer) =>
      _update(timer.resume(ticker.time));

  Future<void> _update(AbiliaTimer timer) async {
    if (await timerDb.update(timer) > 0) {
      emit(
        TimerState(
          timers: List.of(state.timers)
            ..removeWhere((t) => t.id == timer.id)
            ..add(timer),
        ),
      );
    }
  }
}
