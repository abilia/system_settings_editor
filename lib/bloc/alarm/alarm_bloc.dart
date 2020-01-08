import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import './bloc.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmStateBase> {
  StreamSubscription _clockSubscription;
  final ActivitiesBloc activitiesBloc;
  final ClockBloc clockBloc;
  AlarmBloc({
    @required this.activitiesBloc,
    @required this.clockBloc,
  }) {
    _clockSubscription = clockBloc.listen((now) => add(TimeAlarmEvent()));
  }

  @override
  AlarmStateBase get initialState => UnInitializedAlarmState();

  @override
  Stream<AlarmStateBase> mapEventToState(
    AlarmEvent event,
  ) async* {
    final state = activitiesBloc.state;
    if (state is ActivitiesLoaded) {
      final alarmsAndReminders =
          state.activities.alarmsOnExactMinute(clockBloc.state);
      for (final alarm in alarmsAndReminders) {
        yield AlarmState(alarm);
      }
    }
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    return super.close();
  }
}
