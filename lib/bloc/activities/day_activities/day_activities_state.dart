import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class DayActivitiesState extends Equatable {
  const DayActivitiesState(this.dayFilter);
  final DateTime dayFilter;

  @override
  List<Object> get props => [];
}

class DayActivitiesLoading extends DayActivitiesState {
  DayActivitiesLoading(DateTime dayFilter) : super(dayFilter);
}

class DayActivitiesLoaded extends DayActivitiesState {
  final Iterable<Activity> activities;

  const DayActivitiesLoaded(
    this.activities,
    DateTime dayFilter,
  ) : super(dayFilter);

  @override
  List<Object> get props => [activities, dayFilter];

  @override
  String toString() {
    return 'FilteredActivitiesLoaded { filteredTodos: $activities, day: $dayFilter }';
  }
}