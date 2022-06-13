part of 'timer_alarm_bloc.dart';

class TimerAlarmState extends Equatable {
  final UnmodifiableListView<TimerOccasion> timers;
  final Queue<TimerOccasion> ongoingQueue;
  final TimerAlarm? firedAlarm;

  TimerAlarmState.sort(Iterable<TimerOccasion> timers, [this.firedAlarm])
      : ongoingQueue =
            Queue.from(timers.where((t) => t.isOngoing).toList()..sort(_sort)),
        timers = UnmodifiableListView(timers);

  TimerAlarmState({
    required Iterable<TimerOccasion> timers,
    required Iterable<TimerOccasion> queue,
    this.firedAlarm,
  })  : ongoingQueue = Queue.from(queue),
        timers = UnmodifiableListView(timers);

  @override
  List<Object> get props => [timers, ongoingQueue];

  static int _sort(TimerOccasion t1, TimerOccasion t2) =>
      t1.end.compareTo(t2.end);
}
