import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final TimerDb timerDb;

  TimerCubit({required this.timerDb}) : super(TimerState());

  Future<void> addTimer(AbiliaTimer timer) async {
    await timerDb.insert(timer);
    emit(TimerState(timers: [...state.timers, timer]));
  }

  Future<void> deleteTimer(AbiliaTimer timer) async {
    int result = await timerDb.delete(timer);
    if (result > 0) {
      emit(TimerState(timers: List.of(state.timers)..remove(timer)));
    }
  }

  Future<void> loadTimers() async {
    final timers = await timerDb.getAllTimers();
    emit(TimerState(timers: timers));
  }

  Future<void> pauseTimer(AbiliaTimer timer, DateTime time) async {
    AbiliaTimer newTimer =
        timer.copyWith(paused: true, pausedAt: timer.endTime.difference(time));
    if (await timerDb.update(newTimer) > 0) loadTimers();
  }

  Future<void> startTimer(AbiliaTimer timer, DateTime time) async {
    AbiliaTimer newTimer = timer.copyWith(
        startTime: time,
        duration: Duration(milliseconds: timer.pausedAt.inMilliseconds),
        paused: false);
    if (await timerDb.update(newTimer) > 0) loadTimers();
  }
}
