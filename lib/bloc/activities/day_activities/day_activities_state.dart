// @dart=2.9

part of 'day_activities_bloc.dart';

abstract class DayActivitiesState extends Equatable {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class DayActivitiesUninitialized extends DayActivitiesState {}

class DayActivitiesLoaded extends DayActivitiesState {
  final Iterable<ActivityDay> activities;
  final DateTime day;
  final Occasion occasion;

  DayActivitiesLoaded(this.activities, this.day, this.occasion);

  @override
  List<Object> get props => [activities, day, occasion];

  @override
  String toString() =>
      'DayActivitiesLoaded { ${activities.length} activities, day: ${yMd(day)}, $occasion }';
}
