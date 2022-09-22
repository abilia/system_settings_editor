import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:seagull/config.dart';
import 'package:synchronized/synchronized.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/utils/all.dart';

final _log = Logger('NotificationIsolate');

@visibleForTesting
FlutterLocalNotificationsPlugin? notificationsPluginInstance;
FlutterLocalNotificationsPlugin get notificationPlugin =>
    ensureNotificationPluginInitialized();

FlutterLocalNotificationsPlugin ensureNotificationPluginInitialized() {
  var pluginInstance = notificationsPluginInstance;
  if (pluginInstance != null) return pluginInstance;
  _log.finer('initialize notification plugin... ');
  pluginInstance = FlutterLocalNotificationsPlugin();
  pluginInstance.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('icon_notification'),
      iOS: IOSInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    ),
    onSelectNotification: onNotification,
  );
  _log.finer('notification plugin initialize');
  return notificationsPluginInstance = pluginInstance;
}

Future cancelAllActiveNotifications() async {
  final activeNotification = await notificationPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications();
  for (var notification in activeNotification ?? []) {
    await notificationPlugin.cancel(notification.id);
  }
}

Future scheduleAlarmNotifications(
  Iterable<Activity> activities,
  Iterable<TimerAlarm> timers,
  String language,
  bool alwaysUse24HourFormat,
  AlarmSettings settings,
  FileStorage fileStorage, {
  DateTime Function()? now,
}) async {
  now ??= () => DateTime.now();
  final from = settings.disabledUntilDate.isAfter(now())
      ? settings.disabledUntilDate
      : now().nextMinute();
  final activityNotifications = activities.alarmsFrom(
    from,
    take: max(maxNotifications - timers.length, 0),
  );
  return _scheduleAllAlarmNotifications(
    [
      ...timers,
      ...activityNotifications,
    ],
    language,
    alwaysUse24HourFormat,
    settings,
    fileStorage,
    now,
  );
}

Future cancelNotifications(Iterable<ActivityAlarm> notificationAlarms) async {
  for (final notification in notificationAlarms) {
    _log.fine('canceling ${notification.hashCode} $notification');
    await notificationPlugin.cancel(notification.hashCode);
  }
}

AlarmScheduler scheduleAlarmNotificationsIsolated = ({
  required Iterable<Activity> activities,
  required Iterable<TimerAlarm> timers,
  required String language,
  required bool alwaysUse24HourFormat,
  required AlarmSettings settings,
  required FileStorage fileStorage,
  DateTime Function()? now,
}) async {
  now ??= () => DateTime.now();
  final from = settings.disabledUntilDate.isAfter(now())
      ? settings.disabledUntilDate
      : now().nextMinute();
  final serialized =
      activities.map((e) => e.wrapWithDbModel().toJson()).toList();
  final shouldBeScheduledNotificationsSerialized = await compute(
    alarmsFromIsolate,
    [
      serialized,
      from,
      maxNotifications - timers.length,
    ],
  );
  final activityNotifications =
      shouldBeScheduledNotificationsSerialized.map(NotificationAlarm.fromJson);
  return _scheduleAllAlarmNotifications(
    [
      ...timers,
      ...activityNotifications,
    ],
    language,
    alwaysUse24HourFormat,
    settings,
    fileStorage,
    now,
  );
};

@visibleForTesting
List<Map<String, dynamic>> alarmsFromIsolate(List<dynamic> args) {
  final List serialized = args[0];
  final allActivities =
      serialized.map<Activity>((e) => DbActivity.fromJson(e).activity).toList();
  final now = args[1] as DateTime;
  final take = args[2] as int;
  final notificationAlarms = allActivities.alarmsFrom(now, take: take);
  return notificationAlarms.map((e) => e.toJson()).toList();
}

final _lock = Lock();

Future _scheduleAllAlarmNotifications(
  Iterable<NotificationAlarm> notifications,
  String language,
  bool alwaysUse24HourFormat,
  AlarmSettings settings,
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
        final locale = Locale(language);
        await initializeDateFormatting(locale.languageCode);
        _log.fine('scheduling ${notifications.length} notifications...');
        final notificationTimes = <DateTime>{};
        var scheduled = 0;
        for (final newNotification in notifications) {
          if (await _scheduleNotification(
            newNotification,
            locale,
            alwaysUse24HourFormat,
            settings,
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
  Locale locale,
  bool alwaysUse24HourFormat,
  AlarmSettings settings,
  FileStorage fileStorage,
  DateTime Function() now, [
  int secondsOffset = 0,
]) async {
  final title = notificationAlarm.event.title;
  final subtitle = _subtitle(
    notificationAlarm,
    locale,
    alwaysUse24HourFormat,
  );

  final and = Platform.isIOS
      ? null
      : await _androidNotificationDetails(
          notificationAlarm,
          fileStorage,
          title,
          subtitle,
          settings,
        );

  final ios = Platform.isAndroid
      ? null
      : await _iosNotificationDetails(
          notificationAlarm,
          fileStorage,
          settings.duration,
          settings,
        );

  final hash = notificationAlarm.hashCode;
  final payload = notificationAlarm.encode();
  final notificationTime =
      notificationAlarm.notificationTime.add(secondsOffset.seconds());
  final tz = notificationAlarm is ActivityAlarm
      ? tryGetLocation(notificationAlarm.activity.timezone, log: _log)
      : local;
  if (notificationTime.isBefore(now())) return false;
  final time = TZDateTime.from(notificationTime, tz);
  try {
    _log.finest(
      'scheduling ($hash): $title - $subtitle at '
      '$time ${notificationAlarm.event.hasImage ? ' with image' : ''}',
    );
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
    _log.warning('could not schedule $payload', e);
    return false;
  }
}

Future<IOSNotificationDetails> _iosNotificationDetails(
  NotificationAlarm notificationAlarm,
  FileStorage fileStorage,
  Duration alarmDuration,
  AlarmSettings settings,
) async {
  final sound = notificationAlarm.sound(settings);
  final hasSound = notificationAlarm.hasSound(settings);
  final hasVibration = notificationAlarm.vibrate(settings);
  final seconds = alarmDuration.inSeconds;
  final soundFile = !hasVibration && !hasSound
      ? null
      : !hasSound || sound == Sound.NoSound
          ? 'silent.aiff'
          : '${sound.fileName()}${seconds >= 30 ? '_30' : seconds >= 15 ? '_15' : ''}.aiff';
  return IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: hasSound || hasVibration,
    sound: soundFile,
    attachments: await _iOSNotificationAttachment(
      notificationAlarm.event.image.id,
      fileStorage,
    ),
  );
}

Future<AndroidNotificationDetails> _androidNotificationDetails(
  NotificationAlarm notificationAlarm,
  FileStorage fileStorage,
  String title,
  String? subtitle,
  AlarmSettings settings,
) async {
  final groupKey = notificationAlarm is ActivityAlarm
      ? notificationAlarm.activity.seriesId
      : null;
  final sound = notificationAlarm.sound(settings);
  final hasSound = notificationAlarm.hasSound(settings);
  final vibrate = notificationAlarm.vibrate(settings);

  final notificationChannel = _notificationChannel(hasSound, vibrate, sound);
  const insistentFlag = 4;

  return AndroidNotificationDetails(
    notificationChannel.id,
    notificationChannel.name,
    channelDescription: notificationChannel.description,
    groupKey: groupKey,
    playSound: hasSound,
    sound: sound == Sound.NoSound || !hasSound
        ? null
        : RawResourceAndroidNotificationSound(sound.fileName()),
    enableVibration: vibrate,
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    additionalFlags: settings.durationMs > 0
        ? Int32List.fromList(<int>[insistentFlag])
        : null,
    timeoutAfter: settings.durationMs,
    startActivityClassName:
        'com.abilia.memoplanner.AlarmActivity', // This is 'package.name.Activity', dont change to application flavor id
    showNotification: Config.isMPGO,
    largeIcon: await _androidLargeIcon(
      notificationAlarm.event.image.id,
      fileStorage,
    ),
    styleInformation: await _androidStyleInformation(
      notificationAlarm.event.image.id,
      fileStorage,
      title,
      subtitle,
    ),
  );
}

NotificationChannel _notificationChannel(
        bool hasSound, bool vibrate, Sound sound) =>
    hasSound
        ? NotificationChannel(
            'SoundVibration${sound.name}',
            'Sound and Vibration with sound ${sound.name}',
            'Activities with Alarm and Vibration or Only Alarm with sound ${sound.name}')
        : vibrate
            ? NotificationChannel(
                'Vibration', 'Vibration', 'Activities with Only vibration ')
            : NotificationChannel(
                'Silent', 'Silent', 'Activities with Silent Alarm');

class NotificationChannel {
  final String id, name, description;
  NotificationChannel(this.id, this.name, this.description);
}

String? _subtitle(
  NotificationAlarm notificationAlarm,
  Locale givenLocale,
  bool alwaysUse24HourFormat,
) {
  final tf =
      hourAndMinuteFromUse24(alwaysUse24HourFormat, givenLocale.languageCode);
  final translater = Locales.language[givenLocale] ?? const EN();
  if (notificationAlarm is ActivityAlarm) {
    return _activitySubtitle(notificationAlarm, tf, translater);
  }
  return null;
}

String _activitySubtitle(
  ActivityAlarm activeNotification,
  TimeFormat tf,
  Translated? translater,
) {
  final ad = activeNotification.activityDay;
  final endTime = ad.activity.hasEndTime ? ' - ${tf(ad.end)} ' : ' ';
  final extra =
      translater != null ? _extra(activeNotification, translater) : '';
  return tf(ad.start) + endTime + extra;
}

String _extra(ActivityAlarm notificationAlarm, Translated translater) {
  if (notificationAlarm is StartAlarm) return translater.startsNow;
  if (notificationAlarm is EndAlarm) return translater.endsNow;
  if (notificationAlarm is NewReminder) {
    return notificationAlarm.reminder
        .toReminderHeading(translater, notificationAlarm is ReminderBefore);
  }
  return '';
}

Future<List<IOSNotificationAttachment>> _iOSNotificationAttachment(
  String fileId,
  FileStorage fileStorage,
) async {
  final iOSAttachment = <IOSNotificationAttachment>[];
  if (fileId.isNotEmpty) {
    final thumbCopy = await fileStorage.copyImageThumbForNotification(fileId);
    if (thumbCopy != null) {
      iOSAttachment.add(
        IOSNotificationAttachment(
          thumbCopy.path,
          identifier: fileId,
        ),
      );
    }
  }
  return iOSAttachment;
}

Future<StyleInformation?> _androidStyleInformation(
  String fileId,
  FileStorage fileStorage,
  String title,
  String? subtitle,
) async {
  if (fileId.isNotEmpty) {
    final bigPicture = fileStorage.getFile(fileId);
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

Future<AndroidBitmap<Object>?> _androidLargeIcon(
  String fileId,
  FileStorage fileStorage,
) async {
  if (fileId.isNotEmpty) {
    final largeIcon = fileStorage.getImageThumb(ImageThumb(id: fileId));
    if (await fileStorage.exists(largeIcon)) {
      return FilePathAndroidBitmap(largeIcon.path);
    }
  }
  return null;
}
