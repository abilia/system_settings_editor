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

  InactivityCubit(
    this._calendarInactivityTime,
    this.ticker,
    this.settingsBloc,
  ) : super(ActivityDetected(ticker.time)) {
    _clockSubscription = ticker.minutes.listen(_ticking);
  }

  void _ticking(DateTime time) {
    final state = this.state;
    if (state is! _NotFinalState) return;
    final settings = settingsBloc.state;
    final activityTimeout = settings.activityTimeout;
    final calendarInactivityTime = _calendarInactivityTime > activityTimeout
        ? activityTimeout
        : _calendarInactivityTime;

    if (time
        .isAtSameMomentOrAfter(state.timeStamp.add(calendarInactivityTime))) {
      emit(CalendarInactivityThresholdReached(state.timeStamp));
    }
    if (time.isAtSameMomentOrAfter(state.timeStamp.add(activityTimeout))) {
      emit(
        HomeScreenInactivityThresholdReached(
          startView: settings.startView,
          showScreensaver: settings.useScreensaver,
        ),
      );
    }
  }

  void activityDetected([_]) => emit(ActivityDetected(ticker.time));

  @override
  Future<void> close() async {
    await super.close();
    await _clockSubscription.cancel();
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

class ActivityDetected extends _NotFinalState {
  const ActivityDetected(DateTime timeStamp) : super(timeStamp);
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
