part of 'activities_bloc.dart';

abstract class ActivitiesState extends Equatable {
  final List<Activity> activities;
  const ActivitiesState({this.activities = const []});

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class ActivitiesLoaded extends ActivitiesState {
  ActivitiesLoaded(Iterable<Activity> activities)
      : super(activities: activities.toList());

  @override
  List<Object> get props => [activities];
}

class ActivitiesNotLoaded extends ActivitiesState {}

class ActivitiesLoadedFailed extends ActivitiesState {}
