part of 'edit_activity_cubit.dart';

abstract class EditActivityState extends Equatable with Finest {
  const EditActivityState(
    this.activity,
    this.timeInterval,
    this.infoItems, {
    required this.originalActivity,
    required this.originalTimeInterval,
  });

  final Activity activity, originalActivity;
  final TimeInterval timeInterval, originalTimeInterval;
  final MapView<Type, InfoItem> infoItems;

  bool get hasTitleOrImage => activity.hasTitle || activity.hasImage;

  bool get hasStartTime => timeInterval.startTime != null || activity.fullDay;

  bool get unchanged =>
      activity == originalActivity && timeInterval == originalTimeInterval;

  bool get unchangedTime =>
      this is StoredActivityState &&
      timeInterval == originalTimeInterval &&
      originalActivity.recurs == activity.recurs;

  bool get unchangedDate =>
      this is StoredActivityState &&
      timeInterval.startDate == originalTimeInterval.startDate;

  bool get storedRecurring =>
      this is StoredActivityState && originalActivity.isRecurring;

  bool get emptyRecurringData =>
      activity.isRecurring && activity.recurs.data <= 0;

  bool startDateBeforeNow(DateTime now) =>
      timeInterval.startDate.onlyDays().isBefore(now.onlyDays());

  bool startTimeBeforeNow(DateTime now) => activity.fullDay
      ? timeInterval.startDate.onlyDays().isBefore(now.onlyDays())
      : hasStartTime && timeInterval.starts.isBefore(now);

  bool get hasEndDate => timeInterval.endDate != null;

  bool get recursWithNoEnd {
    final endDate = timeInterval.endDate;
    return activity.isRecurring &&
        endDate != null &&
        endDate.millisecondsSinceEpoch >= Recurs.noEnd &&
        activity.recurs.hasNoEnd;
  }

  AbiliaFile get selectedImage => AbiliaFile.from(
        id: activity.fileId,
        path: activity.icon,
      );

  Activity activityToStore() {
    final storeActivity = (activity.hasAttachment && activity.infoItem.isEmpty)
        ? activity.copyWith(infoItem: InfoItem.none)
        : activity;

    if (activity.fullDay) {
      return storeActivity.copyWith(
        startTime: timeInterval.startDate.onlyDays(),
        alarmType: noAlarm,
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
      ];

  @override
  bool get stringify => true;

  EditActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    Map<Type, InfoItem> infoItems,
  });
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
    TimeInterval originalTimeInterval,
  ) : super(
          activity,
          timeInterval,
          infoItems,
          originalActivity: originalActivity,
          originalTimeInterval: originalTimeInterval,
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
    this.day,
  ) : super(
          activity,
          timeInterval,
          infoItems,
          originalActivity: originalgActivity,
          originalTimeInterval: originalTimeInterval,
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
}
