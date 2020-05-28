import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

abstract class NotificationAlarm extends Equatable {
  final ActivityDay activityDay;
  DateTime get day => activityDay.day;
  Activity get activity => activityDay.activity;
  NotificationAlarm(this.activityDay) : assert(activityDay != null);
  DateTime get notificationTime;

  Map<String, dynamic> toJson() => {
        'day': day,
        'activity': activity.wrapWithDbModel().toJson(),
        'type': runtimeType,
        if (this is NewReminder) 'reminder': (this as NewReminder).reminder,
      };
  factory NotificationAlarm.fromJson(Map<String, dynamic> json) {
    final activity = DbActivity.fromJson(json['activity']).activity;
    final day = json['day'];
    switch (json['type']) {
      case StartAlarm:
        return StartAlarm(activity, day);
      case EndAlarm:
        return EndAlarm(activity, day);
      case ReminderBefore:
        return ReminderBefore(activity, day, reminder: json['reminder']);
      case ReminderUnchecked:
        return ReminderUnchecked(activity, day, reminder: json['reminder']);
        break;
      default:
        return null;
    }
  }
  @override
  List<Object> get props => [activityDay];
  @override
  bool get stringify => true;
}

abstract class NewAlarm extends NotificationAlarm {
  NewAlarm(ActivityDay activityDay) : super(activityDay);
}

class StartAlarm extends NewAlarm {
  StartAlarm(Activity activity, DateTime day)
      : super(ActivityDay(activity, day));
  StartAlarm.from(ActivityDay activityDay) : super(activityDay);
  @override
  DateTime get notificationTime => activityDay.start;
}

class EndAlarm extends NewAlarm {
  EndAlarm(Activity activity, DateTime day) : super(ActivityDay(activity, day));
  EndAlarm.from(ActivityDay activityDay) : super(activityDay);
  @override
  DateTime get notificationTime => activityDay.end;
}

abstract class NewReminder extends NotificationAlarm {
  final Duration reminder;
  NewReminder(ActivityDay activityDay, this.reminder)
      : assert(reminder != null),
        super(activityDay);
  @override
  List<Object> get props => [reminder, ...super.props];
}

class ReminderBefore extends NewReminder {
  ReminderBefore(Activity activity, DateTime day, {@required Duration reminder})
      : super(ActivityDay(activity, day), reminder);
  ReminderBefore.from(ActivityDay activityDay, {@required Duration reminder})
      : super(activityDay, reminder);
  @override
  DateTime get notificationTime => activityDay.start.subtract(reminder);
}

class ReminderUnchecked extends NewReminder {
  ReminderUnchecked(Activity activity, DateTime day,
      {@required Duration reminder})
      : super(ActivityDay(activity, day), reminder);
  ReminderUnchecked.from(ActivityDay activityDay, {@required Duration reminder})
      : super(activityDay, reminder);
  @override
  DateTime get notificationTime => activityDay.end.add(reminder);
}
