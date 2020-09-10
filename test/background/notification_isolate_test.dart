import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:seagull/background/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/models/all.dart';
import '../mocks.dart';

void main() {
  final now = DateTime(2020, 05, 14, 18, 53);
  final mockedFileStorage = MockFileStorage();
  final fileId = Uuid().v4();
  final allActivities = [
    Activity.createNew(title: 'passed', startTime: now.subtract(1.minutes())),
    // 1 alarm
    Activity.createNew(
      title: 'start',
      startTime: now.add(5.minutes()),
      fileId: fileId,
    ),
    // 2 alarms
    Activity.createNew(
      title: 'start and end',
      startTime: now.add(3.hours()),
      duration: 1.hours(),
      alarmType: ALARM_SOUND,
    ),
    // 2 reminerds
    Activity.createNew(
      title: 'reminders',
      startTime: now.add(1.hours()),
      reminderBefore: [5.minutes().inMilliseconds, 30.minutes().inMilliseconds],
      alarmType: NO_ALARM,
    ),
    // 6 recurring
    Activity.createNew(
      title: 'recurring',
      startTime: now.add(2.hours()),
      alarmType: ALARM_SOUND_ONLY_ON_START,
      recurs: Recurs.weekly(Recurs.everyday, ends: now.add(5.days())),
    ),
  ];
  setUp(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);

    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    when(mockedFileStorage.copyImageThumbForNotification(fileId))
        .thenAnswer((_) => Future.value(File(fileId)));
    when(mockedFileStorage.getFile(fileId)).thenReturn(File(fileId));
    when(mockedFileStorage.getImageThumb(ImageThumb(id: fileId)))
        .thenReturn(File(fileId));
    when(mockedFileStorage.exists(any)).thenAnswer((_) => Future.value(true));
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
      allActivities,
      'en',
      true,
      mockedFileStorage,
      now: now,
    );
    verify(notificationsPluginInstance.cancelAll());
    verify(notificationsPluginInstance.zonedSchedule(any, any, any, any, any,
            payload: anyNamed('payload'),
            androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime))
        .called(11);
  });
  test('scheduleAlarmNotifications', () async {
    await scheduleAlarmNotifications(
      allActivities,
      'en',
      true,
      mockedFileStorage,
      now: now,
    );
    verify(notificationsPluginInstance.cancelAll());
    verify(notificationsPluginInstance.zonedSchedule(any, any, any, any, any,
            payload: anyNamed('payload'),
            androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime))
        .called(11);
  });

  test('scheduleAlarmNotifications with image', () async {
    await scheduleAlarmNotifications(
      allActivities.take(2),
      'en',
      true,
      mockedFileStorage,
      now: now,
    );
    verify(notificationsPluginInstance.cancelAll());
    verify(mockedFileStorage.copyImageThumbForNotification(fileId));
    verify(mockedFileStorage.getFile(fileId));
    verify(mockedFileStorage.getImageThumb(ImageThumb(id: fileId)));

    final details = verify(notificationsPluginInstance.zonedSchedule(
            any, any, any, any, captureAny,
            payload: anyNamed('payload'),
            androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.wallClockTime))
        .captured
        .single as NotificationDetails;

    // iOS
    expect(details.iOS.attachments.length, 1);
    final attachment = details.iOS.attachments.first;
    expect(attachment.filePath, fileId);
    expect(attachment.identifier, fileId);
    // Android
    expect(
        details.android.styleInformation is BigPictureStyleInformation, isTrue);
    final bpd = details.android.styleInformation as BigPictureStyleInformation;
    expect(bpd.bigPicture.bitmap, fileId);

    expect(details.android.largeIcon is FilePathAndroidBitmap, isTrue);
    final largeIcon = details.android.largeIcon as FilePathAndroidBitmap;
    expect(largeIcon.bitmap, fileId);

    expect(details.android.fullScreenIntent, isTrue);
  });
}
