part of 'edit_activity_bloc.dart';

abstract class EditActivityState extends Equatable {
  const EditActivityState(this.activity);
  final Activity activity;
  bool get canSave =>
      activity.title?.isNotEmpty == true ||
      activity.fileId?.isNotEmpty == true && activity.startDateTime != null;
  @override
  List<Object> get props => [activity];
}

class UnsavedActivityState extends EditActivityState {
  const UnsavedActivityState(Activity activity) : super(activity);
  @override
  String toString() => 'UnsavedActivityState: {activity: $activity}';
}

class SavedActivityState extends EditActivityState {
  const SavedActivityState(Activity activity) : super(activity);
  @override
  String toString() => 'SavedActivityState: {activity: $activity}';
}
