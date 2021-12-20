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
  const ReplaceActivity(this.activity);

  @override
  List<Object> get props => [activity];
}

class AddBasicActivity extends ActivityChangedEvent {
  final BasicActivityDataItem basicActivityData;

  const AddBasicActivity(this.basicActivityData);
  @override
  List<Object> get props => [basicActivityData];
}

class ActivitySavedSuccessfully extends EditActivityEvent with Fine {
  final Activity activitySaved;
  const ActivitySavedSuccessfully(this.activitySaved);
  @override
  List<Object> get props => [activitySaved];
}

class ChangeDate extends ActivityChangedEvent {
  final DateTime date;
  const ChangeDate(this.date);
  @override
  List<Object> get props => [date];
}

class ChangeTimeInterval extends ActivityChangedEvent {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  const ChangeTimeInterval({this.startTime, this.endTime});

  @override
  List<Object?> get props => [startTime, endTime];
}

class AddOrRemoveReminder extends ActivityChangedEvent {
  final Duration reminder;
  const AddOrRemoveReminder(this.reminder);
  @override
  List<Object> get props => [reminder];
}

class ImageSelected extends ActivityChangedEvent {
  final AbiliaFile selected;
  String get imageId => selected.id;
  String get path => selected.path;
  const ImageSelected(this.selected);

  @override
  List<Object> get props => [imageId];
}

class ChangeInfoItemType extends ActivityChangedEvent {
  final Type infoItemType;
  const ChangeInfoItemType(this.infoItemType);
  @override
  List<Object> get props => [infoItemType];
  @override
  String toString() => 'InfoItemChanged { $infoItemType }';
}
