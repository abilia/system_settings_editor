import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class DayActivitiesState extends Equatable {}

class DayActivitiesUninitialized extends DayActivitiesState {
  @override
  String toString() => 'DayActivitiesUninitialized';
  @override
  List<Object> get props => null;
}

class DayActivitiesLoading extends DayActivitiesState {
  @override
  String toString() => 'DayActivitiesLoading';
  @override
  List<Object> get props => null;
}

class DayActivitiesLoaded extends DayActivitiesState {
  final Iterable<Activity> activities;
  final DateTime day;

  DayActivitiesLoaded(this.activities, this.day);

  @override
  List<Object> get props => [activities, day];

  @override
  String toString() => 'DayActivitiesLoaded { activities: $activities }';
}
