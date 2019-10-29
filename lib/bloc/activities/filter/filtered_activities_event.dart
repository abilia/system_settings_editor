import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class FilteredActivitiesEvent extends Equatable {
  const FilteredActivitiesEvent();
}

class UpdateFilter extends FilteredActivitiesEvent {
  final DateTime dayFilter;

  const UpdateFilter(this.dayFilter);

  @override
  List<Object> get props => [dayFilter];

  @override
  String toString() => 'UpdateFilter { filter: $dayFilter }';
}

class UpdateActivities extends FilteredActivitiesEvent {
  final List<Activity> activities;

  const UpdateActivities(this.activities);

  @override
  List<Object> get props => [activities];

  @override
  String toString() => 'UpdateActivities { activities: $activities }';
}