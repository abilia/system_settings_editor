import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

@immutable
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
  final List<Payload> pedingAlarms;
  PendingAlarmState(this.pedingAlarms);
  @override
  List<Object> get props => [pedingAlarms];
  @override
  String toString() => 'PendingAlarmState { activityIds: $pedingAlarms }';
}
