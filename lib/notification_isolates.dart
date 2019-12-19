import 'dart:convert';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/models.dart';
import 'package:seagull/utils.dart';

// Stream is created so that app can respond to notification-selected events since the plugin is initialised in the main function
final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

FlutterLocalNotificationsPlugin _notificationsPlugin;
FlutterLocalNotificationsPlugin get notificationPlugin {
  ensureNotificationPluginInitialized();
  return _notificationsPlugin;
}

void ensureNotificationPluginInitialized() {
  if (_notificationsPlugin == null) {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _notificationsPlugin.initialize(
      InitializationSettings(
        AndroidInitializationSettings('@mipmap/ic_launcher'),
        IOSInitializationSettings(),
      ),
      onSelectNotification: (String payload) async {
        if (payload != null) {
          print('notification payload: ' + payload);
          selectNotificationSubject.add(payload);
        }
      },
    );
  }
}

Future schedualAlarmNotifications(Iterable<Activity> allActivities,
    {Duration forDuration = const Duration(hours: 24)}) async {
  await notificationPlugin.cancelAll();

  final now = DateTime.now().add(1.minutes()).onlyMinutes();
  final List<NotificationAlarm> shouldBeScheduledNotifications =
      allActivities.alarmsFor(now, end: now.add(forDuration)).toList();

  for (final newNotification in shouldBeScheduledNotifications) {
    await schedualNotification(newNotification, now);
  }
}

Future schedualNotification(
    NotificationAlarm notificationAlarm, DateTime now) async {
  final alarm = notificationAlarm.activity.alarm;
  final title = notificationAlarm.activity.title;
  final notificationTime = notificationAlarm.notificationTime(now);
  final subtitle = getSubtitle(notificationAlarm, notificationTime);
  final hash = notificationAlarm.hashCode;
  final payload = json.encode(getPayload(notificationAlarm).toJson());

  final and = AndroidNotificationDetails(
    notificationChannelName(alarm),
    notificationChannelName(alarm),
    notificationChannelName(alarm),
    playSound: alarm.sound,
    enableVibration: alarm.vibrate,
    importance: Importance.Max,
    priority: Priority.High,
  );
  final ios = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: alarm.sound,
  );

  print('''Schedual a notification
    ${hash}
    $notificationTime'
    ${title} /// $subtitle
    payload: $payload''');

  await notificationPlugin.schedule(
    hash,
    title,
    subtitle,
    notificationTime,
    NotificationDetails(and, ios),
    payload: payload,
    androidAllowWhileIdle: true,
  );
}

Payload getPayload(NotificationAlarm notificationAlarm) {
  final id = notificationAlarm.activity.id;
  if (notificationAlarm is NewAlarm) {
    return Payload(
      activityId: id,
      onStart: notificationAlarm.alarmOnStart,
    );
  } else if (notificationAlarm is NewReminder) {
    return Payload(
      activityId: id,
      reminder: notificationAlarm.reminder.inMinutes,
    );
  }
  return Payload(activityId: id);
}

String notificationChannelName(AlarmType alarm) =>
    'seagulls notifications${alarm.sound ? ' sound' : ''} ${alarm.vibrate ? ' vibration' : ''}';

String getSubtitle(NotificationAlarm notificationAlarm, DateTime day) {
  final locale = Locale.cachedLocale;
  final tf = DateFormat('jm', locale.languageCode);
  final translater = Translated.dictionaries.containsKey(locale)
      ? Translated.dictionaries[locale]
      : Translated.dictionaries.values.first;
  final a = notificationAlarm.activity;
  String endTime = a.hasEndTime ? ' - ${tf.format(a.endClock(day))} ' : '';
  String extra = notificationAlarm is NewAlarm
      ? (notificationAlarm.alarmOnStart
          ? translater.startsNow
          : translater.endsNow)
      : (notificationAlarm is NewReminder
          ? translater.inMinutes(notificationAlarm.reminder.inMinutes)
          : '');
  return tf.format(a.startClock(day)) + endTime + extra;
}
