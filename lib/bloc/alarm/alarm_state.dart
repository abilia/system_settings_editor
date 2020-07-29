part of 'alarm_bloc.dart';

abstract class AlarmStateBase extends Equatable {}

class UnInitializedAlarmState extends AlarmStateBase {
  @override
  List<Object> get props => [];
  @override
  String toString() => 'UnInitializedAlarmState';
}

class AlarmState extends AlarmStateBase {
  final NotificationAlarm alarm;
  AlarmState(this.alarm) : assert(alarm != null);
  @override
  List<Object> get props => [alarm];
  @override
  String toString() => 'AlarmState { alarm: $alarm }';
}

class PendingAlarmState extends AlarmStateBase {
  final UnmodifiableSetView<NotificationPayload> pedingAlarms;
  PendingAlarmState._(this.pedingAlarms);
  PendingAlarmState(Iterable<NotificationPayload> pedingAlarms)
      : this._(UnmodifiableSetView(pedingAlarms.toSet()));
  @override
  List<Object> get props => [pedingAlarms];
  @override
  String toString() => 'PendingAlarmState { activityIds: $pedingAlarms }';
}
