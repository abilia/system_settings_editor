part of 'activities_bloc.dart';

abstract class ActivitiesEvent extends Equatable {
  const ActivitiesEvent();

  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

class LoadActivities extends ActivitiesEvent {}

abstract class ManipulateActivitiesEvent extends ActivitiesEvent {
  const ManipulateActivitiesEvent();
  Activity get activity;
  @override
  List<Object> get props => [activity];
}

class AddActivity extends ManipulateActivitiesEvent implements AnalyticEvent {
  @override
  final Activity activity;
  const AddActivity(this.activity);

  @override
  String get eventName => 'Activity created';

  @override
  Map<String, dynamic>? get properties => {
        'title': activity.hasTitle,
        'image': activity.hasImage,
        'startTime': activity.startTime.toIso8601String(),
        'noneRecurringEnd': activity.noneRecurringEnd.toIso8601String(),
        'duration': '${activity.duration}',
        'timezone': activity.timezone,
        'fullDay': activity.fullDay,
        'category': activity.category,
        'checkable': activity.checkable,
        'availableFor': activity.availableFor.name,
        'secretExemptions': activity.secretExemptions.length,
        'alarmType': activity.alarm.type.name,
        'onlyStart': activity.alarm.onlyStart,
        'reminders': activity.reminders.map((d) => '$d').toList(),
        'removeAfter': activity.removeAfter,
        'speechAtStartTime': activity.extras.startTimeExtraAlarm.isNotEmpty,
        'speechAtEndTime': activity.extras.endTimeExtraAlarm.isNotEmpty,
        'recurring': activity.recurs.recurrence.name,
        'recurringHasNoEnd': activity.recurs.hasNoEnd,
        'infoItem': activity.infoItem.typeId,
      };
}

class UpdateActivity extends ManipulateActivitiesEvent {
  @override
  final Activity activity;
  const UpdateActivity(this.activity);
}

abstract class RecurringActivityEvent extends ManipulateActivitiesEvent {
  final ActivityDay activityDay;
  final ApplyTo applyTo;
  DateTime get day => activityDay.day;
  @override
  Activity get activity => activityDay.activity;
  const RecurringActivityEvent(this.activityDay, this.applyTo);
  @override
  List<Object> get props => [activityDay];
}

class UpdateRecurringActivity extends RecurringActivityEvent {
  const UpdateRecurringActivity(ActivityDay activityDay, ApplyTo applyTo)
      : assert(applyTo != ApplyTo.allDays),
        super(activityDay, applyTo);
}

class DeleteRecurringActivity extends RecurringActivityEvent {
  const DeleteRecurringActivity(ActivityDay activityDay, ApplyTo applyTo)
      : super(activityDay, applyTo);
}
