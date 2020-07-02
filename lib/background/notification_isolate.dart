import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

// Stream is created so that app can respond to notification-selected events since the plugin is initialised in the main function
final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

final _log = Logger('NotificationIsolate');

@visibleForTesting
FlutterLocalNotificationsPlugin notificationsPluginInstance;
FlutterLocalNotificationsPlugin get notificationPlugin {
  ensureNotificationPluginInitialized();
  return notificationsPluginInstance;
}

void ensureNotificationPluginInitialized() {
  if (notificationsPluginInstance == null) {
    notificationsPluginInstance = FlutterLocalNotificationsPlugin();
    notificationsPluginInstance.initialize(
      InitializationSettings(
        AndroidInitializationSettings('@mipmap/ic_launcher'),
        IOSInitializationSettings(),
      ),
      onSelectNotification: (String payload) async {
        if (payload != null) {
          _log.fine('notification payload: ' + payload);
          selectNotificationSubject.add(payload);
        }
      },
    );
  }
}

Future scheduleAlarmNotifications(
  Iterable<Activity> allActivities,
  String language,
  bool alwaysUse24HourFormat,
  FileStorage fileStorage, {
  DateTime now,
}) async {
  now ??= DateTime.now();
  now = now.nextMinute();
  final shouldBeScheduledNotifications =
      allActivities.alarmsFrom(now, take: 50);
  return _scheduleAllAlarmNotifications(
    shouldBeScheduledNotifications,
    language,
    alwaysUse24HourFormat,
    fileStorage,
  );
}

Future scheduleAlarmNotificationsIsolated(
  Iterable<Activity> allActivities,
  String language,
  bool alwaysUse24HourFormat,
  FileStorage fileStorage, {
  DateTime now,
}) async {
  now ??= DateTime.now();
  now = now.nextMinute();
  final serialized =
      allActivities.map((e) => e.wrapWithDbModel().toJson()).toList();
  final shouldBeScheduledNotificationsSerialized =
      await compute(alarmsFromIsolate, [serialized, now]);
  final shouldBeScheduledNotifications =
      shouldBeScheduledNotificationsSerialized
          .map((e) => NotificationAlarm.fromJson(e));
  return _scheduleAllAlarmNotifications(
    shouldBeScheduledNotifications,
    language,
    alwaysUse24HourFormat,
    fileStorage,
  );
}

@visibleForTesting
List<Map<String, dynamic>> alarmsFromIsolate(List<dynamic> args) {
  final serialized = args[0];
  final List<Activity> allActivities =
      serialized.map<Activity>((e) => DbActivity.fromJson(e).activity).toList();
  final now = args[1] as DateTime;
  final notificationAlarms = allActivities.alarmsFrom(now);
  return notificationAlarms.map((e) => e.toJson()).toList();
}

final _lock = Lock();

Future _scheduleAllAlarmNotifications(
  Iterable<NotificationAlarm> notifications,
  String language,
  bool alwaysUse24HourFormat,
  FileStorage fileStorage,
) =>
    // We need the lock because if two pushes comes simultaniusly
    // (that happens when file is uploaded on myAbilia)
    // there is a race condition when adding pictures to notifications.
    // The image being are moved into the attachment data store is gone for the next thread
    _lock.synchronized(
      () async {
        await notificationPlugin.cancelAll();
        _log.fine('schedualing ${notifications.length} notifications...');
        for (final newNotification in notifications) {
          await _scheduleNotification(
            newNotification,
            language,
            alwaysUse24HourFormat,
            fileStorage,
          );
        }
      },
    );

Future _scheduleNotification(
  NotificationAlarm notificationAlarm,
  String language,
  bool alwaysUse24HourFormat,
  FileStorage fileStorage,
) async {
  final activity = notificationAlarm.activity;
  final alarm = activity.alarm;
  final title = activity.title;
  final notificationTime = notificationAlarm.notificationTime;
  final subtitle = _getSubtitle(
    notificationAlarm,
    language,
    alwaysUse24HourFormat,
  );
  final hash = notificationAlarm.hashCode;
  final payload = json.encode(
      NotificationPayload.fromNotificationAlarm(notificationAlarm).toJson());
  final notificationChannel = _getNotificationChannel(alarm);

  final and = AndroidNotificationDetails(
    notificationChannel.id,
    notificationChannel.name,
    notificationChannel.description,
    playSound: alarm.sound,
    importance: Importance.Max,
    priority: Priority.High,
  );

  final iOSAttachment = Platform.isAndroid
      ? null
      : await _getIOSNotificationAttachment(activity, fileStorage);
  final ios = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: alarm.sound,
    attachments: iOSAttachment,
  );

  _log.finest('schedualing: $title - $subtitle at $notificationTime');
  await notificationPlugin.schedule(
    hash,
    title,
    subtitle,
    notificationTime,
    NotificationDetails(and, ios),
    payload: payload,
    androidAllowWhileIdle: true,
    androidWakeScreen: true,
  );
}

NotificationChannel _getNotificationChannel(AlarmType alarm) => alarm.sound
    ? NotificationChannel('Sound + Vibration', 'Sound + Vibration',
        'Activities with Alarm + Vibration or Only Alarm')
    : NotificationChannel('Vibration', 'Vibration',
        'Activities with Only vibration or Silent Alarm');

class NotificationChannel {
  final String id, name, description;
  NotificationChannel(this.id, this.name, this.description);
}

String _getSubtitle(
  NotificationAlarm notificationAlarm,
  String language,
  bool alwaysUse24HourFormat,
) {
  final givenLocale = Locale(language);
  final locale = Locales.language.containsKey(givenLocale)
      ? givenLocale
      : Locales.language.keys.first;
  initializeDateFormatting(locale.languageCode);
  final tf = hourAndMinuteFromUse24(alwaysUse24HourFormat, language);
  final translater = Locales.language[locale];
  final ad = notificationAlarm.activityDay;
  final endTime = ad.activity.hasEndTime ? ' - ${tf(ad.end)} ' : ' ';
  final extra = _getExtra(notificationAlarm, translater);
  return tf(ad.start) + endTime + extra;
}

String _getExtra(NotificationAlarm notificationAlarm, Translated translater) {
  if (notificationAlarm is StartAlarm) return translater.startsNow;
  if (notificationAlarm is EndAlarm) return translater.endsNow;
  if (notificationAlarm is NewReminder) {
    return notificationAlarm.reminder
        .toReminderHeading(translater, notificationAlarm is ReminderBefore);
  }
  return '';
}

Future<List<IOSNotificationAttachment>> _getIOSNotificationAttachment(
    Activity activity, FileStorage fileStorage) async {
  final iOSAttachment = <IOSNotificationAttachment>[];
  if (activity.hasImage) {
    final thumbCopy =
        await fileStorage.copyImageThumbForNotification(activity.fileId);
    if (thumbCopy != null) {
      iOSAttachment.add(
        IOSNotificationAttachment(
          thumbCopy.path,
          identifier: activity.fileId,
        ),
      );
    }
  }
  return iOSAttachment;
}
