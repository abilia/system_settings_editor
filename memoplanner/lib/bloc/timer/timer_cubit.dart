import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final TimerDb timerDb;
  final Ticker ticker;
  final SeagullAnalytics analytics;

  TimerCubit({
    required this.timerDb,
    required this.ticker,
    required this.analytics,
  }) : super(TimerState());

  Future<void> addTimer(
    AbiliaTimer timer,
    EditTimerMetaData metaData,
  ) async {
    await timerDb.insert(timer);
    emit(TimerState(timers: [...state.timers, timer]));
    analytics.trackEvent(AnalyticsEvents.timerStarted, properties: {
      'From Template': metaData.fromTemplate,
      'Duration': timer.duration.inMinutes,
      'Image': timer.hasImage,
      'Title Changed': metaData.titleChanged,
      'Set Type': metaData.timerSetType.name,
    });
  }

  Future<void> deleteTimer(AbiliaTimer timer) async {
    final result = await timerDb.delete(timer);
    if (result > 0) {
      analytics.trackEvent(AnalyticsEvents.timerDeleted);
      emit(TimerState(timers: List.of(state.timers)..remove(timer)));
    }
  }

  Future<void> loadTimers() async {
    final timers = await timerDb.getAllTimers();
    emit(TimerState(timers: timers));
  }
}
