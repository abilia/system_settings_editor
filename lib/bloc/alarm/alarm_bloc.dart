import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/utils.dart';
import './bloc.dart';

class AlarmBloc extends Bloc<AlarmEvent, AlarmState> {
  StreamSubscription _activitiesSubscription;
  StreamSubscription _clockSubscription;
  ActivitiesBloc activitiesBloc;
  ClockBloc clockBloc;
  AlarmBloc({
    @required this.activitiesBloc,
    @required this.clockBloc,
  }) {
    _activitiesSubscription = activitiesBloc.listen((state) {
      if (state is ActivitiesLoaded) {
        add(ActivitiesAlarmEvent());
      }
    });
    _clockSubscription = clockBloc.listen((now) => add(TimeAlarmEvent()));
  }

  @override
  AlarmState get initialState => UnInitializedAlarmState();

  @override
  Stream<AlarmState> mapEventToState(
    AlarmEvent event,
  ) async* {
    if (activitiesBloc.state is ActivitiesLoaded) {
      final time = clockBloc.state;

      final activitiesThisDay = (activitiesBloc.state as ActivitiesLoaded)
          .activities
          .where((a) => Recurs.shouldShowForDay(a, onlyDays(time)));
      final activitiesWithAlarm =
          activitiesThisDay.where((a) => a.alarm.shouldAlarm);

      final Iterable<PopUpAlarmState> startTimeAlarms = activitiesWithAlarm
          .where((a) => a.startClock(time).isAtSameMomentAs(time))
          .map((a) => NewAlarmState(a, alarmOnStart: true));

      final endTimeAlarms = activitiesWithAlarm
          .where(
              (a) => a.alarm.atEnd && a.endClock(time).isAtSameMomentAs(time))
          .map((a) => NewAlarmState(a, alarmOnStart: false));

      final reminders = activitiesThisDay.expand((a) => a.reminderBefore
              .map((r) => NewReminderState(a, reminderTime: r))
              .where((rs) {
            final reminderAt = rs.activity
                .startClock(time)
                .subtract(Duration(minutes: rs.reminderTime));
            return reminderAt.isAtSameMomentAs(time);
          }));

      for (final alarm
          in startTimeAlarms.followedBy(endTimeAlarms).followedBy(reminders)) {
        yield alarm;
      }
    }
  }

  @override
  Future<void> close() async {
    await _activitiesSubscription.cancel();
    await _clockSubscription.cancel();
    return super.close();
  }
}
