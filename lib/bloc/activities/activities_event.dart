part of 'activities_bloc.dart';

abstract class ActivitiesEvent extends Equatable {
  const ActivitiesEvent();

  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
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
}

class UpdateActivity extends ManipulateActivitiesEvent {
  @override
  final Activity activity;
  const UpdateActivity(this.activity);
}

class DeleteActivity extends ManipulateActivitiesEvent {
  @override
  final Activity activity;
  const DeleteActivity(this.activity);
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
  const UpdateRecurringActivity(ActivityDay activityDay, ApplyTo applyTo)
      : assert(applyTo != ApplyTo.allDays),
        super(activityDay, applyTo);
}

class DeleteRecurringActivity extends RecurringActivityEvent {
  const DeleteRecurringActivity(ActivityDay activityDay, ApplyTo applyTo)
      : super(activityDay, applyTo);
}
