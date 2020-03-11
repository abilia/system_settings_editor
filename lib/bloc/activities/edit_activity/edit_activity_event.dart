part of 'edit_activity_bloc.dart';

abstract class EditActivityEvent extends Equatable {
  const EditActivityEvent();
}

class ChangeActivity extends EditActivityEvent {
  final Activity activity;
  ChangeActivity(this.activity);

  @override
  List<Object> get props => [activity];
  @override
  String toString() => 'ChangeActivity { $activity }';
}

class SaveActivity extends EditActivityEvent {
  @override
  List<Object> get props => [];
}

class ChangeDate extends EditActivityEvent {
  final DateTime date;
  ChangeDate(this.date);
  @override
  List<Object> get props => [date];
  @override
  String toString() => 'ChangeDate { $date }';
}

abstract class ChangeTime extends EditActivityEvent {
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

class AddOrRemoveReminder extends EditActivityEvent {
  final Duration reminder;
  const AddOrRemoveReminder(this.reminder);
  @override
  String toString() => 'AddOrRemoveReminder { $reminder }';
  @override
  List<Object> get props => [reminder];
}

class ImageSelected extends EditActivityEvent {
  final String imageId;
  ImageSelected(this.imageId);
  @override
  List<Object> get props => [imageId];
  @override
  String toString() => 'ImageSelected { $imageId }';
}
