part of 'timer_alarm_bloc.dart';

abstract class TimerAlarmEvent {
  const TimerAlarmEvent();
}

class _TimerAlarmFired extends TimerAlarmEvent {
  const _TimerAlarmFired();
}

class _TimersChanged extends TimerAlarmEvent implements Silent {
  final Iterable<AbiliaTimer> timers;
  const _TimersChanged(this.timers);
}

class _MinuteChanged extends TimerAlarmEvent implements Silent {
  final DateTime time;
  const _MinuteChanged(this.time);
}
