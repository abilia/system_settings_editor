import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/utils.dart';
import './bloc.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  StreamSubscription _clockSubscription;
  ActivitiesBloc activitiesBloc;
  ClockBloc clockBloc;
  AlarmBloc({
    @required this.activitiesBloc,
    @required this.clockBloc,
  }) {
    _clockSubscription = clockBloc.listen((now) => add(TimeAlarmEvent()));
  }

  @override
  AlarmState get initialState => UnInitializedAlarmState();

  @override
  Stream<AlarmState> mapEventToState(
    AlarmEvent event,
  ) async* {
    final state = activitiesBloc.state;
    if (state is ActivitiesLoaded) {
      final time = clockBloc.state;

      final activitiesThisDay = state.activities
          .where((a) => Recurs.shouldShowForDay(a, time.onlyDays()));
      final activitiesWithAlarm =
          activitiesThisDay.where((a) => a.alarm.shouldAlarm);

      final Iterable<PopUpAlarmState> startTimeAlarms = activitiesWithAlarm
          .where((a) => a.startClock(time).isAtSameMomentAs(time))
          .map((a) => NewAlarmState(a, alarmOnStart: true));

      final endTimeAlarms = activitiesWithAlarm
          .where((a) => a.hasEndTime)
          .where((a) => a.alarm.atEnd)
          .where((a) => a.endClock(time).isAtSameMomentAs(time))
          .map((a) => NewAlarmState(a, alarmOnStart: false));

      final reminders = activitiesThisDay.expand((a) => a.reminders
          .map((r) => NewReminderState(a, reminder: r))
          .where((rs) => rs.activity
              .startClock(time)
              .subtract(rs.reminder)
              .isAtSameMomentAs(time)));

      for (final alarm
          in startTimeAlarms.followedBy(endTimeAlarms).followedBy(reminders)) {
        yield alarm;
      }
    }
  }

  @override
  Future<void> close() async {
    await _clockSubscription.cancel();
    return super.close();
  }
}
