import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class DayActivitiesState extends Equatable {
  const DayActivitiesState(this.dayFilter);
  final DateTime dayFilter;

}

class DayActivitiesLoading extends DayActivitiesState {
  DayActivitiesLoading(DateTime dayFilter) : super(dayFilter);
  @override
  String toString() => 'DayActivitiesLoading { day: $dayFilter }';
  @override
  List<Object> get props => [dayFilter];
}

class DayActivitiesLoaded extends DayActivitiesState {
  final Iterable<Activity> activities;

  const DayActivitiesLoaded(
    this.activities,
    DateTime dayFilter,
  ) : super(dayFilter);

  @override
  List<Object> get props => [activities, dayFilter]; // During testing we need to execute iterable

  @override
  String toString() =>
      'DayActivitiesLoaded { activities: $activities, day: $dayFilter }';
}
