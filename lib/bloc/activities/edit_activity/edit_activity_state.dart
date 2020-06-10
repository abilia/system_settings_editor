part of 'edit_activity_bloc.dart';

abstract class EditActivityState extends Equatable with Silent {
  const EditActivityState(this.activity, this.timeInterval, [this.newImage]);
  final Activity activity;
  final TimeInterval timeInterval;
  final File newImage;
  bool get canSave =>
      (activity.hasTitle || activity.fileId?.isNotEmpty == true) &&
      (timeInterval.startTime != null || activity.fullDay);
  @override
  List<Object> get props => [activity, timeInterval, newImage];
  EditActivityState copyWith(Activity activity,
      {TimeInterval timeInterval, File newImage});
}

class UnstoredActivityState extends EditActivityState {
  const UnstoredActivityState(Activity activity, TimeInterval timeInterval,
      [File newImage])
      : super(activity, timeInterval, newImage);
  @override
  String toString() =>
      'UnstoredActivityState: {activity: $activity, timeInterval: $timeInterval, newImage: ${newImage?.path}';
  @override
  UnstoredActivityState copyWith(Activity activity,
          {TimeInterval timeInterval, File newImage}) =>
      UnstoredActivityState(activity, timeInterval ?? this.timeInterval,
          newImage ?? this.newImage);
}

class StoredActivityState extends EditActivityState {
  final DateTime day;
  const StoredActivityState(
      Activity activity, TimeInterval timeInterval, this.day,
      [File newImage])
      : super(activity, timeInterval);
  @override
  String toString() =>
      'StoredActivityState: {activity: $activity, timeInterval: $timeInterval, day: $day, newImage: ${newImage?.path}';
  @override
  List<Object> get props => super.props..add(day);

  @override
  StoredActivityState copyWith(Activity activity,
          {TimeInterval timeInterval, File newImage}) =>
      StoredActivityState(activity, timeInterval ?? this.timeInterval, day,
          newImage ?? this.newImage);
}
