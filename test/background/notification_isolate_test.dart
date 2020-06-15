import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/models/all.dart';

import '../mocks.dart';

void main() {
  final now = DateTime(2020, 05, 14, 18, 53);
  final allActivities = [
    Activity.createNew(title: 'passed', startTime: now.subtract(1.minutes())),
    // 1 alarm
    Activity.createNew(title: 'start', startTime: now.add(5.minutes())),
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
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
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
    await scheduleAlarmNotificationsIsolated(allActivities, 'en', true,
        now: now);
    verify(notificationsPluginInstance.cancelAll());
    verify(notificationsPluginInstance.schedule(any, any, any, any, any,
            payload: anyNamed('payload'),
            androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
            androidWakeScreen: anyNamed('androidWakeScreen')))
        .called(11);
  });
  test('scheduleAlarmNotifications', () async {
    await scheduleAlarmNotifications(allActivities, 'en', true, now: now);
    verify(notificationsPluginInstance.cancelAll());
    verify(notificationsPluginInstance.schedule(any, any, any, any, any,
            payload: anyNamed('payload'),
            androidAllowWhileIdle: anyNamed('androidAllowWhileIdle'),
            androidWakeScreen: anyNamed('androidWakeScreen')))
        .called(11);
  });
}
