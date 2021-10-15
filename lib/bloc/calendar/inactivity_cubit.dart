import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';

class InactivityCubit extends Cubit<InactivityState> {
  final Duration _inactivityTime;
  final ClockBloc clockBloc;

  late StreamSubscription<DateTime> _clockSubscription;

  InactivityCubit(
    this._inactivityTime,
    this.clockBloc,
  ) : super(ActivityDetectedState(clockBloc.state)) {
    _clockSubscription = clockBloc.stream.listen(_ticking);
  }

  void _ticking(DateTime time) async {
    final state = this.state;
    if (state is ActivityDetectedState &&
        time.isAfter(state.timeStamp.add(_inactivityTime))) {
      emit(InactivityThresholdReachedState());
    }
  }

  void activityDetected(_) async {
    emit(ActivityDetectedState(clockBloc.state));
  }

  @override
  Future<void> close() async {
    await super.close();
    await _clockSubscription.cancel();
  }
}

abstract class InactivityState extends Equatable {
  const InactivityState();
}

class InactivityThresholdReachedState extends InactivityState {
  const InactivityThresholdReachedState();
  @override
  List<Object> get props => [];
}

class ActivityDetectedState extends InactivityState {
  final DateTime timeStamp;
  const ActivityDetectedState(this.timeStamp);
  @override
  List<Object> get props => [timeStamp];
}
