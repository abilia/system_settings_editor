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

abstract class ManipulateActivitiesEvent extends ActivitiesEvent {
  const ManipulateActivitiesEvent();
  Activity get activity;
  @override
  List<Object> get props => [activity];
}

class AddActivity extends ManipulateActivitiesEvent {
  @override
  final Activity activity;
  const AddActivity(this.activity);
  @override
  String toString() => 'AddActivity { $activity }';
}

class UpdateActivity extends ManipulateActivitiesEvent {
  @override
  final Activity activity;
  const UpdateActivity(this.activity);
  @override
  String toString() => 'UpdateActivity { $activity }';
}

class DeleteActivity extends ManipulateActivitiesEvent {
  @override
  final Activity activity;
  const DeleteActivity(this.activity);
  @override
  String toString() => 'DeleteActivity { $activity }';
}

abstract class RecurringActivityEvent extends ManipulateActivitiesEvent {
  final ActivityDay activityDay;
  final ApplyTo applyTo;
  DateTime get day => activityDay.day;
  @override
  Activity get activity => activityDay.activity;
  const RecurringActivityEvent(this.activityDay, this.applyTo);
  @override
  List<Object> get props => [activityDay];
}

class UpdateRecurringActivity extends RecurringActivityEvent {
  UpdateRecurringActivity(ActivityDay activityDay, ApplyTo applyTo)
      : assert(applyTo != ApplyTo.allDays),
        super(activityDay, applyTo);

  @override
  String toString() => 'UpdateRecurringActivity { $activityDay, $applyTo, }';
}

class DeleteRecurringActivity extends RecurringActivityEvent {
  DeleteRecurringActivity(ActivityDay activityDay, ApplyTo applyTo)
      : super(activityDay, applyTo);

  @override
  String toString() => 'DeleteRecurringActivity { $activityDay, $applyTo }';
}
