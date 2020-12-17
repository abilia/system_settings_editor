part of 'edit_activity_bloc.dart';

abstract class EditActivityEvent extends Equatable {
  const EditActivityEvent();
  @override
  bool get stringify => true;
}

abstract class ActivityChangedEvent extends EditActivityEvent with Finest {
  const ActivityChangedEvent();
}

class ReplaceActivity extends ActivityChangedEvent {
  final Activity activity;
  ReplaceActivity(this.activity);

  @override
  List<Object> get props => [activity];
}

class SaveActivity extends EditActivityEvent with Fine {
  const SaveActivity();
  @override
  List<Object> get props => [];
}

class SaveRecurringActivity extends SaveActivity with Fine {
  final ApplyTo applyTo;
  final DateTime day;
  const SaveRecurringActivity(this.applyTo, this.day);
  @override
  List<Object> get props => [applyTo];
}

class ChangeDate extends ActivityChangedEvent {
  final DateTime date;
  ChangeDate(this.date);
  @override
  List<Object> get props => [date];
}

abstract class ChangeTime extends ActivityChangedEvent {
  final TimeOfDay time;
  const ChangeTime(this.time);
  @override
  List<Object> get props => [time];
}

class ChangeStartTime extends ChangeTime {
  const ChangeStartTime(TimeOfDay time) : super(time);
}

class ChangeTimeInterval extends ActivityChangedEvent {
  final TimeInput timeInput;
  const ChangeTimeInterval(this.timeInput);

  @override
  List<Object> get props => [timeInput];
}

class ChangeEndTime extends ChangeTime {
  const ChangeEndTime(TimeOfDay time) : super(time);
}

class AddOrRemoveReminder extends ActivityChangedEvent {
  final Duration reminder;
  const AddOrRemoveReminder(this.reminder);
  @override
  List<Object> get props => [reminder];
}

class ImageSelected extends ActivityChangedEvent {
  final String imageId;
  final String path;
  final File newImage;
  ImageSelected(this.imageId, this.path, this.newImage);
  @override
  List<Object> get props => [imageId];
}

class ChangeInfoItemType extends ActivityChangedEvent {
  final Type infoItemType;
  ChangeInfoItemType(this.infoItemType);
  @override
  List<Object> get props => [infoItemType];
  @override
  String toString() => 'InfoItemChanged { $infoItemType }';
}
