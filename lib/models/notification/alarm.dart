import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

abstract class NotificationAlarm extends Equatable {
  final Activity activity;
  final DateTime day;
  NotificationAlarm(this.activity, this.day)
      : assert(activity != null),
        assert(day != null);
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
  bool get stringify => true;
}

abstract class NewAlarm extends NotificationAlarm {
  NewAlarm(Activity activity, DateTime day) : super(activity, day);
  @override
  List<Object> get props => [activity, day];
}

class StartAlarm extends NewAlarm {
  StartAlarm(Activity activity, DateTime day) : super(activity, day);
  @override
  DateTime get notificationTime => activity.startClock(day);
}

class EndAlarm extends NewAlarm {
  EndAlarm(Activity activity, DateTime day) : super(activity, day);
  @override
  DateTime get notificationTime => activity.endClock(day);
}

abstract class NewReminder extends NotificationAlarm {
  final Duration reminder;
  NewReminder(Activity activity, DateTime day, {@required this.reminder})
      : assert(reminder != null),
        super(activity, day);
  @override
  List<Object> get props => [activity, reminder, day];
}

class ReminderBefore extends NewReminder {
  ReminderBefore(Activity activity, DateTime day, {@required Duration reminder})
      : super(activity, day, reminder: reminder);
  @override
  DateTime get notificationTime => activity.startClock(day).subtract(reminder);
}

class ReminderUnchecked extends NewReminder {
  ReminderUnchecked(Activity activity, DateTime day,
      {@required Duration reminder})
      : super(activity, day, reminder: reminder);
  @override
  DateTime get notificationTime => activity.endClock(day).add(reminder);
}
