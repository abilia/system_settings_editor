part of 'edit_activity_bloc.dart';

abstract class EditActivityState extends Equatable with Silent {
  const EditActivityState(this.activity, this.timeInterval,
      [this.newImage, this.failedSave]);
  final Activity activity;
  final TimeInterval timeInterval;
  final File newImage;
  final bool failedSave;

  bool get canSave => hasTitleOrImage && hasStartTime;
  bool get hasTitleOrImage =>
      (activity.hasTitle || activity.fileId?.isNotEmpty == true);
  bool get hasStartTime => timeInterval.startTime != null || activity.fullDay;
  @override
  bool get stringify => true;
  @override
  List<Object> get props => [activity, timeInterval, newImage, failedSave];
  EditActivityState copyWith(Activity activity,
      {TimeInterval timeInterval, File newImage});

  EditActivityState _failSave();
}

class UnstoredActivityState extends EditActivityState {
  const UnstoredActivityState(Activity activity, TimeInterval timeInterval,
      [File newImage, bool failedSave = false])
      : super(activity, timeInterval, newImage, failedSave);

  @override
  UnstoredActivityState copyWith(Activity activity,
          {TimeInterval timeInterval, File newImage}) =>
      UnstoredActivityState(activity, timeInterval ?? this.timeInterval,
          newImage ?? this.newImage);

  @override
  EditActivityState _failSave() =>
      UnstoredActivityState(activity, timeInterval, newImage, true);
}

class StoredActivityState extends EditActivityState {
  final DateTime day;
  const StoredActivityState(
      Activity activity, TimeInterval timeInterval, this.day,
      [File newImage, bool failedSave = false])
      : super(activity, timeInterval, newImage, failedSave);

  @override
  List<Object> get props => [...super.props, day];

  @override
  StoredActivityState copyWith(Activity activity,
          {TimeInterval timeInterval, File newImage}) =>
      StoredActivityState(activity, timeInterval ?? this.timeInterval, day,
          newImage ?? this.newImage);

  @override
  EditActivityState _failSave() =>
      StoredActivityState(activity, timeInterval, day, newImage, true);
}
