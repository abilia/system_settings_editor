import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logging/logging.dart';
import 'package:memoplanner/config.dart';
import 'package:synchronized/synchronized.dart';

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/i18n/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/storage/all.dart';
import 'package:memoplanner/utils/all.dart';

final _log = Logger('NotificationIsolate');

const showNotifications = Config.isMPGO;

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
      iOS: DarwinInitializationSettings(
        requestSoundPermission: false,
        requestBadgePermission: false,
        requestAlertPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: onNotification,
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

// If showNotifications is false, notifications aren't triggered by
// NotificationManagerCompat as normal but by a custom BackgroundAlarm class.
// Using cancel() for any scheduled notification will always cancel the current
// BackgroundAlarm while cancelAll() only cancels scheduled notification.
//
// If showNotifications is true, it's the other way around and cancelAll will
// also cancel the current notification.
Future cancelAllPendingNotifications() async {
  if (!showNotifications) {
    return notificationPlugin.cancelAll();
  }
  final pendingNotification =
      await notificationPlugin.pendingNotificationRequests();
  for (var notification in pendingNotification) {
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
    // We need the lock because if two pushes comes simultaneously
    // (that happens when file is uploaded on myAbilia)
    // there is a race condition when adding pictures to notifications.
    // The image being are moved into the attachment data store is gone for the next thread
    _lock.synchronized(
      () async {
        await cancelAllPendingNotifications();
        final locale = Locale(language);
        await initializeDateFormatting(locale.languageCode);
        final androidNotificationChannels =
            await androidNotificationChannelIds();
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
            androidNotificationChannels,
            // Adding a delay on simultaneous alarms to let the
            // selectNotificationSubject handle them
            notificationTimes.add(newNotification.notificationTime) ? 0 : 3,
          )) scheduled++;
        }
        _log.info('$scheduled notifications scheduled');
      },
    );

Future<Set<String>> androidNotificationChannelIds() async {
  return (await notificationPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.getNotificationChannels())
          ?.map((e) => e.id)
          .toSet() ??
      {};
}

Future<bool> _scheduleNotification(
  NotificationAlarm notificationAlarm,
  Locale locale,
  bool alwaysUse24HourFormat,
  AlarmSettings settings,
  FileStorage fileStorage,
  DateTime Function() now,
  Set<String> androidChannelIds,
  int secondsOffset,
) async {
  final title = notificationAlarm.event.title;
  final subtitle = _subtitle(
    notificationAlarm,
    locale,
    alwaysUse24HourFormat,
  );

  final and = defaultTargetPlatform == TargetPlatform.android
      ? await _androidNotificationDetails(
          notificationAlarm,
          fileStorage,
          title,
          subtitle,
          settings,
          androidChannelIds,
        )
      : null;

  final iOS = defaultTargetPlatform == TargetPlatform.iOS
      ? await _iosNotificationDetails(
          notificationAlarm,
          fileStorage,
          settings.duration,
          settings,
        )
      : null;

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
      NotificationDetails(android: and, iOS: iOS),
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

Future<DarwinNotificationDetails> _iosNotificationDetails(
  NotificationAlarm notificationAlarm,
  FileStorage fileStorage,
  Duration alarmDuration,
  AlarmSettings settings,
) async {
  final sound = notificationAlarm.sound(settings);
  final hasSound = notificationAlarm.hasSound(settings);
  final hasVibration = notificationAlarm.hasVibration(settings);
  final seconds = alarmDuration.inSeconds;
  final soundFile = !hasVibration && !hasSound
      ? null
      : !hasSound || sound == Sound.NoSound
          ? 'silent.aiff'
          : '${sound.fileName()}'
              '${seconds >= 30 ? '_30' : seconds >= 15 ? '_15' : ''}'
              '.aiff';
  return DarwinNotificationDetails(
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
  Set<String> channelIds,
) async {
  final groupKey = notificationAlarm is ActivityAlarm
      ? notificationAlarm.activity.seriesId
      : null;
  final sound = notificationAlarm.sound(settings);
  final hasSound = notificationAlarm.hasSound(settings);
  final hasVibration = notificationAlarm.hasVibration(settings);

  final channel = notificationChannel(hasSound, hasVibration, sound);
  const insistentFlag = 4;

  return AndroidNotificationDetails(
    channel.id,
    channel.name,
    channelDescription: channel.description,
    groupKey: groupKey,
    playSound: hasSound,
    sound: sound == Sound.NoSound || !hasSound
        ? null
        : RawResourceAndroidNotificationSound(sound.fileName()),
    enableVibration: hasVibration,
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    additionalFlags: settings.durationMs > 0
        ? Int32List.fromList(<int>[insistentFlag])
        : null,
    timeoutAfter: settings.durationMs,
    startActivityClassName:
        // This is 'package.name.Activity',
        // don't change to application flavor id
        'com.abilia.memoplanner.AlarmActivity',
    showNotification: showNotifications,
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
    audioAttributesUsage: AudioAttributesUsage.alarm,
    category: AndroidNotificationCategory.alarm,
    channelAction: channelIds.contains(channel.id)
        ? AndroidNotificationChannelAction.update
        : AndroidNotificationChannelAction.createIfNotExists,
  );
}

@visibleForTesting
NotificationChannel notificationChannel(
        bool hasSound, bool hasVibration, Sound sound) =>
    hasSound
        ? NotificationChannel(
            'SoundVibration${sound.name}',
            'Sound and Vibration with sound ${sound.name}',
            'Activities with Alarm and Vibration or Only Alarm with sound '
                '${sound.name}',
          )
        : hasVibration
            ? NotificationChannel(
                'Vibration',
                'Vibration',
                'Activities with Only vibration',
              )
            : NotificationChannel(
                'Silent',
                'Silent',
                'Activities with Silent Alarm',
              );

class NotificationChannel {
  final String id, name, description;
  NotificationChannel(this.id, this.name, this.description);
}

String? _subtitle(
  NotificationAlarm notificationAlarm,
  Locale givenLocale,
  bool alwaysUse24HourFormat,
) {
  final timeFormat =
      hourAndMinuteFromUse24(alwaysUse24HourFormat, givenLocale.languageCode);
  final translator = Locales.language[givenLocale] ?? const EN();
  if (notificationAlarm is ActivityAlarm) {
    return _activitySubtitle(notificationAlarm, timeFormat, translator);
  }
  return null;
}

String _activitySubtitle(
  ActivityAlarm activeNotification,
  TimeFormat timeFormat,
  Translated? translator,
) {
  final ad = activeNotification.activityDay;
  final endTime = ad.activity.hasEndTime ? ' - ${timeFormat(ad.end)} ' : ' ';
  final extra =
      translator != null ? _extra(activeNotification, translator) : '';
  return timeFormat(ad.start) + endTime + extra;
}

String _extra(ActivityAlarm notificationAlarm, Translated translator) {
  if (notificationAlarm is StartAlarm) return translator.startsNow;
  if (notificationAlarm is EndAlarm) return translator.endsNow;
  if (notificationAlarm is NewReminder) {
    return notificationAlarm.reminder
        .toReminderHeading(translator, notificationAlarm is ReminderBefore);
  }
  return '';
}

Future<List<DarwinNotificationAttachment>> _iOSNotificationAttachment(
  String fileId,
  FileStorage fileStorage,
) async {
  final iOSAttachment = <DarwinNotificationAttachment>[];
  if (fileId.isNotEmpty) {
    final thumbCopy = await fileStorage.copyImageThumbForNotification(fileId);
    if (thumbCopy != null) {
      iOSAttachment.add(
        DarwinNotificationAttachment(
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