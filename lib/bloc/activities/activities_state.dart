part of 'activities_bloc.dart';

abstract class ActivitiesState extends Equatable {
  const ActivitiesState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class ActivitiesLoaded extends ActivitiesState {
  final Iterable<Activity> activities;

  const ActivitiesLoaded(this.activities);

  @override
  List<Object> get props => [activities];
}

class ActivitiesReloadning extends ActivitiesLoaded {
  const ActivitiesReloadning(Iterable<Activity> activities) : super(activities);
}

class ActivitiesNotLoaded extends ActivitiesState {}

class ActivitiesLoadedFailed extends ActivitiesState {}
