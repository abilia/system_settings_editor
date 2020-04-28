import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';

@immutable
abstract class AlarmEvent with Silent {}

class TimeAlarmEvent extends AlarmEvent {
  @override
  String toString() => 'TimeAlarmEvent';
}

class ActivitiesAlarmEvent extends AlarmEvent {
  @override
  String toString() => 'ActivitiesAlarmEvent';
}
