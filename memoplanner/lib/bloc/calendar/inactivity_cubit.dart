import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:rxdart/rxdart.dart';

const _timeToReturnToToday = Duration(minutes: 5);

class InactivityCubit extends Cubit<InactivityState> {
  final Ticker ticker;
  final MemoplannerSettingsBloc settingsBloc;
  final DayPartCubit dayPartCubit;

  final Duration clockDelay;

  late StreamSubscription<DateTime> _clockSubscription;
  late StreamSubscription _activitySubscription;

  InactivityCubit(
    this.ticker,
    this.settingsBloc,
    this.dayPartCubit,
    Stream<Touch> activityDetectedStream,
    Stream<NotificationAlarm?> alarm,
    Stream<TimerAlarmState> timers, {
    required this.clockDelay,
  }) : super(SomethingHappened(ticker.time)) {
    _clockSubscription = MergeStream(
      [
        ticker.minutes.delay(clockDelay),
        // Listen to changes from evening to night
        // Since DayPartCubit has not had time to update its state for the new
        // minute
        // Otherwise the screensaver won't start at exactly Night Start
        dayPartCubit.stream
            .where(
              (state) =>
                  state.isNight &&
                  settingsBloc
                      .state.functions.timeout.screensaverOnlyDuringNight,
            )
            .map((_) => ticker.time),
      ],
    ).listen(_ticking);

    _activitySubscription = MergeStream(
      [
        activityDetectedStream.map((_) => ticker.time),
        dayPartCubit.stream
            .where(
              (state) =>
                  state.isMorning &&
                  settingsBloc
                      .state.functions.timeout.screensaverOnlyDuringNight,
            )
            .map((_) => ticker.time),
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
    final timeout = settingsBloc.state.functions.timeout;
    final realTimeToReturnToToday =
        timeout.hasDuration && _timeToReturnToToday > timeout.duration
            ? timeout.duration
            : _timeToReturnToToday;

    final returnToTodayThresholdNotReached =
        time.isBefore(state.timeStamp.add(realTimeToReturnToToday));
    if (returnToTodayThresholdNotReached) {
      return;
    }

    if (!timeout.hasDuration) {
      return emit(const ReturnToTodayFinalState());
    }

    // from here Timeout is set
    final timeoutThresholdNotReached =
        time.isBefore(state.timeStamp.add(timeout.duration));
    if (timeoutThresholdNotReached) {
      return emit(ReturnToTodayThresholdReached(state.timeStamp));
    }

    if (!timeout.screensaver) {
      return emit(const HomeScreenFinalState());
    }

    // from here screensaver is set
    final activateScreensaver =
        !timeout.screensaverOnlyDuringNight || dayPartCubit.state.isNight;
    if (activateScreensaver) {
      return emit(const ScreensaverState());
    }

    return emit(HomeScreenThresholdReached(state.timeStamp));
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    await _activitySubscription.cancel();
    await super.close();
  }
}

abstract class ReturnToTodayState {}

abstract class HomeScreenState implements ReturnToTodayState {}

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

class ReturnToTodayThresholdReached extends _NotFinalState
    implements ReturnToTodayState {
  const ReturnToTodayThresholdReached(DateTime timeStamp) : super(timeStamp);
}

class HomeScreenThresholdReached extends ReturnToTodayThresholdReached
    implements HomeScreenState {
  const HomeScreenThresholdReached(DateTime timeStamp) : super(timeStamp);
}

// Final states
class ReturnToTodayFinalState extends InactivityState
    implements ReturnToTodayState {
  const ReturnToTodayFinalState() : super();
  @override
  List<Object> get props => [];
}

class HomeScreenFinalState extends ReturnToTodayFinalState
    implements HomeScreenState {
  const HomeScreenFinalState();
  @override
  List<Object> get props => [];
}

class ScreensaverState extends HomeScreenFinalState implements HomeScreenState {
  const ScreensaverState();
  @override
  List<Object> get props => [];
}
