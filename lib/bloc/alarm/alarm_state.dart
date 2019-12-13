import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models.dart';

@immutable
abstract class AlarmState extends Equatable {
  @override
  List<Object> get props => [];
}

class UnInitializedAlarmState extends AlarmState {
  @override
  String toString() => 'UnInitializedAlarmState';
}

class NoAlarmState extends AlarmState {
  @override
  String toString() => 'NoAlarmState';
}

abstract class PopUpAlarmState extends AlarmState {
  final Activity activity;
  PopUpAlarmState(this.activity) : assert(activity != null);
}

class NewAlarmState extends PopUpAlarmState {
  final bool alarmOnStart;
  NewAlarmState(Activity activity, {this.alarmOnStart = true})
      : assert(alarmOnStart != null),
        super(activity);
  @override
  List<Object> get props => [activity, alarmOnStart];
  @override
  String toString() =>
      'NewAlarmState { activity: $activity, ${alarmOnStart ? 'START' : 'END'}-alarm }';
}

class NewReminderState extends PopUpAlarmState {
  final Duration reminder;
  NewReminderState(Activity activity, {@required this.reminder})
      : assert(reminder != null),
        assert(reminder > Duration.zero),
        super(activity);
  @override
  List<Object> get props => [activity, reminder];
  @override
  String toString() =>
      'NewReminderState { activity: $activity, reminder: $reminder }';
}