// @dart=2.9

part of 'day_activities_bloc.dart';

abstract class DayActivitiesEvent extends Equatable {
  const DayActivitiesEvent();
}

class UpdateDay extends DayActivitiesEvent {
  final DateTime dayFilter;
  final Occasion occasion;

  const UpdateDay(this.dayFilter, this.occasion);

  @override
  List<Object> get props => [dayFilter, occasion];

  @override
  String toString() => 'UpdateDay { ${yMd(dayFilter)}, $occasion }';
}

class UpdateActivities extends DayActivitiesEvent {
  final Iterable<Activity> activities;

  const UpdateActivities(this.activities);

  @override
  List<Object> get props => [activities];

  @override
  String toString() => 'UpdateActivities { ${activities.length} activities }';
}
