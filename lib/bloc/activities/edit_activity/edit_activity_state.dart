part of 'edit_activity_bloc.dart';

abstract class EditActivityState extends Equatable with Silent {
  const EditActivityState(
    this.activity,
    this.timeInterval, {
    this.ogActivity,
    this.ogTimeInterval,
    this.newImage,
    this.failedSave = false,
  });
  final Activity activity, ogActivity;
  final TimeInterval timeInterval, ogTimeInterval;
  final File newImage;
  final bool failedSave;

  bool get canSave => hasTitleOrImage && hasStartTime;

  bool get hasTitleOrImage =>
      activity.hasTitle || activity.fileId?.isNotEmpty == true;

  bool get hasStartTime => timeInterval.startTime != null || activity.fullDay;

  bool get unchanged =>
      activity == ogActivity &&
      timeInterval == ogTimeInterval &&
      newImage == newImage;

  @override
  List<Object> get props => [
        activity,
        timeInterval,
        newImage,
        failedSave,
      ];

  @override
  bool get stringify => true;

  EditActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    File newImage,
  });

  EditActivityState _failSave();
}

class UnstoredActivityState extends EditActivityState {
  const UnstoredActivityState(
    Activity activity,
    TimeInterval timeInterval, [
    File newImage,
    bool failedSave = false,
  ]) : super(
          activity,
          timeInterval,
          ogActivity: activity,
          ogTimeInterval: timeInterval,
          newImage: newImage,
          failedSave: failedSave,
        );

  const UnstoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    Activity ogActivity,
    TimeInterval ogTimeInterval, [
    File newImage,
    bool failedSave = false,
  ]) : super(
          activity,
          timeInterval,
          ogActivity: ogActivity,
          ogTimeInterval: ogTimeInterval,
          newImage: newImage,
          failedSave: failedSave,
        );

  @override
  UnstoredActivityState copyWith(Activity activity,
          {TimeInterval timeInterval, File newImage}) =>
      UnstoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        ogActivity,
        ogTimeInterval,
        newImage ?? this.newImage,
        failedSave,
      );

  @override
  EditActivityState _failSave() => UnstoredActivityState._(
        activity,
        timeInterval,
        ogActivity,
        ogTimeInterval,
        newImage,
        true,
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
          ogActivity: activity,
          ogTimeInterval: timeInterval,
          failedSave: false,
        );

  const StoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    Activity ogActivity,
    TimeInterval ogTimeInterval,
    this.day, [
    File newImage,
    bool failedSave,
  ]) : super(
          activity,
          timeInterval,
          ogActivity: ogActivity,
          ogTimeInterval: ogTimeInterval,
          newImage: newImage,
          failedSave: false,
        );

  @override
  List<Object> get props => [...super.props, day];

  @override
  StoredActivityState copyWith(Activity activity,
          {TimeInterval timeInterval, File newImage}) =>
      StoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        this.activity,
        this.timeInterval,
        day,
        newImage ?? this.newImage,
        failedSave,
      );

  @override
  EditActivityState _failSave() => StoredActivityState._(
        activity,
        timeInterval,
        activity,
        timeInterval,
        day,
        newImage,
        true,
      );
}
