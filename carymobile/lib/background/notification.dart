import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:seagull_logging/seagull_logging.dart';
import 'package:utils/utils.dart';

final _log = Logger('Notifications');

Future<FlutterLocalNotificationsPlugin>
    initFlutterLocalNotificationsPlugin() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('icon_notification'),
    ),
    onDidReceiveNotificationResponse: (notificationResponse) => _log.finer(
      'clicked on notification, payload: ${notificationResponse.payload}',
    ),
  );
  return flutterLocalNotificationsPlugin;
}

Future<void> scheduleNextAlarm(
  FlutterLocalNotificationsPlugin plugin,
  ActivityDay activity,
) async {
  await plugin.cancelAll();
  final startTime = TZDateTime.from(
    activity.start,
    tryGetLocation(activity.activity.timezone),
  );
  await plugin.zonedSchedule(
    activity.hashCode,
    activity.title,
    null,
    startTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'CARY Mobile',
        'Activities',
        channelDescription: 'Notifications for activities',
        playSound: false,
        enableVibration: false,
        showNotification: false,
        startActivityClassName: 'com.abilia.carymessenger.MainActivity',
        importance: Importance.max,
        priority: Priority.high,
        category: AndroidNotificationCategory.alarm,
        channelAction: AndroidNotificationChannelAction.createIfNotExists,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.alarmClock,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.wallClockTime,
  );
}
