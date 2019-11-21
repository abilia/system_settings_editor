import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class DayActivitiesEvent extends Equatable {
  const DayActivitiesEvent();
}

class UpdateDay extends DayActivitiesEvent {
  final DateTime dayFilter;

  const UpdateDay(this.dayFilter);

  @override
  List<Object> get props => [dayFilter];

  @override
  String toString() => 'UpdateDay { ${['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][dayFilter.weekday-1]}, $dayFilter }';
}

class UpdateActivities extends DayActivitiesEvent {
  final Iterable<Activity> activities;

  const UpdateActivities(this.activities);

  @override
  List<Object> get props => [activities];

  @override
  String toString() => 'UpdateActivities { activities: $activities }';
}