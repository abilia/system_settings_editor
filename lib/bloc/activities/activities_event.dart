import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

@immutable
abstract class ActivitiesEvent extends Equatable {
  const ActivitiesEvent();

  @override
  List<Object> get props => [];
}

class LoadActivities extends ActivitiesEvent {}

class AddActivity extends ActivitiesEvent {
  final Activity activity;

  const AddActivity(this.activity);

  @override
  List<Object> get props => [activity];

  @override
  String toString() => 'AddActivity { activity: $activity }';
}

class UpdateActivity extends ActivitiesEvent {
  final Activity updatedActivity;

  const UpdateActivity(this.updatedActivity);

  @override
  List<Object> get props => [updatedActivity];

  @override
  String toString() => 'UpdateActivity { updatedActivity: $updatedActivity }';
}
