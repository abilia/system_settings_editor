import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';

class InactivityCubit extends Cubit<InactivityState> {
  final Duration _calendarInactivityTime;
  late Duration _homeScreenInactivityTime;
  late bool _useScreenSaver = false;
  final ClockBloc clockBloc;
  late StreamSubscription<MemoplannerSettingsState> _settingsStream;
  late StartView _homeScreenView;

  final Logger _log = Logger('InactivityCubit');

  late StreamSubscription<DateTime> _clockSubscription;

  InactivityCubit(
    this._calendarInactivityTime,
    this.clockBloc,
    MemoplannerSettingBloc settingsBloc,
  ) : super(ActivityDetectedState(clockBloc.state)) {
    _settingsStream = settingsBloc.stream.listen((settings) {
      if (settings is MemoplannerSettingsLoaded) {
        _useScreenSaver = settings.useScreensaver;
        _homeScreenInactivityTime =
            Duration(milliseconds: settings.activityTimeout);
        _homeScreenView = settings.startView;
        _log.fine(
            'ScreenSaver settings $_useScreenSaver $_homeScreenInactivityTime $_homeScreenView');
      }
    });
    _clockSubscription = clockBloc.stream.listen(_ticking);
  }

  void _ticking(DateTime time) async {
    final state = this.state;
    if (state is ActivityDetectedState &&
        time.isAfter(state.timeStamp.add(_calendarInactivityTime))) {
      emit(const CalendarInactivityThresholdReachedState());
    }
    if (_useScreenSaver &&
        state is ActivityDetectedState &&
        time.isAfter(state.timeStamp.add(_homeScreenInactivityTime))) {
      emit(HomeScreenInactivityThresholdReachedState(
          _homeScreenView, _useScreenSaver));
    }
  }

  void activityDetected(_) async {
    emit(ActivityDetectedState(clockBloc.state));
  }

  @override
  Future<void> close() async {
    await super.close();
    await _clockSubscription.cancel();
    await _settingsStream.cancel();
  }
}

abstract class InactivityState extends Equatable {
  const InactivityState();
}

class CalendarInactivityThresholdReachedState extends InactivityState {
  const CalendarInactivityThresholdReachedState();

  @override
  List<Object> get props => [];
}

class HomeScreenInactivityThresholdReachedState extends InactivityState {
  const HomeScreenInactivityThresholdReachedState(
      this.startView, this.showScreenSaver);
  final StartView startView;
  final bool showScreenSaver;

  @override
  List<Object?> get props => [startView, showScreenSaver];
}

class ActivityDetectedState extends InactivityState {
  final DateTime timeStamp;

  const ActivityDetectedState(this.timeStamp);

  @override
  List<Object> get props => [timeStamp];
}
