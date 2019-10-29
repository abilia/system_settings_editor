import 'package:equatable/equatable.dart';
import 'package:seagull/models.dart';

abstract class FilteredActivitiesState extends Equatable {
  const FilteredActivitiesState();

  @override
  List<Object> get props => [];
}

class FilteredActivitiesLoading extends FilteredActivitiesState {}

class FilteredActivitiesLoaded extends FilteredActivitiesState {
  final List<Activity> filteredActivities;
  final DateTime dayFilter;

  const FilteredActivitiesLoaded(
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