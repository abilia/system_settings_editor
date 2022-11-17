import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uuid/uuid.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/models/all.dart';
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
    // 2 reminders
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

  setUpAll(registerFallbackValues);

  setUp(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    notificationsPluginInstance =
        mockedNotificationsPlugin = MockFlutterLocalNotificationsPlugin();

    when(() => mockedNotificationsPlugin.cancelAll())
        .thenAnswer((_) => Future.value());
    when(() => mockedNotificationsPlugin.pendingNotificationRequests())
        .thenAnswer((_) => Future.value([]));
    when(() => mockedFileStorage.copyImageThumbForNotification(fileId))
        .thenAnswer((_) => Future.value(File(fileId)));
    when(() => mockedFileStorage.getFile(fileId)).thenReturn(File(fileId));
    when(() => mockedFileStorage.getImageThumb(ImageThumb(id: fileId)))
        .thenReturn(File(fileId));
    when(() => mockedFileStorage.exists(any()))
        .thenAnswer((_) => Future.value(true));
  });

  void verifyCancelAllPendingNotifications() => verify(() => !showNotifications
      ? mockedNotificationsPlugin.cancelAll()
      : mockedNotificationsPlugin.pendingNotificationRequests());

  group('Notification channels', () {
    test('are unique', () async {
      const sound = Sound.Default;
      final notificationChannel1 = notificationChannel(true, true, sound);
      final notificationChannel2 = notificationChannel(true, false, sound);
      final notificationChannel3 = notificationChannel(false, true, sound);
      final notificationChannel4 = notificationChannel(false, false, sound);

      expect(notificationChannel1.id, 'SoundVibration${sound.name}');
      expect(
        notificationChannel1.name,
        'Sound and Vibration with sound ${sound.name}',
      );
      expect(
        notificationChannel1.description,
        'Activities with Alarm and Vibration or Only Alarm with sound ${sound.name}',
      );

      expect(notificationChannel2.id, notificationChannel1.id);
      expect(notificationChannel2.name, notificationChannel1.name);
      expect(
        notificationChannel2.description,
        notificationChannel1.description,
      );

      expect(notificationChannel3.id, 'Vibration');
      expect(notificationChannel3.name, 'Vibration');
      expect(
        notificationChannel3.description,
        'Activities with Only vibration',
      );

      expect(notificationChannel4.id, 'Silent');
      expect(notificationChannel4.name, 'Silent');
      expect(notificationChannel4.description, 'Activities with Silent Alarm');
    });

    test('are updated if existing, created otherwise', () async {
      // Arrange
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      const soundVibrationDefault = 'SoundVibrationDefault';
      final mockedAndroidFlutterLocalNotificationsPlugin =
          MockAndroidFlutterLocalNotificationsPlugin();
      when(() =>
              mockedNotificationsPlugin.resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockedAndroidFlutterLocalNotificationsPlugin);
      when(() => mockedAndroidFlutterLocalNotificationsPlugin
          .getNotificationChannels()).thenAnswer(
        (invocation) => Future.value(
          [
            const AndroidNotificationChannel(
              soundVibrationDefault,
              'Sound and Vibration with sound Default',
            ),
          ],
        ),
      );

      const timerSound = Sound.Hello;

      // Act
      await scheduleAlarmNotifications(
        [Activity.createNew(startTime: now.add(30.minutes()))],
        [
          TimerAlarm(
            AbiliaTimer.createNew(
              startTime: now,
              duration: 10.minutes(),
            ),
          )
        ],
        'en',
        true,
        const AlarmSettings().copyWith(timerSound: timerSound),
        mockedFileStorage,
        now: () => now,
      );

      // Assert
      final captured = verify(
        () => mockedNotificationsPlugin.zonedSchedule(
          any(),
          any(),
          any(),
          any(),
          captureAny(),
          payload: any(named: 'payload'),
          androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        ),
      ).captured;

      final update = captured
          .cast<NotificationDetails>()
          .firstWhere(
            (element) => element.android?.channelId == soundVibrationDefault,
          )
          .android;

      expect(update?.channelAction, AndroidNotificationChannelAction.update);

      final create = captured
          .cast<NotificationDetails>()
          .firstWhere(
            (element) =>
                element.android?.channelId ==
                'SoundVibration${timerSound.name}',
          )
          .android;
      expect(
        create?.channelAction,
        AndroidNotificationChannelAction.createIfNotExists,
      );
    });
  });

  group('only activities', () {
    test('isolate', () async {
      final serialized =
          allActivities.map((e) => e.wrapWithDbModel().toJson()).toList();
      final shouldBeScheduledNotificationsSerialized =
          await compute(alarmsFromIsolate, [serialized, now, 50]);
      final shouldBeScheduledNotifications =
          shouldBeScheduledNotificationsSerialized
              .map((e) => ActivityAlarm.fromJson(e));
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
      verifyCancelAllPendingNotifications();
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
        [],
        'en',
        true,
        const AlarmSettings(),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
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
        [],
        'en',
        true,
        AlarmSettings(
          disabledUntilEpoch: now.onlyDays().nextDay().millisecondsSinceEpoch,
        ),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();

      verify(() => mockedNotificationsPlugin.zonedSchedule(
          any(), any(), any(), any(), any(),
          payload: any(named: 'payload'),
          androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime)).called(5);
    });

    test('scheduleAlarmNotifications with image android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await scheduleAlarmNotifications(
        allActivities.take(2),
        [],
        'en',
        true,
        const AlarmSettings(),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
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

    test('scheduleAlarmNotifications with image iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      await scheduleAlarmNotifications(
        allActivities.take(2),
        [],
        'en',
        true,
        const AlarmSettings(),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
      verify(() => mockedFileStorage.copyImageThumbForNotification(fileId));

      final details = verify(
        () => mockedNotificationsPlugin.zonedSchedule(
            any(), any(), any(), any(), captureAny(),
            payload: any(named: 'payload'),
            androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime),
      ).captured.single as NotificationDetails;

      // iOS
      expect(details.iOS?.attachments?.length, 1);
      final attachment = details.iOS?.attachments?.first;
      expect(attachment?.filePath, fileId);
      expect(attachment?.identifier, fileId);
    });
  });

  final timer1 = TimerAlarm(
        AbiliaTimer(
          id: 'ids',
          title: 'title',
          startTime: now,
          duration: 22.minutes(),
        ),
      ),
      timer2 = TimerAlarm(
        AbiliaTimer(
          id: 'ids2',
          title: 'title2',
          startTime: now.subtract(23.hours()),
          duration: 24.hours(),
        ),
      ),
      timer3 = TimerAlarm(
        AbiliaTimer(
          id: 'ids3',
          title: 'title3',
          startTime: now.subtract(21.minutes()).subtract(55.seconds()),
          duration: 22.minutes(),
        ),
      );

  final allTimers = [timer1, timer2, timer3];
  group('only timers', () {
    test('scheduleAlarmNotificationsIsolated one timer', () async {
      await scheduleAlarmNotificationsIsolated(
        activities: [],
        timers: [timer1],
        language: 'en',
        alwaysUse24HourFormat: true,
        settings: const AlarmSettings(),
        fileStorage: mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
      verify(
        () => mockedNotificationsPlugin.zonedSchedule(
            timer1.hashCode, timer1.timer.title, any(), any(), any(),
            payload: timer1.encode(),
            androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime),
      ).called(1);
    });

    test('scheduleAlarmNotificationsIsolated 3 timers', () async {
      await scheduleAlarmNotificationsIsolated(
        activities: [],
        timers: allTimers,
        language: 'en',
        alwaysUse24HourFormat: true,
        settings: const AlarmSettings(),
        fileStorage: mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
      verify(
        () => mockedNotificationsPlugin.zonedSchedule(
            any(), any(), any(), any(), any(),
            payload: any(named: 'payload'),
            androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime),
      ).called(3);
    });

    test('scheduleAlarmNotifications one timer', () async {
      await scheduleAlarmNotifications(
        [],
        [timer1],
        'en',
        true,
        const AlarmSettings(),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
      verify(
        () => mockedNotificationsPlugin.zonedSchedule(
            timer1.hashCode, timer1.timer.title, any(), any(), any(),
            payload: timer1.encode(),
            androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime),
      ).called(1);
    });

    test('scheduleAlarmNotifications 3 timers', () async {
      await scheduleAlarmNotifications(
        [],
        allTimers,
        'en',
        true,
        const AlarmSettings(),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
      verify(
        () => mockedNotificationsPlugin.zonedSchedule(
            any(), any(), any(), any(), any(),
            payload: any(named: 'payload'),
            androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime),
      ).called(3);
    });

    test('scheduleAlarmNotifications with image android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final timerWithImage = TimerAlarm(
        AbiliaTimer(
          id: 'id6',
          fileId: fileId,
          startTime: now,
          duration: 14.minutes(),
        ),
      );
      await scheduleAlarmNotifications(
        [],
        [timerWithImage],
        'en',
        true,
        const AlarmSettings(),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
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

    test('scheduleAlarmNotifications with image iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final timerWithImage = TimerAlarm(
        AbiliaTimer(
          id: 'id6',
          fileId: fileId,
          startTime: now,
          duration: 14.minutes(),
        ),
      );
      await scheduleAlarmNotifications(
        [],
        [timerWithImage],
        'en',
        true,
        const AlarmSettings(),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
      verify(() => mockedFileStorage.copyImageThumbForNotification(fileId));

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
    });

    test(
        'scheduleAlarmNotifications disabled until tomorrow does not consider timers',
        () async {
      await scheduleAlarmNotifications(
        [],
        allTimers,
        'en',
        true,
        AlarmSettings(
          disabledUntilEpoch: now.onlyDays().nextDay().millisecondsSinceEpoch,
        ),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();

      verify(() => mockedNotificationsPlugin.zonedSchedule(
          any(), any(), any(), any(), any(),
          payload: any(named: 'payload'),
          androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime)).called(3);
    });
  });

  group('activities and  timers', () {
    test('scheduleAlarmNotificationsIsolated', () async {
      await scheduleAlarmNotificationsIsolated(
        activities: allActivities,
        timers: allTimers,
        language: 'en',
        alwaysUse24HourFormat: true,
        settings: const AlarmSettings(),
        fileStorage: mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
      verify(
        () => mockedNotificationsPlugin.zonedSchedule(
            any(), any(), any(), any(), any(),
            payload: any(named: 'payload'),
            androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime),
      ).called(11 + 3);
    });
    test('scheduleAlarmNotifications 3 timers', () async {
      await scheduleAlarmNotifications(
        allActivities,
        allTimers,
        'en',
        true,
        const AlarmSettings(),
        mockedFileStorage,
        now: () => now,
      );
      verifyCancelAllPendingNotifications();
      verify(
        () => mockedNotificationsPlugin.zonedSchedule(
            any(), any(), any(), any(), any(),
            payload: any(named: 'payload'),
            androidAllowWhileIdle: any(named: 'androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime),
      ).called(11 + 3);
    });
  });
}
