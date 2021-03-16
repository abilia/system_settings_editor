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
  const SaveActivity({this.activityBeforeNowConfirmed = false});
  final bool activityBeforeNowConfirmed;
  @override
  List<Object> get props => [];
}

class SaveRecurringActivity extends SaveActivity with Fine {
  final ApplyTo applyTo;
  final DateTime day;
  const SaveRecurringActivity(this.applyTo, this.day,
      {bool activityBeforeNowConfirmed = false})
      : super(activityBeforeNowConfirmed: activityBeforeNowConfirmed);
  @override
  List<Object> get props => [applyTo];
}

class ChangeDate extends ActivityChangedEvent {
  final DateTime date;
  ChangeDate(this.date);
  @override
  List<Object> get props => [date];
}

class ChangeTimeInterval extends ActivityChangedEvent {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  const ChangeTimeInterval({this.startTime, this.endTime});

  @override
  List<Object> get props => [startTime, endTime];
}

class AddOrRemoveReminder extends ActivityChangedEvent {
  final Duration reminder;
  const AddOrRemoveReminder(this.reminder);
  @override
  List<Object> get props => [reminder];
}

class ImageSelected extends ActivityChangedEvent {
  final SelectedImage selected;
  String get imageId => selected.id;
  String get path => selected.path;
  File get newImage => selected.file;
  const ImageSelected(this.selected);

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
