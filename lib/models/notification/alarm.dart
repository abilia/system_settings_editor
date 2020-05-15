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
        if (this is NewAlarm) 'alarmOnStart': (this as NewAlarm).alarmOnStart,
        if (this is NewReminder) 'reminder': (this as NewReminder).reminder,
      };
  factory NotificationAlarm.fromJson(Map<String, dynamic> json) {
    final activity = DbActivity.fromJson(json['activity']).activity;
    switch (json['type']) {
      case NewAlarm:
        return NewAlarm(
          activity,
          json['day'],
          alarmOnStart: json['alarmOnStart'],
        );
      case NewReminder:
        return NewReminder(
          activity,
          json['day'],
          reminder: json['reminder'],
        );
        break;
      default:
        return null;
    }
  }
}

class NewAlarm extends NotificationAlarm {
  final bool alarmOnStart;
  NewAlarm(Activity activity, DateTime day, {this.alarmOnStart = true})
      : assert(alarmOnStart != null),
        super(activity, day);
  @override
  List<Object> get props => [activity, alarmOnStart, day];
  @override
  bool get stringify => true;

  @override
  DateTime get notificationTime =>
      alarmOnStart ? activity.startClock(day) : activity.endClock(day);
}

class NewReminder extends NotificationAlarm {
  final Duration reminder;
  NewReminder(Activity activity, DateTime day, {@required this.reminder})
      : assert(reminder != null),
        assert(reminder > Duration.zero),
        super(activity, day);
  @override
  List<Object> get props => [activity, reminder, day];
  @override
  bool get stringify => true;
  @override
  DateTime get notificationTime => activity.startClock(day).subtract(reminder);
}
