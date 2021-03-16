part of 'edit_activity_bloc.dart';

enum SaveError {
  NO_START_TIME,
  NO_TITLE_OR_IMAGE,
  START_TIME_BEFORE_NOW,
  UNCONFIRMED_START_TIME_BEFORE_NOW,
  NO_RECURRING_DAYS,
  STORED_RECURRING,
}

abstract class EditActivityState extends Equatable with Silent {
  const EditActivityState(
    this.activity,
    this.timeInterval,
    this.infoItems, {
    this.originalActivity,
    this.originalTimeInterval,
    this.newImage,
    this.sucessfullSave,
    this.saveErrors = const UnmodifiableSetView.empty(),
  });

  final Activity activity, originalActivity;
  final TimeInterval timeInterval, originalTimeInterval;
  final MapView<Type, InfoItem> infoItems;
  final File newImage;
  final bool sucessfullSave;
  final UnmodifiableSetView<SaveError> saveErrors;

  bool get hasTitleOrImage =>
      activity.hasTitle || activity.fileId?.isNotEmpty == true;

  bool get hasStartTime => timeInterval.startTime != null || activity.fullDay;

  bool get unchanged =>
      activity == originalActivity &&
      timeInterval == originalTimeInterval &&
      newImage == null;

  bool get storedRecurring =>
      this is StoredActivityState && originalActivity.isRecurring;

  bool get emptyRecurringData =>
      activity.isRecurring && activity.recurs.data <= 0;

  bool startTimeBeforeNow(DateTime now) => activity.fullDay
      ? timeInterval.startDate.onlyDays().isBefore(now.onlyDays())
      : hasStartTime &&
          timeInterval.startDate.withTime(timeInterval.startTime).isBefore(now);

  SelectedImage get selectedImage => SelectedImage(
        id: activity.fileId,
        path: activity.icon,
        file: newImage,
      );

  @override
  List<Object> get props => [
        activity,
        timeInterval,
        newImage,
        infoItems,
        sucessfullSave,
        saveErrors,
      ];

  @override
  bool get stringify => true;

  EditActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    ImageUpdate imageUpdate,
    Map<Type, InfoItem> infoItems,
  });

  EditActivityState failSave(Set<SaveError> saveErrors);
}

class UnstoredActivityState extends EditActivityState {
  const UnstoredActivityState(
    Activity activity,
    TimeInterval timeInterval, {
    File newImage,
  }) : super(
          activity,
          timeInterval,
          const MapView(<Type, InfoItem>{}),
          originalActivity: activity,
          originalTimeInterval: timeInterval,
          newImage: newImage,
        );

  const UnstoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    MapView<Type, InfoItem> infoItems,
    Activity originalActivity,
    TimeInterval originalTimeInterval, {
    File newImage,
    UnmodifiableSetView<SaveError> saveErrors =
        const UnmodifiableSetView.empty(),
    bool sucessfullSave,
  }) : super(
          activity,
          timeInterval,
          infoItems,
          originalActivity: originalActivity,
          originalTimeInterval: originalTimeInterval,
          newImage: newImage,
          sucessfullSave: sucessfullSave,
          saveErrors: saveErrors,
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
        newImage: imageUpdate == null ? newImage : imageUpdate.updatedImage,
      );

  @override
  EditActivityState failSave(Set<SaveError> saveErrors) =>
      UnstoredActivityState._(
        activity,
        timeInterval,
        infoItems,
        originalActivity,
        originalTimeInterval,
        newImage: newImage,
        saveErrors: UnmodifiableSetView(saveErrors),
        sucessfullSave: sucessfullSave == null
            ? false
            : null, // this ugly trick to force state change each failSave
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
        );

  const StoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    Activity originalgActivity,
    TimeInterval originalTimeInterval,
    MapView<Type, InfoItem> infoItems,
    this.day, {
    File newImage,
    bool sucessfullSave,
    UnmodifiableSetView<SaveError> saveErrors =
        const UnmodifiableSetView.empty(),
  }) : super(
          activity,
          timeInterval,
          infoItems,
          originalActivity: originalgActivity,
          originalTimeInterval: originalTimeInterval,
          newImage: newImage,
          sucessfullSave: sucessfullSave,
          saveErrors: saveErrors,
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
        newImage: imageUpdate == null ? newImage : imageUpdate.updatedImage,
      );

  @override
  EditActivityState failSave(Set<SaveError> saveErrors) =>
      StoredActivityState._(
        activity,
        timeInterval,
        originalActivity,
        originalTimeInterval,
        infoItems,
        day,
        newImage: newImage,
        saveErrors: UnmodifiableSetView(saveErrors),
        sucessfullSave: sucessfullSave == null
            ? false
            : null, // this ugly trick to force state change each failSave
      );

  StoredActivityState saveSucess() => StoredActivityState._(
        activity,
        timeInterval,
        activity,
        timeInterval,
        infoItems,
        day,
        newImage: newImage,
        sucessfullSave: true,
      );
}

class ImageUpdate {
  final File updatedImage;

  ImageUpdate(this.updatedImage);
}
