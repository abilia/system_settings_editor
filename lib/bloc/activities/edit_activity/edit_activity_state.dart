part of 'edit_activity_bloc.dart';

abstract class EditActivityState extends Equatable with Finest {
  final Activity activity, ogActivity;
  final TimeInterval timeInterval, ogTimeInterval;
  final File newImage;

  const EditActivityState(
    this.activity,
    this.timeInterval,
    this.ogActivity,
    this.ogTimeInterval, [
    this.newImage,
  ]);

  bool get canSave =>
      (activity.hasTitle || activity.fileId?.isNotEmpty == true) &&
      (timeInterval.startTime != null || activity.fullDay);

  bool get unchanged =>
      activity == ogActivity &&
      timeInterval == ogTimeInterval &&
      newImage == newImage;

  @override
  List<Object> get props => [
        activity,
        timeInterval,
        newImage,
      ];

  @override
  bool get stringify => true;

  EditActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    File newImage,
  });
}

class UnstoredActivityState extends EditActivityState {
  const UnstoredActivityState(Activity activity, TimeInterval timeInterval)
      : super(
          activity,
          timeInterval,
          activity,
          timeInterval,
        );

  const UnstoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    Activity ogActivity,
    TimeInterval ogTimeInterval, [
    File newImage,
  ]) : super(
          activity,
          timeInterval,
          ogActivity,
          ogTimeInterval,
          newImage,
        );

  @override
  UnstoredActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    File newImage,
  }) =>
      UnstoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        ogActivity,
        ogTimeInterval,
        newImage ?? this.newImage,
      );
}

class StoredActivityState extends EditActivityState {
  final DateTime day;

  const StoredActivityState(
    Activity activity,
    TimeInterval timeInterval,
    this.day,
  ) : super(
          activity,
          timeInterval,
          activity,
          timeInterval,
        );

  const StoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    Activity ogActivity,
    TimeInterval ogTimeInterval,
    this.day, [
    File newImage,
  ]) : super(
          activity,
          timeInterval,
          ogActivity,
          ogTimeInterval,
          newImage,
        );

  @override
  List<Object> get props => [...super.props, day];

  @override
  StoredActivityState copyWith(Activity activity,
          {TimeInterval timeInterval, File newImage}) =>
      StoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        ogActivity,
        ogTimeInterval,
        day,
        newImage ?? this.newImage,
      );
}
