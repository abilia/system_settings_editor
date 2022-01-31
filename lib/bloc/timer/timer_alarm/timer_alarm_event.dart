part of 'timer_alarm_bloc.dart';

abstract class TimerAlarmEvent {
  const TimerAlarmEvent();
}

class _TimerAlarmFired extends TimerAlarmEvent {
  const _TimerAlarmFired();
}

class _TimersChanged extends TimerAlarmEvent {
  final Iterable<AbiliaTimer> timers;
  const _TimersChanged(this.timers);
}

class _MinuteChanged extends TimerAlarmEvent {
  final DateTime time;
  const _MinuteChanged(this.time);
}
