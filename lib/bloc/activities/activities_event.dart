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
  String toString() => 'AddActivity { $activity }';
}

class UpdateActivity extends ActivitiesEvent {
  final Activity updatedActivity;

  const UpdateActivity(this.updatedActivity);

  @override
  List<Object> get props => [updatedActivity];

  @override
  String toString() => 'UpdateActivity { $updatedActivity }';
}

class UpdateRecurringActivity extends UpdateActivity {
  final ApplyTo applyTo;
  final DateTime day;
  const UpdateRecurringActivity(Activity activity, this.applyTo, this.day)
      : assert(applyTo != ApplyTo.allDays),
        super(activity);

  @override
  List<Object> get props => [updatedActivity, applyTo, day];

  @override
  String toString() =>
      'UpdateRecurringActivity { $updatedActivity, $applyTo, $day }';
}

class DeleteActivity extends ActivitiesEvent {
  final Activity activity;

  const DeleteActivity(this.activity);

  @override
  List<Object> get props => [activity];

  @override
  String toString() => 'DeleteActivity { $activity }';
}

class DeleteRecurringActivity extends DeleteActivity {
  final ApplyTo applyTo;
  final DateTime day;
  const DeleteRecurringActivity(Activity activity, this.applyTo, this.day)
      : super(activity);

  @override
  List<Object> get props => [activity, applyTo, day];

  @override
  String toString() => 'DeleteRecurringActivity { $activity, $applyTo, $day }';
}
