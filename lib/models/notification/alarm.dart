import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';

abstract class NotificationAlarm extends Equatable {
  final Activity activity;
  final DateTime day;
  NotificationAlarm(this.activity, this.day)
      : assert(activity != null),
        assert(day != null);
  DateTime notificationTime(DateTime now);
}

class NewAlarm extends NotificationAlarm {
  final bool alarmOnStart;
  NewAlarm(Activity activity, DateTime day, {this.alarmOnStart = true})
      : assert(alarmOnStart != null),
        super(activity, day);
  @override
  List<Object> get props => [activity, alarmOnStart, day];
  @override
  String toString() =>
      'NewAlarm { activity: $activity, day: $day, ${alarmOnStart ? 'START' : 'END'}-alarm }';

  @override
  DateTime notificationTime(DateTime now) =>
      alarmOnStart ? activity.startClock(now) : activity.endClock(now);
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
  String toString() =>
      'NewReminder { activity: $activity, reminder: $reminder, day: $day }';

  @override
  DateTime notificationTime(DateTime now) =>
      activity.startClock(now).subtract(reminder);
}
