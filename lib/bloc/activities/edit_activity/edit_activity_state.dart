part of 'edit_activity_bloc.dart';

abstract class EditActivityState extends Equatable {
  const EditActivityState(this.activity, [this.newImage]);
  final Activity activity;
  final File newImage;
  bool get canSave =>
      activity.title?.isNotEmpty == true ||
      activity.fileId?.isNotEmpty == true && activity.startDateTime != null;
  @override
  List<Object> get props => [activity, newImage];
}

class UnsavedActivityState extends EditActivityState {
  const UnsavedActivityState(Activity activity, [File newImage])
      : super(activity, newImage);
  @override
  String toString() =>
      'UnsavedActivityState: {activity: $activity, newImage: ${newImage?.path}';
}

class SavedActivityState extends EditActivityState {
  const SavedActivityState(Activity activity) : super(activity);
  @override
  String toString() => 'SavedActivityState: {activity: $activity}';
}
