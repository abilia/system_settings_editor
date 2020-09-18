part of 'edit_activity_bloc.dart';

enum SaveError {
  NO_START_TIME,
  NO_TITLE_OR_IMAGE,
  START_TIME_BEFORE_NOW,
}

abstract class EditActivityState extends Equatable with Silent {
  const EditActivityState(
    this.activity,
    this.timeInterval,
    this.infoItems, {
    this.originalActivity,
    this.originalTimeInterval,
    this.newImage,
    this.failedSave = false,
  });
  final Activity activity, originalActivity;
  final TimeInterval timeInterval, originalTimeInterval;
  final MapView<Type, InfoItem> infoItems;
  final File newImage;
  final bool failedSave;

  bool get hasTitleOrImage =>
      activity.hasTitle || activity.fileId?.isNotEmpty == true;

  bool get hasStartTime => timeInterval.startTime != null || activity.fullDay;

  bool get unchanged =>
      activity == originalActivity &&
      timeInterval == originalTimeInterval &&
      newImage == newImage;

  @override
  List<Object> get props => [
        activity,
        timeInterval,
        newImage,
        infoItems,
        failedSave,
      ];

  @override
  bool get stringify => true;

  EditActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    ImageUpdate imageUpdate,
    Map<Type, InfoItem> infoItems,
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
          const MapView(<Type, InfoItem>{}),
          originalActivity: activity,
          originalTimeInterval: timeInterval,
          newImage: newImage,
          failedSave: failedSave,
        );

  const UnstoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    MapView<Type, InfoItem> infoItems,
    Activity originalActivity,
    TimeInterval originalTimeInterval, [
    File newImage,
    bool failedSave = false,
  ]) : super(
          activity,
          timeInterval,
          infoItems,
          originalActivity: originalActivity,
          originalTimeInterval: originalTimeInterval,
          newImage: newImage,
          failedSave: failedSave,
        );

  @override
  UnstoredActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    Map<Type, InfoItem> infoItems,
    ImageUpdate imageUpdate,
  }) =>
      UnstoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        MapView(infoItems ?? this.infoItems),
        originalActivity,
        originalTimeInterval,
        imageUpdate == null ? newImage : imageUpdate.updatedImage,
        failedSave,
      );

  @override
  EditActivityState _failSave() => UnstoredActivityState._(
        activity,
        timeInterval,
        infoItems,
        originalActivity,
        originalTimeInterval,
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
          const MapView(<Type, InfoItem>{}),
          originalActivity: activity,
          originalTimeInterval: timeInterval,
          failedSave: false,
        );

  const StoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    Activity originalgActivity,
    TimeInterval originalTimeInterval,
    MapView<Type, InfoItem> infoItems,
    this.day, [
    File newImage,
    bool failedSave,
  ]) : super(
          activity,
          timeInterval,
          infoItems,
          originalActivity: originalgActivity,
          originalTimeInterval: originalTimeInterval,
          newImage: newImage,
          failedSave: failedSave,
        );

  @override
  List<Object> get props => [...super.props, day];

  @override
  StoredActivityState copyWith(
    Activity activity, {
    Map<Type, InfoItem> infoItems,
    TimeInterval timeInterval,
    ImageUpdate imageUpdate,
  }) =>
      StoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        originalActivity,
        originalTimeInterval,
        MapView(infoItems ?? this.infoItems),
        day,
        imageUpdate == null ? newImage : imageUpdate.updatedImage,
        failedSave,
      );

  @override
  EditActivityState _failSave() => StoredActivityState._(
        activity,
        timeInterval,
        activity,
        timeInterval,
        infoItems,
        day,
        newImage,
        true,
      );
}

class ImageUpdate {
  final File updatedImage;

  ImageUpdate(this.updatedImage);
}
