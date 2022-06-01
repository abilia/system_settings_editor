import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class InactivityCubit extends Cubit<InactivityState> {
  final Duration _calendarInactivityTime;
  final Ticker ticker;
  final MemoplannerSettingBloc settingsBloc;

  late StreamSubscription<DateTime> _clockSubscription;
  late StreamSubscription<Touch> _activitySubscription;

  InactivityCubit(
    this._calendarInactivityTime,
    this.ticker,
    this.settingsBloc,
    Stream<Touch> activityDetectedStream,
  ) : super(UserTouch(ticker.time)) {
    _clockSubscription = ticker.minutes.listen(_ticking);
    _activitySubscription = activityDetectedStream.listen(
      (state) => emit(UserTouch(ticker.time)),
    );
  }

  void _ticking(DateTime time) {
    final state = this.state;
    if (state is! _NotFinalState) return;
    final settings = settingsBloc.state;
    final activityTimeout = settings.activityTimeout;
    final hasTimeout = activityTimeout > Duration.zero;
    final calendarInactivityTime =
        hasTimeout && _calendarInactivityTime > activityTimeout
            ? activityTimeout
            : _calendarInactivityTime;

    if (time
        .isAtSameMomentOrAfter(state.timeStamp.add(calendarInactivityTime))) {
      emit(CalendarInactivityThresholdReached(state.timeStamp));
    }
    if (hasTimeout &&
        time.isAtSameMomentOrAfter(state.timeStamp.add(activityTimeout))) {
      emit(
        HomeScreenInactivityThresholdReached(
          startView: settings.startView,
          showScreensaver: settings.useScreensaver,
        ),
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

class UserTouch extends _NotFinalState {
  const UserTouch(DateTime timeStamp) : super(timeStamp);
}

class CalendarInactivityThresholdReached extends _NotFinalState {
  const CalendarInactivityThresholdReached(DateTime timeStamp)
      : super(timeStamp);
}

class HomeScreenInactivityThresholdReached extends InactivityState {
  const HomeScreenInactivityThresholdReached({
    required this.startView,
    required this.showScreensaver,
  });

  final StartView startView;
  final bool showScreensaver;

  bool get screensaverOrPhotoAlbum =>
      showScreensaver || startView == StartView.photoAlbum;

  @override
  List<Object?> get props => [startView, showScreensaver];
}
