import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uuid/uuid.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:seagull/background/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/models/all.dart';
import '../mocks/mocks.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  final now = DateTime(2020, 05, 14, 18, 53);
  final mockedFileStorage = MockFileStorage();
  late MockFlutterLocalNotificationsPlugin mockedNotificationsPlugin;
  final fileId = const Uuid().v4();
  final allActivities = [
    Activity.createNew(
      title: 'passed',
      startTime: now.subtract(1.minutes()),
      timezone: 'aTimeZone',
    ),
    // 1 alarm
    Activity.createNew(
      title: 'start',
      startTime: now.add(5.minutes()),
      fileId: fileId,
      timezone: 'aTimeZone',
    ),
    // 2 alarms
    Activity.createNew(
      title: 'start and end',
      startTime: now.add(3.hours()),
      duration: 1.hours(),
      alarmType: alarmSound,
      timezone: 'aTimeZone',
    ),
    // 2 reminerds
    Activity.createNew(
      title: 'reminders',
      startTime: now.add(1.hours()),
      reminderBefore: [5.minutes().inMilliseconds, 30.minutes().inMilliseconds],
      alarmType: noAlarm,
      timezone: 'aTimeZone',
    ),
    // 6 recurring
    Activity.createNew(
      title: 'recurring',
      startTime: now.add(2.hours()),
      alarmType: alarmSoundOnlyOnStart,
      timezone: 'aTimeZone',
      recurs: Recurs.weeklyOnDays(List.generate(7, (d) => d + 1),
          ends: now.add(5.days())),
    ),
  ];

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    notificationsPluginInstance =
        mockedNotificationsPlugin = MockFlutterLocalNotificationsPlugin();

    when(() => mockedNotificationsPlugin.cancelAll())
        .thenAnswer((_) => Future.value());
    when(() => mockedFileStorage.copyImageThumbForNotification(fileId))
        .thenAnswer((_) => Future.value(File(fileId)));
    when(() => mockedFileStorage.getFile(fileId)).thenReturn(File(fileId));
    when(() => mockedFileStorage.getImageThumb(ImageThumb(id: fileId)))
        .thenReturn(File(fileId));
    when(() => mockedFileStorage.exists(any()))
        .thenAnswer((_) => Future.value(true));
  });

  test('isolate', () async {
    final serialized =
        allActivities.map((e) => e.wrapWithDbModel().toJson()).toList();
    final shouldBeScheduledNotificationsSerialized =
        await compute(alarmsFromIsolate, [serialized, now]);
    final shouldBeScheduledNotifications =
        shouldBeScheduledNotificationsSerialized
            .map((e) => NotificationAlarm.fromJson(e));
    expect(shouldBeScheduledNotifications, hasLength(11));
  });

  test('scheduleAlarmNotificationsIsolated', () async {
    await scheduleAlarmNotificationsIsolated(
      activities: allActivities,
      timers: [],
      language: 'en',
      alwaysUse24HourFormat: true,
      settings: const AlarmSettings(),
      fileStorage: mockedFileStorage,
      now: () => now,
    );
    verify(() => mockedNotificationsPlugin.cancelAll());
    verify(() => mockedNotificationsPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        payload: any(named: 'payload'),
        androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime)).called(11);
  });

  test('scheduleAlarmNotifications', () async {
    await scheduleAlarmNotifications(
      allActivities,
      [], // TODO timers
      'en',
      true,
      const AlarmSettings(),
      mockedFileStorage,
      now: () => now,
    );
    verify(() => mockedNotificationsPlugin.cancelAll());
    verify(() => mockedNotificationsPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        payload: any(named: 'payload'),
        androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime)).called(11);
  });

  test('scheduleAlarmNotifications disabled until tomorrow', () async {
    await scheduleAlarmNotifications(
      allActivities,
      [], // TODO timers
      'en',
      true,
      AlarmSettings(
        disabledUntilEpoch: now.onlyDays().nextDay().millisecondsSinceEpoch,
      ),
      mockedFileStorage,
      now: () => now,
    );
    verify(() => mockedNotificationsPlugin.cancelAll());

    verify(() => mockedNotificationsPlugin.zonedSchedule(
        any(), any(), any(), any(), any(),
        payload: any(named: 'payload'),
        androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime)).called(5);
  });

  test('scheduleAlarmNotifications with image', () async {
    await scheduleAlarmNotifications(
      allActivities.take(2),
      [], // TODO timers
      'en',
      true,
      const AlarmSettings(),
      mockedFileStorage,
      now: () => now,
    );
    verify(() => mockedNotificationsPlugin.cancelAll());
    verify(() => mockedFileStorage.copyImageThumbForNotification(fileId));
    verify(() => mockedFileStorage.getFile(fileId));
    verify(() => mockedFileStorage.getImageThumb(ImageThumb(id: fileId)));

    final details = verify(() => mockedNotificationsPlugin.zonedSchedule(
            any(), any(), any(), any(), captureAny(),
            payload: any(named: 'payload'),
            androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime))
        .captured
        .single as NotificationDetails;

    // iOS
    expect(details.iOS?.attachments?.length, 1);
    final attachment = details.iOS?.attachments?.first;
    expect(attachment?.filePath, fileId);
    expect(attachment?.identifier, fileId);
    // Android
    expect(details.android?.styleInformation,
        isInstanceOf<BigPictureStyleInformation>());
    final bpd =
        (details.android?.styleInformation as BigPictureStyleInformation)
            .bigPicture as FilePathAndroidBitmap;
    expect(bpd.data, fileId);

    expect(details.android?.largeIcon, isInstanceOf<FilePathAndroidBitmap>());
    final largeIcon = details.android?.largeIcon as FilePathAndroidBitmap;
    expect(largeIcon.data, fileId);

    expect(details.android?.fullScreenIntent, isTrue);
  });
}
