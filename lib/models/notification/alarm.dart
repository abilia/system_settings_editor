import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models.dart';

abstract class NotificationAlarm extends Equatable {
  final Activity activity;
  NotificationAlarm(this.activity) : assert(activity != null);
  DateTime notificationTime(DateTime now);
}

class NewAlarm extends NotificationAlarm {
  final bool alarmOnStart;
  NewAlarm(Activity activity, {this.alarmOnStart = true})
      : assert(alarmOnStart != null),
        super(activity);
  @override
  List<Object> get props => [activity.id, alarmOnStart];
  @override
  String toString() =>
      'NewAlarm { activity: $activity, ${alarmOnStart ? 'START' : 'END'}-alarm }';

  @override
  DateTime notificationTime(DateTime now) =>
      alarmOnStart ? activity.startClock(now) : activity.endClock(now);
}

class NewReminder extends NotificationAlarm {
  final Duration reminder;
  NewReminder(Activity activity, {@required this.reminder})
      : assert(reminder != null),
        assert(reminder > Duration.zero),
        super(activity);
  @override
  List<Object> get props => [activity.id, reminder];
  @override
  String toString() =>
      'NewReminder { activity: $activity, reminder: $reminder }';

  @override
  DateTime notificationTime(DateTime now) =>
      activity.startClock(now).subtract(reminder);
}
