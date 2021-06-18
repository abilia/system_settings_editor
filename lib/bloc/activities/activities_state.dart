// @dart=2.9

part of 'activities_bloc.dart';

abstract class ActivitiesState extends Equatable {
  final Iterable<Activity> activities;
  const ActivitiesState({this.activities = const []});

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class ActivitiesLoaded extends ActivitiesState {
  const ActivitiesLoaded(Iterable<Activity> activities)
      : super(activities: activities);

  @override
  List<Object> get props => [activities];
}

class ActivitiesNotLoaded extends ActivitiesState {}

class ActivitiesLoadedFailed extends ActivitiesState {}
