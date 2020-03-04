part of 'add_activity_bloc.dart';

abstract class AddActivityEvent extends Equatable {
  const AddActivityEvent();
}

class ChangeActivity extends AddActivityEvent {
  final Activity activity;
  ChangeActivity(this.activity);

  @override
  List<Object> get props => [activity];
  @override
  String toString() => 'ChangeActivity { $activity }';
}

class SaveActivity extends AddActivityEvent {
  @override
  List<Object> get props => [];
}

class ChangeDate extends AddActivityEvent {
  final DateTime date;
  ChangeDate(this.date);
  @override
  List<Object> get props => [date];
  @override
  String toString() => 'ChangeDate { $date }';
}

abstract class ChangeTime extends AddActivityEvent {
  final TimeOfDay time;

  ChangeTime(this.time);
  @override
  List<Object> get props => [time];
}

class ChangeStartTime extends ChangeTime {
  ChangeStartTime(TimeOfDay time) : super(time);
  @override
  String toString() => 'ChangeStartTime { $time }';
}

class ChangeEndTime extends ChangeTime {
  ChangeEndTime(TimeOfDay time) : super(time);
  @override
  String toString() => 'ChangeEndTime { $time }';
}

class ImageSelected extends AddActivityEvent {
  final String imageId;
  ImageSelected(this.imageId);
  @override
  List<Object> get props => [imageId];
  @override
  String toString() => 'ImageSelected { $imageId }';
}
