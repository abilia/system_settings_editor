import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';

part 'timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  final TimerDb timerDb;
  final Ticker ticker;
  final SeagullAnalytics seagullAnalytics;

  TimerCubit({
    required this.timerDb,
    required this.ticker,
    required this.seagullAnalytics,
  }) : super(TimerState());

  Future<void> addTimer(
    AbiliaTimer timer,
    EditTimerMetaData metaData,
  ) async {
    await timerDb.insert(timer);
    emit(TimerState(timers: [...state.timers, timer]));
    seagullAnalytics.track('Timer started', properties: {
      'fromTemplate': metaData.fromTemplate,
      'duration': timer.duration.inMinutes,
      'image': timer.hasImage,
      'titleChanged': metaData.titleChanged,
      'timerSetType': metaData.timerSetType.name,
    });
  }

  Future<void> deleteTimer(AbiliaTimer timer) async {
    final result = await timerDb.delete(timer);
    if (result > 0) {
      seagullAnalytics.track('Timer deleted');
      emit(TimerState(timers: List.of(state.timers)..remove(timer)));
    }
  }

  Future<void> loadTimers() async {
    final timers = await timerDb.getAllTimers();
    emit(TimerState(timers: timers));
  }
}
