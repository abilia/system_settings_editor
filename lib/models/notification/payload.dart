import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class NotificationPayload extends Equatable {
  final String activityId;
  final int reminder;
  final bool onStart;
  final DateTime day;

  NotificationPayload({
    @required this.activityId,
    @required this.day,
    @required this.onStart,
    int reminder,
  }) : reminder = reminder ?? -1;
  factory NotificationPayload.fromJson(Map<String, dynamic> json) =>
      NotificationPayload(
        activityId: json['activityId'],
        reminder: json['reminder'],
        onStart: json['onStart'],
        day: DateTime.parse(json['day']),
      );
  Map<String, dynamic> toJson() => {
        'activityId': activityId,
        'reminder': reminder,
        'onStart': onStart,
        'day': day.toIso8601String(),
      };
  @override
  String toString() =>
      'Payload: { $activityId, reminder: $reminder, onStart: $onStart, day: $day}';
  @override
  List<Object> get props => [activityId, reminder, onStart, day];

  factory NotificationPayload.fromNotificationAlarm(
      NotificationAlarm notificationAlarm) {
    final id = notificationAlarm.activity.id;
    final day = notificationAlarm.day;
    if (notificationAlarm is NewAlarm) {
      return NotificationPayload(
        activityId: id,
        day: day,
        onStart: notificationAlarm is StartAlarm,
      );
    }
    if (notificationAlarm is NewReminder) {
      return NotificationPayload(
          activityId: id,
          day: day,
          reminder: notificationAlarm.reminder.inMinutes,
          onStart: notificationAlarm is ReminderBefore);
    }
    return NotificationPayload(activityId: id, day: day, onStart: false);
  }

  NotificationAlarm getAlarm(Activity activity) {
    if (reminder > 0) {
      return onStart
          ? ReminderBefore(activity, day, reminder: reminder.minutes())
          : ReminderUnchecked(activity, day, reminder: reminder.minutes());
    }
    return onStart ? StartAlarm(activity, day) : EndAlarm(activity, day);
  }
}
