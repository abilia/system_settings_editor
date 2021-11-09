part of 'day_activities_bloc.dart';

// This does not extends Equatable because of preformance issues
// when we do equals on a large amount of DateTime
abstract class DayActivitiesState {}

class DayActivitiesUninitialized extends DayActivitiesState {}

class DayActivitiesLoaded extends DayActivitiesState {
  final List<ActivityDay> activities;
  final DateTime day;
  final Occasion occasion;

  DayActivitiesLoaded(this.activities, this.day, this.occasion);

  @override
  String toString() =>
      'DayActivitiesLoaded { ${activities.length} activities, day: ${yMd(day)}, $occasion }';
}
