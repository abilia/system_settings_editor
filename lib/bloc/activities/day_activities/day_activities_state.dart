import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class DayActivitiesState extends Equatable {
  const DayActivitiesState();

  @override
  List<Object> get props => [];
}

class DayActivitiesLoading extends DayActivitiesState {}

class DayActivitiesLoaded extends DayActivitiesState {
  final List<Activity> filteredActivities;
  final DateTime dayFilter;

  const DayActivitiesLoaded(
    this.filteredActivities,
    this.dayFilter,
  );

  @override
  List<Object> get props => [filteredActivities, dayFilter];

  @override
  String toString() {
    return 'FilteredActivitiesLoaded { filteredTodos: $filteredActivities, day: $dayFilter }';
  }
}