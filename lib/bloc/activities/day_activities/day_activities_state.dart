import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/recurs.dart';

@immutable
abstract class DayActivitiesState extends Equatable {}

class DayActivitiesUninitialized extends DayActivitiesState {
  @override
  String toString() => 'DayActivitiesUninitialized';
  @override
  List<Object> get props => [];
}

class DayActivitiesLoading extends DayActivitiesState {
  @override
  String toString() => 'DayActivitiesLoading';
  @override
  List<Object> get props => [];
}

class DayActivitiesLoaded extends DayActivitiesState {
  final Iterable<Activity> activities;
  final DateTime day;

  DayActivitiesLoaded(Iterable<Activity> activities, this.day)
      : this.activities =
            activities.where((activity) => activity.shouldShowForDay(day));

  @override
  List<Object> get props => [activities, day];

  @override
  String toString() =>
      'DayActivitiesLoaded { activities: $activities, day: $day }';
}
