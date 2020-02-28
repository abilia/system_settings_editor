part of 'add_activity_bloc.dart';

abstract class AddActivityState extends Equatable {
  const AddActivityState(this.activity);
  final Activity activity;
  bool get canSave =>
      activity.title?.isNotEmpty == true ||
      activity.fileId?.isNotEmpty == true && activity.startDateTime != null;
  @override
  List<Object> get props => [activity];
}

class UnsavedActivityState extends AddActivityState {
  const UnsavedActivityState(Activity activity) : super(activity);
  @override
  String toString() => 'UnsavedActivityState: {activity: $activity}';
}

class SavedActivityState extends AddActivityState {
  const SavedActivityState(Activity activity) : super(activity);
  @override
  String toString() => 'SavedActivityState: {activity: $activity}';
}
