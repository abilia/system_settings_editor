import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final TimerDb timerDb;
  final SeagullAnalytics analytics;

  TimerCubit({
    required this.timerDb,
    required this.analytics,
  }) : super(TimerState());

  Future<void> addTimer(AbiliaTimer timer) async {
    await timerDb.insert(timer);
    if (isClosed) return;
    emit(TimerState(timers: [...state.timers, timer]));
  }

  Future<void> deleteTimer(AbiliaTimer timer) async {
    final result = await timerDb.delete(timer);
    if (result > 0 && !isClosed) {
      analytics.trackEvent(AnalyticsEvents.timerDeleted);
      emit(TimerState(timers: List.of(state.timers)..remove(timer)));
    }
  }

  Future<void> loadTimers() async {
    final timers = await timerDb.getAllTimers();
    if (isClosed) return;
    emit(TimerState(timers: timers));
  }
}
