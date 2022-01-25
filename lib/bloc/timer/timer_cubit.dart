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
}
