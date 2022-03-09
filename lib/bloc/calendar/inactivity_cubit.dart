import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

class InactivityCubit extends Cubit<InactivityState> {
  final Duration _calendarInactivityTime;
  final ClockBloc clockBloc;
  final MemoplannerSettingBloc settingsBloc;

  late StreamSubscription<DateTime> _clockSubscription;

  InactivityCubit(
    this._calendarInactivityTime,
    this.clockBloc,
    this.settingsBloc,
  ) : super(ActivityDetected(clockBloc.state)) {
    _clockSubscription = clockBloc.stream.listen(_ticking);
  }

  void _ticking(DateTime time) {
    final state = this.state;
    if (state is! ActivityDetected) return;
    final settings = settingsBloc.state;
    final activityTimeout = Duration(milliseconds: settings.activityTimeout);
    final calendarInactivityTime = _calendarInactivityTime > activityTimeout
        ? activityTimeout
        : _calendarInactivityTime;

    if (time.isAfter(state.timeStamp.add(calendarInactivityTime))) {
      emit(const CalendarInactivityThresholdReached());
    }
    if (time.isAfter(state.timeStamp.add(activityTimeout))) {
      emit(
        HomeScreenInactivityThresholdReached(
          startView: settings.startView,
          showScreensaver: settings.useScreensaver,
        ),
      );
    }
  }

  void activityDetected([_]) => emit(ActivityDetected(clockBloc.state));

  @override
  Future<void> close() async {
    await super.close();
    await _clockSubscription.cancel();
  }
}

abstract class InactivityState extends Equatable {
  const InactivityState();
}

class CalendarInactivityThresholdReached extends InactivityState {
  const CalendarInactivityThresholdReached();

  @override
  List<Object> get props => [];
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

class ActivityDetected extends InactivityState {
  final DateTime timeStamp;

  const ActivityDetected(this.timeStamp);

  @override
  List<Object> get props => [timeStamp];
}
