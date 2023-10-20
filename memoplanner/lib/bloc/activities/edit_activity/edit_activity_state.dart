part of 'edit_activity_cubit.dart';

abstract class EditActivityState extends Equatable with Finest {
  const EditActivityState(
    this.activity,
    this.timeInterval, {
    required this.originalActivity,
    required this.originalTimeInterval,
    required this.selectedRecurrentType,
  });

  final Activity activity, originalActivity;
  final RecurrentType selectedRecurrentType;
  final TimeInterval timeInterval, originalTimeInterval;

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
        endDate.millisecondsSinceEpoch >= noEnd &&
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
        selectedRecurrentType,
      ];

  @override
  bool get stringify => true;

  EditActivityState copyWith(
    Activity activity, {
    TimeInterval timeInterval,
    RecurrentType selectedRecurrentType,
  });
}

class UnstoredActivityState extends EditActivityState {
  const UnstoredActivityState(
    super.activity,
    super.timeInterval,
    RecurrentType selectedRecurrentType,
  ) : super(
          originalActivity: activity,
          originalTimeInterval: timeInterval,
          selectedRecurrentType: selectedRecurrentType,
        );

  const UnstoredActivityState._(
    super.activity,
    super.timeInterval,
    Activity originalActivity,
    TimeInterval originalTimeInterval,
    RecurrentType selectedRecurrentType,
  ) : super(
          originalActivity: originalActivity,
          originalTimeInterval: originalTimeInterval,
          selectedRecurrentType: selectedRecurrentType,
        );

  @override
  UnstoredActivityState copyWith(
    Activity activity, {
    TimeInterval? timeInterval,
    RecurrentType? selectedRecurrentType,
  }) =>
      UnstoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        originalActivity,
        originalTimeInterval,
        selectedRecurrentType ?? this.selectedRecurrentType,
      );
}

class StoredActivityState extends EditActivityState {
  final DateTime day;

  const StoredActivityState(
    super.activity,
    super.timeInterval,
    this.day,
    RecurrentType recurrentType,
  ) : super(
          originalActivity: activity,
          originalTimeInterval: timeInterval,
          selectedRecurrentType: recurrentType,
        );

  const StoredActivityState._(
    super.activity,
    super.timeInterval,
    Activity originalActivity,
    TimeInterval originalTimeInterval,
    this.day,
    RecurrentType recurrentType,
  ) : super(
          originalActivity: originalActivity,
          originalTimeInterval: originalTimeInterval,
          selectedRecurrentType: recurrentType,
        );

  @override
  List<Object?> get props => [...super.props, day];

  @override
  StoredActivityState copyWith(
    Activity activity, {
    TimeInterval? timeInterval,
    RecurrentType? selectedRecurrentType,
  }) =>
      StoredActivityState._(
        activity,
        timeInterval ?? this.timeInterval,
        originalActivity,
        originalTimeInterval,
        day,
        selectedRecurrentType ?? this.selectedRecurrentType,
      );
}
