part of 'edit_activity_bloc.dart';

enum SaveError {
  NO_START_TIME,
  NO_TITLE_OR_IMAGE,
  START_TIME_BEFORE_NOW,
  UNCONFIRMED_START_TIME_BEFORE_NOW,
  UNCONFIRMED_ACTIVITY_CONFLICT,
  NO_RECURRING_DAYS,
  STORED_RECURRING,
}

abstract class EditActivityState extends Equatable with Silent {
  const EditActivityState(
    this.activity,
    this.timeInterval,
    this.infoItems, {
    required this.originalActivity,
    required this.originalTimeInterval,
    this.sucessfullSave,
    this.saveErrors = const UnmodifiableSetView.empty(),
  });

  final Activity activity, originalActivity;
  final TimeInterval timeInterval, originalTimeInterval;
  final MapView<Type, InfoItem> infoItems;
  final bool? sucessfullSave;
  final UnmodifiableSetView<SaveError> saveErrors;

  bool get hasTitleOrImage => activity.hasTitle || activity.hasImage;

  bool get hasStartTime => timeInterval.startTime != null || activity.fullDay;

  bool get unchanged =>
      activity == originalActivity && timeInterval == originalTimeInterval;

  bool get unchangedTime =>
      this is StoredActivityState &&
      timeInterval == originalTimeInterval &&
      originalActivity.recurs == activity.recurs;

  bool get storedRecurring =>
      this is StoredActivityState && originalActivity.isRecurring;

  bool get emptyRecurringData =>
      activity.isRecurring && activity.recurs.data <= 0;

  bool startTimeBeforeNow(DateTime now) => activity.fullDay
      ? timeInterval.startDate.onlyDays().isBefore(now.onlyDays())
      : hasStartTime && timeInterval.starts.isBefore(now);

  AbiliaFile get selectedImage => AbiliaFile.from(
        id: activity.fileId,
        path: activity.icon,
      );

  Activity _activityToStore() {
    var storeActivity = (activity.hasAttachment && activity.infoItem.isEmpty)
        ? activity.copyWith(infoItem: InfoItem.none)
        : activity;

    if (activity.fullDay) {
      return storeActivity.copyWith(
        startTime: timeInterval.startDate.onlyDays(),
        alarmType: NO_ALARM,
        reminderBefore: const [],
      );
    }

    final startTime = timeInterval.starts;
    return storeActivity.copyWith(
      startTime: startTime,
      duration: _getDuration(startTime, timeInterval.endTime),
    );
  }

  Duration _getDuration(DateTime? startTime, TimeOfDay? endTime) {
    if (startTime == null || endTime == null) return Duration.zero;
    final pickedEndTimeBeforeStartTime = endTime.hour < startTime.hour ||
        endTime.hour == startTime.hour && endTime.minute < startTime.minute;

    return pickedEndTimeBeforeStartTime
        ? startTime
            .copyWith(
              day: startTime.day + 1,
              hour: endTime.hour,
              minute: endTime.minute,
            )
            .difference(startTime)
        : Duration(
            hours: endTime.hour - startTime.hour,
            minutes: endTime.minute - startTime.minute,
          );
  }

  @override
  List<Object?> get props => [
        activity,
        timeInterval,
        infoItems,
        sucessfullSave,
        saveErrors,
      ];

  @override
  bool get stringify => true;

  EditActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    Map<Type, InfoItem> infoItems,
  });

  EditActivityState failSave(Set<SaveError> saveErrors);
}

class UnstoredActivityState extends EditActivityState {
  const UnstoredActivityState(
    Activity activity,
    TimeInterval timeInterval,
  ) : super(
          activity,
          timeInterval,
          const MapView(<Type, InfoItem>{}),
          originalActivity: activity,
          originalTimeInterval: timeInterval,
        );

  const UnstoredActivityState._(
    Activity activity,
    TimeInterval timeInterval,
    MapView<Type, InfoItem> infoItems,
    Activity originalActivity,
    TimeInterval originalTimeInterval, {
    UnmodifiableSetView<SaveError> saveErrors =
        const UnmodifiableSetView.empty(),
    bool? sucessfullSave,
  }) : super(
          activity,
          timeInterval,
          infoItems,
          originalActivity: originalActivity,
          originalTimeInterval: originalTimeInterval,
          sucessfullSave: sucessfullSave,
          saveErrors: saveErrors,
        );

  @override
  UnstoredActivityState copyWith(
    Activity activity, {
    TimeInterval? timeInterval,
    Map<Type, InfoItem>? infoItems,
  }) =>
      UnstoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        MapView(infoItems ?? this.infoItems),
        originalActivity,
        originalTimeInterval,
      );

  @override
  EditActivityState failSave(Set<SaveError> saveErrors) =>
      UnstoredActivityState._(
        activity,
        timeInterval,
        infoItems,
        originalActivity,
        originalTimeInterval,
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
    bool? sucessfullSave,
    UnmodifiableSetView<SaveError> saveErrors =
        const UnmodifiableSetView.empty(),
  }) : super(
          activity,
          timeInterval,
          infoItems,
          originalActivity: originalgActivity,
          originalTimeInterval: originalTimeInterval,
          sucessfullSave: sucessfullSave,
          saveErrors: saveErrors,
        );

  @override
  List<Object?> get props => [...super.props, day];

  @override
  StoredActivityState copyWith(
    Activity activity, {
    Map<Type, InfoItem>? infoItems,
    TimeInterval? timeInterval,
  }) =>
      StoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        originalActivity,
        originalTimeInterval,
        MapView(infoItems ?? this.infoItems),
        day,
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
        sucessfullSave: true,
      );
}
