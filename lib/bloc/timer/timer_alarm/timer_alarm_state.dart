part of 'timer_alarm_bloc.dart';

class TimerAlarmState extends Equatable {
  final UnmodifiableListView<TimerOccasion> timers;
  final Queue<TimerOccasion> ongoingQueue;

  TimerAlarmState.sort(
    Iterable<TimerOccasion> timers,
  )   : ongoingQueue =
            Queue.from(timers.where((t) => t.isOngoing).toList()..sort(_sort)),
        timers = UnmodifiableListView(timers);
  TimerAlarmState({
    required Iterable<TimerOccasion> timers,
    required Iterable<TimerOccasion> queue,
  })  : ongoingQueue = Queue.from(queue),
        timers = UnmodifiableListView(timers);

  @override
  List<Object> get props => [timers, ongoingQueue];

  static int _sort(TimerOccasion t1, TimerOccasion t2) =>
      t1.end.compareTo(t2.end);
}
