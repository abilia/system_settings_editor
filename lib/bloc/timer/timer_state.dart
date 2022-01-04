part of 'timer_cubit.dart';

class TimerState extends Equatable {
  final List<AbiliaTimer> timers;

  const TimerState({
    required this.timers,
  });

  TimerState copyWith({List<AbiliaTimer>? timers}) {
    return TimerState(timers: timers ?? this.timers);
  }

  @override
  List<Object> get props => [timers];
}
