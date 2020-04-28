part of 'edit_activity_bloc.dart';

abstract class EditActivityEvent extends Equatable {
  const EditActivityEvent();
}

abstract class ActivityChangedEvent extends EditActivityEvent with Silent {
  const ActivityChangedEvent();
}

class ReplaceActivity extends ActivityChangedEvent {
  final Activity activity;
  ReplaceActivity(this.activity);

  @override
  List<Object> get props => [activity];
  @override
  String toString() => 'ChangeActivity { $activity }';
}

class SaveActivity extends EditActivityEvent {
  const SaveActivity();
  @override
  List<Object> get props => [];
}

class SaveRecurringActivity extends SaveActivity {
  final ApplyTo applyTo;
  final DateTime day;
  const SaveRecurringActivity(this.applyTo, this.day);
  @override
  List<Object> get props => [applyTo];
  String toString() => 'SaveRecurringActivity { $applyTo, $day }';
}

class ChangeDate extends ActivityChangedEvent {
  final DateTime date;
  ChangeDate(this.date);
  @override
  List<Object> get props => [date];
  @override
  String toString() => 'ChangeDate { $date }';
}

abstract class ChangeTime extends ActivityChangedEvent {
  final TimeOfDay time;
  const ChangeTime(this.time);
  @override
  List<Object> get props => [time];
}

class ChangeStartTime extends ChangeTime {
  const ChangeStartTime(TimeOfDay time) : super(time);
  @override
  String toString() => 'ChangeStartTime { $time }';
}

class ChangeEndTime extends ChangeTime {
  const ChangeEndTime(TimeOfDay time) : super(time);
  @override
  String toString() => 'ChangeEndTime { $time }';
}

class AddOrRemoveReminder extends ActivityChangedEvent {
  final Duration reminder;
  const AddOrRemoveReminder(this.reminder);
  @override
  String toString() => 'AddOrRemoveReminder { $reminder }';
  @override
  List<Object> get props => [reminder];
}

class ImageSelected extends ActivityChangedEvent {
  final String imageId;
  final File newImage;
  ImageSelected(this.imageId, this.newImage);
  @override
  List<Object> get props => [imageId];
  @override
  String toString() => 'ImageSelected { $imageId }';
}
