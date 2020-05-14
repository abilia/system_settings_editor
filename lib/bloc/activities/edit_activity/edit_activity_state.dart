part of 'edit_activity_bloc.dart';

abstract class EditActivityState extends Equatable with Silent {
  const EditActivityState(this.activity, [this.newImage]);
  final Activity activity;
  final File newImage;
  bool get canSave =>
      activity.hasTitle ||
      activity.fileId?.isNotEmpty == true && activity.startTime != null;
  @override
  List<Object> get props => [activity, newImage];
  EditActivityState copyWith(Activity activity, [File newImage]);
}

class UnstoredActivityState extends EditActivityState {
  const UnstoredActivityState(Activity activity, [File newImage])
      : super(activity, newImage);
  @override
  String toString() =>
      'UnstoredActivityState: {activity: $activity, newImage: ${newImage?.path}';
  @override
  UnstoredActivityState copyWith(Activity activity, [File newImage]) =>
      UnstoredActivityState(activity, newImage ?? this.newImage);
}

class StoredActivityState extends EditActivityState {
  final DateTime day;
  const StoredActivityState(Activity activity, this.day, [File newImage])
      : super(activity);
  @override
  String toString() =>
      'StoredActivityState: {activity: $activity, day: $day, newImage: ${newImage?.path}';
  @override
  List<Object> get props => super.props..add(day);

  @override
  StoredActivityState copyWith(Activity activity, [File newImage]) =>
      StoredActivityState(activity, day, newImage ?? this.newImage);
}
