import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
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
  final Iterable<ActivityDay> activities;
  final DateTime day;

  DayActivitiesLoaded(Iterable<Activity> activities, this.day)
      : activities = activities
            .map((activity) => activity.shouldShowForDay(day))
            .where((activityDay) => activityDay != null);

  @override
  List<Object> get props => [activities, day];

  @override
  String toString() =>
      'DayActivitiesLoaded { ${activities.length} activities, day: ${yMd(day)} }';
}
