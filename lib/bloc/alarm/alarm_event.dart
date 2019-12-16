import 'package:meta/meta.dart';

@immutable
abstract class AlarmEvent {}

class TimeAlarmEvent extends AlarmEvent {
  @override
  String toString() => 'TimeAlarmEvent';
}

class ActivitiesAlarmEvent extends AlarmEvent {
  @override
  String toString() => 'ActivitiesAlarmEvent';
}
