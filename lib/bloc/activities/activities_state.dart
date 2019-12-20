import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

@immutable
abstract class ActivitiesState extends Equatable {
  const ActivitiesState();

  @override
  List<Object> get props => [];
}

class ActivitiesLoading extends ActivitiesState {}

class ActivitiesLoaded extends ActivitiesState {
  final Iterable<Activity> activities;

  const ActivitiesLoaded(this.activities);

  @override
  List<Object> get props => [activities];

  @override
  String toString() => 'ActivitiesLoaded { activities: $activities }';
}

class ActivitiesNotLoaded extends ActivitiesState {}

class ActivitiesLoadedFailed extends ActivitiesState {}
