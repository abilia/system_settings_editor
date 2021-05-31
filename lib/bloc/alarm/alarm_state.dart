// @dart=2.9

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
