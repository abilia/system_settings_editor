import 'dart:async';

import 'package:calendar_events/calendar_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:utils/utils.dart';

final _log = Logger('Notifications');

Future<void> initializeNotificationPlugin() async {
  _log.finer('initializing notification plugin... ');
  await FlutterLocalNotificationsPlugin().initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('icon_notification'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: (notificationResponse) {
      _log.finer(notificationResponse);
    },
  );
  _log.finer('notification plugin initialized');
}

Future cancelPendingNotifications() async {
  final pendingNotifications =
      await FlutterLocalNotificationsPlugin().pendingNotificationRequests();
  for (var notification in pendingNotifications) {
    await FlutterLocalNotificationsPlugin().cancel(notification.id);
  }
}

Future scheduleActivityNotifications(Iterable<Activity> activities) async {
  await cancelPendingNotifications();
  _log.fine('scheduling ${activities.length} notifications...');
  for (final activity in activities) {
    await _scheduleActivityNotification(activity);
  }
}

Future<bool> _scheduleActivityNotification(Activity activity) async {
  final title = activity.title;

  final and = defaultTargetPlatform == TargetPlatform.android
      ? _androidNotificationDetails(activity)
      : null;

  final iOS = defaultTargetPlatform == TargetPlatform.iOS
      ? _iosNotificationDetails(activity)
      : null;
  final startTime = TZDateTime.from(
      activity.startTime, tryGetLocation(activity.timezone, log: _log));
  if (startTime.isBefore(DateTime.now())) return false;

  try {
    _log.fine('scheduling (${activity.hashCode}): $title at $startTime');
    await FlutterLocalNotificationsPlugin().zonedSchedule(
      activity.hashCode,
      title,
      null,
      startTime,
      NotificationDetails(android: and, iOS: iOS),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
    return true;
  } catch (e) {
    _log.severe('could not schedule notification $title\n$e');
    return false;
  }
}

DarwinNotificationDetails _iosNotificationDetails(Activity activity) =>
    const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

AndroidNotificationDetails _androidNotificationDetails(Activity activity) =>
    AndroidNotificationDetails(
      'id',
      'Activities',
      channelDescription: 'Notifications for activities',
      groupKey: activity.seriesId,
      playSound: false,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
    );
