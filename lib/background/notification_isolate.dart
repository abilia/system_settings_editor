import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:synchronized/synchronized.dart';

import 'package:seagull/repository/timezone.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';

import 'package:seagull/utils/all.dart';

// Stream is created so that app can respond to notification-selected events since the plugin is initialised in the main function
ReplaySubject<String> get selectNotificationSubject =>
    _selectNotificationSubject;
ReplaySubject<String> _selectNotificationSubject = ReplaySubject<String>();

Future<void> clearNotificationSubject() async {
  await _selectNotificationSubject.close();
  _selectNotificationSubject = ReplaySubject<String>();
}

final _log = Logger('NotificationIsolate');

@visibleForTesting
FlutterLocalNotificationsPlugin notificationsPluginInstance;
FlutterLocalNotificationsPlugin get notificationPlugin {
  ensureNotificationPluginInitialized();
  return notificationsPluginInstance;
}

void ensureNotificationPluginInitialized() {
  if (notificationsPluginInstance == null) {
    _log.finer('initialize notification plugin... ');
    notificationsPluginInstance = FlutterLocalNotificationsPlugin();
    notificationsPluginInstance.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: IOSInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        ),
      ),
      onSelectNotification: (String payload) async {
        if (payload != null) {
          _log.fine('notification payload: ' + payload);
          selectNotificationSubject.add(payload);
        }
      },
    );
    _log.finer('notification plugin initialize');
  }
}

Future scheduleAlarmNotifications(
  Iterable<Activity> allActivities,
  String language,
  bool alwaysUse24HourFormat,
  FileStorage fileStorage, {
  DateTime Function() now,
}) async {
  now ??= () => DateTime.now();
  final _now = now().nextMinute();
  final shouldBeScheduledNotifications = allActivities.alarmsFrom(_now);
  return _scheduleAllAlarmNotifications(
    shouldBeScheduledNotifications,
    language,
    alwaysUse24HourFormat,
    fileStorage,
    now,
  );
}

Future scheduleAlarmNotificationsIsolated(
  Iterable<Activity> allActivities,
  String language,
  bool alwaysUse24HourFormat,
  FileStorage fileStorage, {
  DateTime Function() now,
}) async {
  now ??= () => DateTime.now();
  final _now = now().nextMinute();
  final serialized =
      allActivities.map((e) => e.wrapWithDbModel().toJson()).toList();
  final shouldBeScheduledNotificationsSerialized =
      await compute(alarmsFromIsolate, [serialized, _now]);
  final shouldBeScheduledNotifications =
      shouldBeScheduledNotificationsSerialized
          .map((e) => NotificationAlarm.fromJson(e));
  return _scheduleAllAlarmNotifications(
    shouldBeScheduledNotifications,
    language,
    alwaysUse24HourFormat,
    fileStorage,
    now,
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
  DateTime Function() now,
) =>
    // We need the lock because if two pushes comes simultaniusly
    // (that happens when file is uploaded on myAbilia)
    // there is a race condition when adding pictures to notifications.
    // The image being are moved into the attachment data store is gone for the next thread
    _lock.synchronized(
      () async {
        await notificationPlugin.cancelAll();
        _log.fine('scheduling ${notifications.length} notifications...');
        final notificationTimes = <DateTime>{};
        var scheduled = 0;
        for (final newNotification in notifications) {
          if (await _scheduleNotification(
            newNotification,
            language,
            alwaysUse24HourFormat,
            fileStorage,
            now,
            // Adding a delay on simultaneous alarms to let the selectNotificationSubject handle them
            notificationTimes.add(newNotification.notificationTime) ? 0 : 3,
          )) scheduled++;
        }
        _log.info('$scheduled notifications scheduled');
      },
    );

Future<bool> _scheduleNotification(
  NotificationAlarm notificationAlarm,
  String language,
  bool alwaysUse24HourFormat,
  FileStorage fileStorage,
  DateTime Function() now, [
  int secondsOffset = 0,
]) async {
  final activity = notificationAlarm.activity;
  final title = activity.title;
  final notificationTime =
      notificationAlarm.notificationTime.add(secondsOffset.seconds());
  final subtitle = _subtitle(
    notificationAlarm,
    language,
    alwaysUse24HourFormat,
  );
  final hash = notificationAlarm.hashCode;
  final payload = notificationAlarm.encode();

  final and = Platform.isIOS
      ? null
      : await _androidNotificationDetails(
          notificationAlarm, fileStorage, title, subtitle);

  final ios = Platform.isAndroid
      ? null
      : await _iosNotificationDetails(notificationAlarm, fileStorage);

  if (notificationTime.isBefore(now())) return false;
  final time = TZDateTime.from(
      notificationTime, tryGetLocation(activity.timezone, log: _log));
  try {
    _log.finest(
        'scheduling: $title - $subtitle at $time ${activity.hasImage ? ' with image' : ''}');
    await notificationPlugin.zonedSchedule(
      hash,
      title,
      subtitle,
      time,
      NotificationDetails(android: and, iOS: ios),
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
    );
    return true;
  } catch (e) {
    _log.warning('could not schedual $payload', e);
    return false;
  }
}

Future<IOSNotificationDetails> _iosNotificationDetails(
    NotificationAlarm notificationAlarm, FileStorage fileStorage) async {
  final activity = notificationAlarm.activity;
  final alarm = activity.alarm;
  return IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: alarm.sound || alarm.vibrate,
    sound: alarm.vibrate && !alarm.sound ? 'silent.aiff' : null,
    attachments: await _iOSNotificationAttachment(activity, fileStorage),
  );
}

Future<AndroidNotificationDetails> _androidNotificationDetails(
    NotificationAlarm notificationAlarm,
    FileStorage fileStorage,
    String title,
    String subtitle) async {
  final activity = notificationAlarm.activity;
  final alarm = activity.alarm;
  final notificationChannel = _notificationChannel(alarm);

  return AndroidNotificationDetails(
    notificationChannel.id,
    notificationChannel.name,
    notificationChannel.description,
    groupKey: activity.seriesId,
    playSound: alarm.sound,
    enableVibration: alarm.vibrate,
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    startActivityClassName: 'com.abilia.memoplannergo.AlarmActivity',
    largeIcon: await _androidLargeIcon(activity, fileStorage),
    styleInformation: await _androidStyleInformation(
      activity,
      fileStorage,
      title,
      subtitle,
    ),
  );
}

NotificationChannel _notificationChannel(Alarm alarm) => alarm.sound
    ? NotificationChannel('Sound + Vibration', 'Sound + Vibration',
        'Activities with Alarm + Vibration or Only Alarm')
    : alarm.vibrate
        ? NotificationChannel(
            'Vibration', 'Vibration', 'Activities with Only vibration ')
        : NotificationChannel(
            'Silent', 'Silent', 'Activities with Silent Alarm');

class NotificationChannel {
  final String id, name, description;
  NotificationChannel(this.id, this.name, this.description);
}

String _subtitle(
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
  final extra = _extra(notificationAlarm, translater);
  return tf(ad.start) + endTime + extra;
}

String _extra(NotificationAlarm notificationAlarm, Translated translater) {
  if (notificationAlarm is StartAlarm) return translater.startsNow;
  if (notificationAlarm is EndAlarm) return translater.endsNow;
  if (notificationAlarm is NewReminder) {
    return notificationAlarm.reminder
        .toReminderHeading(translater, notificationAlarm is ReminderBefore);
  }
  return '';
}

Future<List<IOSNotificationAttachment>> _iOSNotificationAttachment(
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

Future<StyleInformation> _androidStyleInformation(
  Activity activity,
  FileStorage fileStorage,
  String title,
  String subtitle,
) async {
  if (activity.hasImage) {
    final bigPicture = fileStorage.getFile(activity.fileId);
    if (await fileStorage.exists(bigPicture)) {
      return BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicture.path),
        contentTitle: title,
        summaryText: subtitle,
      );
    }
  }
  return null;
}

Future<AndroidBitmap> _androidLargeIcon(
  Activity activity,
  FileStorage fileStorage,
) async {
  if (activity.hasImage) {
    final largeIcon =
        fileStorage.getImageThumb(ImageThumb(id: activity.fileId));
    if (await fileStorage.exists(largeIcon)) {
      return FilePathAndroidBitmap(largeIcon.path);
    }
  }
  return null;
}
