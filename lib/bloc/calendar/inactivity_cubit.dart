import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class InactivityCubit extends Cubit<InactivityState> {
  final Duration _calendarInactivityTime;
  final Ticker ticker;
  final MemoplannerSettingBloc settingsBloc;

  late StreamSubscription<DateTime> _clockSubscription;
  late StreamSubscription _activitySubscription;

  InactivityCubit(
    this._calendarInactivityTime,
    this.ticker,
    this.settingsBloc,
    Stream<Touch> activityDetectedStream,
    Stream<NotificationAlarm?> alarm,
    Stream<TimerAlarmState> timers,
  ) : super(SomethingHappened(ticker.time)) {
    _clockSubscription = ticker.minutes.listen(_ticking);
    _activitySubscription = MergeStream(
      [
        activityDetectedStream.map((_) => ticker.time),
        MergeStream(
          [
            alarm,
            timers.map((event) => event.firedAlarm),
          ],
        ).whereType<NotificationAlarm>().map((event) => event.notificationTime),
      ],
    ).map(SomethingHappened.new).listen(emit);
  }

  void _ticking(DateTime time) {
    final state = this.state;
    if (state is! _NotFinalState) return;
    final screensaver = settingsBloc.state.settings.functions.screensaver;
    final calendarInactivityTime = screensaver.hasDuration &&
            _calendarInactivityTime > screensaver.duration
        ? screensaver.duration
        : _calendarInactivityTime;

    if (time
        .isAtSameMomentOrAfter(state.timeStamp.add(calendarInactivityTime))) {
      emit(CalendarInactivityThresholdReached(state.timeStamp));
    }
    if (screensaver.hasDuration &&
        time.isAtSameMomentOrAfter(state.timeStamp.add(screensaver.duration))) {
      emit(
        const HomeScreenInactivityThresholdReached(),
      );
    }
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    await _activitySubscription.cancel();
    await super.close();
  }
}

abstract class InactivityState extends Equatable {
  const InactivityState();
}

abstract class _NotFinalState extends InactivityState {
  final DateTime timeStamp;

  const _NotFinalState(this.timeStamp);

  @override
  List<Object> get props => [timeStamp];
}

class SomethingHappened extends _NotFinalState {
  const SomethingHappened(DateTime timeStamp) : super(timeStamp);
}

class CalendarInactivityThresholdReached extends _NotFinalState {
  const CalendarInactivityThresholdReached(DateTime timeStamp)
      : super(timeStamp);
}

class HomeScreenInactivityThresholdReached extends InactivityState {
  const HomeScreenInactivityThresholdReached();

  @override
  List<Object?> get props => [];
}
