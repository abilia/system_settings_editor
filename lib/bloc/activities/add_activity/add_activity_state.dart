part of 'add_activity_bloc.dart';

class AddActivityState extends Equatable {
  const AddActivityState(this.activity);
  final Activity activity;
  bool get canSave =>
      activity.title != null ||
      activity.fileId != null && activity.startDateTime != null;
  @override
  List<Object> get props => [activity];
  @override
  String toString() => 'AddActivityState: {activity: $activity}';
}
