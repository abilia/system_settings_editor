part of 'timer_cubit.dart';

class TimerState extends Equatable {
  final UnmodifiableListView<AbiliaTimer> timers;

  TimerState({
    Iterable<AbiliaTimer> timers = const [],
  }) : timers = UnmodifiableListView(timers);

  @override
  List<Object> get props => [timers];
}
