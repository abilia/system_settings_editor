import 'dart:convert';
import 'dart:ui';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

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

Future scheduleAlarmNotifications(Iterable<Activity> allActivities,
    {Duration forDuration = const Duration(hours: 24),
    String language = "en"}) async {
  await notificationPlugin.cancelAll();

  final now = DateTime.now().add(1.minutes()).onlyMinutes();
  final List<NotificationAlarm> shouldBeScheduledNotifications =
      allActivities.alarmsForRange(now, now.add(forDuration)).toList();

  for (final newNotification in shouldBeScheduledNotifications) {
    await scheduleNotification(newNotification, now, language: language);
  }
}

Future scheduleNotification(NotificationAlarm notificationAlarm, DateTime now,
    {String language = "en"}) async {
  final alarm = notificationAlarm.activity.alarm;
  final title = notificationAlarm.activity.title;
  final notificationTime = notificationAlarm.notificationTime(now);
  final subtitle =
      getSubtitle(notificationAlarm, notificationTime, language: language);
  final hash = notificationAlarm.hashCode;
  final payload = json.encode(getPayload(notificationAlarm).toJson());
  final notificationChannel = getNotificationChannel(alarm);

  final and = AndroidNotificationDetails(
    notificationChannel.id,
    notificationChannel.name,
    notificationChannel.description,
    playSound: alarm.sound,
    importance: Importance.Max,
    priority: Priority.High,
  );
  final ios = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: alarm.sound,
  );

  print('''Schedule a notification
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

NotificationPayload getPayload(NotificationAlarm notificationAlarm) {
  final id = notificationAlarm.activity.id;
  if (notificationAlarm is NewAlarm) {
    return NotificationPayload(
      activityId: id,
      onStart: notificationAlarm.alarmOnStart,
    );
  } else if (notificationAlarm is NewReminder) {
    return NotificationPayload(
      activityId: id,
      reminder: notificationAlarm.reminder.inMinutes,
    );
  }
  return NotificationPayload(activityId: id);
}

NotificationChannel getNotificationChannel(AlarmType alarm) => alarm.sound
    ? NotificationChannel('Sound + Vibration', 'Sound + Vibration',
        'Activities with Alarm + Vibration or Only Alarm')
    : NotificationChannel('Vibration', 'Vibration',
        'Activities with Only vibration or Silent Alarm');

class NotificationChannel {
  final String id, name, description;
  NotificationChannel(this.id, this.name, this.description);
}

String getSubtitle(NotificationAlarm notificationAlarm, DateTime day,
    {String language = "en"}) {
  initializeDateFormatting(language);
  final locale = Locale(language);
  final tf = DateFormat('jm', locale.languageCode);
  final translater = Translated.dictionaries.containsKey(locale)
      ? Translated.dictionaries[locale]
      : Translated.dictionaries.values.first;
  final a = notificationAlarm.activity;
  String endTime = a.hasEndTime ? ' - ${tf.format(a.endClock(day))} ' : ' ';
  String extra = notificationAlarm is NewAlarm
      ? (notificationAlarm.alarmOnStart
          ? translater.startsNow
          : translater.endsNow)
      : (notificationAlarm is NewReminder
          ? translater.inMinutes(notificationAlarm.reminder.inMinutes)
          : '');
  return tf.format(a.startClock(day)) + endTime + extra;
}
