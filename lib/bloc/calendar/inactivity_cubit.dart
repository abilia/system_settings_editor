import 'dart:async';

import 'package:equatable/equatable.dart';

import '../all.dart';

class _InactivityTicker {
  final int _tickRate;

  const _InactivityTicker(this._tickRate);

  Stream<int> tick({required int duration}) {
    return Stream.periodic(Duration(seconds: _tickRate), (x) => x * _tickRate)
        .take((duration ~/ _tickRate) + 1);
  }
}

class InactivityCubit extends Cubit<InactivityState> {
  final Duration _inactivityTime;

  final _InactivityTicker _ticker = _InactivityTicker(1);
  StreamSubscription<Duration>? _tickerSubscription;

  InactivityCubit(this._inactivityTime) : super(ActivityDetectedState()) {
    _startTimer();
  }

  void _ticking(Duration duration) async {
    if (duration >= _inactivityTime) {
      emit(InactivityThresholdReachedState());
      _startTimer();
    }
  }

  void _startTimer() async {
    await _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(duration: _inactivityTime.inSeconds)
        .map((event) => Duration(seconds: event))
        .listen((duration) => _ticking(duration));
  }

  void activityDetected() {
    emit(ActivityDetectedState());
    _startTimer();
  }

  void stopTimer() async {
    await _tickerSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await super.close();
    await _tickerSubscription?.cancel();
  }
}

class InactivityState extends Equatable {
  @override
  List<Object> get props => [];
}

class InactivityThresholdReachedState extends InactivityState {}

class ActivityDetectedState extends InactivityState {}
