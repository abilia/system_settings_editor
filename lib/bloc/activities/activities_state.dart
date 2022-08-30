part of 'activities_bloc.dart';

abstract class ActivitiesState extends Equatable {
  final List<Activity> activities;
  const ActivitiesState({this.activities = const [], this.validLicense = true});

  final bool validLicense;

  @override
  List<Object> get props => [];
}

class ActivitiesLoaded extends ActivitiesState {
  ActivitiesLoaded(Iterable<Activity> activities)
      : super(activities: activities.toList());

  @override
  List<Object> get props => [activities];
  @override
  String toString() => 'ActivitiesLoaded { ${activities.length} activities}';
}

class ActivitiesNotLoaded extends ActivitiesState {
  const ActivitiesNotLoaded({bool validLicense = true})
      : super(validLicense: validLicense);
}

class ActivitiesLoadedFailed extends ActivitiesState {
  const ActivitiesLoadedFailed({required bool validLicense})
      : super(validLicense: validLicense);
}
