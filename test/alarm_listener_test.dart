import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

import 'mocks.dart';

void main() {
  StreamController<DateTime> mockTicker;
  StreamController<String> mockNotificationSelected;
  final mockActivityDb = MockActivityDb();

  final activityWithAlarmTime = DateTime(2011, 11, 11, 11, 11);
  final activityWithAlarmday = activityWithAlarmTime.onlyDays();
  final twoHoursAfter = activityWithAlarmTime.add(2.hours());
  final activity =
      FakeActivity.starts(activityWithAlarmTime).copyWith(checkable: true);
  final payloadSerial = json.encode(NotificationPayload(
    activityId: activity.id,
    day: activityWithAlarmday,
    onStart: true,
  ).toJson());

  setUp(() {
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    mockTicker = StreamController<DateTime>();
    mockNotificationSelected = StreamController<String>();

    final mockTokenDb = MockTokenDb();
    when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));

    final response = [activity];

    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(response));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    GetItInitializer()
      ..activityDb = mockActivityDb
      ..userDb = MockUserDb()
      ..ticker = Ticker(stream: mockTicker.stream)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..tokenDb = mockTokenDb
      ..httpClient = Fakes.client(() => response)
      ..notificationStreamGetter = (() => mockNotificationSelected.stream)
      ..fileStorage = MockFileStorage()
      ..syncDelay = SyncDelays.zero
      ..init();
  });
  group('alarms and reminder test', () {
    testWidgets('Alarms shows', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    });

    testWidgets('Alarms shows when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.byKey(TestKey.onScreenAlarm), findsNothing);
      // Act
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    });

    testWidgets('Alarms shows when notification selected before app start',
        (WidgetTester tester) async {
      // Act
      mockTicker.add(twoHoursAfter);
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    });

    testWidgets('Alarms can be checked when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpAndSettle();

      // Assert -- Alarm is on screen and alarm is checkable
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityUncheckButton), findsNothing);

      // Act -- Tap the check button
      await tester.tap(find.byKey(TestKey.activityCheckButton));
      await tester.pumpAndSettle();

      // Assert -- Alarm is checked
      expect(find.byKey(TestKey.activityUncheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsNothing);

      // Act -- Tap the uncheck button
      await tester.tap(find.byKey(TestKey.activityUncheckButton));
      await tester.pumpAndSettle();

      // Assert -- Alarm is unchecked again
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityUncheckButton), findsNothing);
    });

    testWidgets('Popup Alarms can be signed off', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Act -- alarm time happend
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();

      // Assert -- On screen alarm showing and check button showing
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityUncheckButton), findsNothing);

      // Act -- Tap the check button
      await tester.tap(find.byKey(TestKey.activityCheckButton));
      await tester.pumpAndSettle();

      // Assert -- Check button not showing and uncheck button showing
      expect(find.byKey(TestKey.activityUncheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsNothing);

      // Act -- Tap the uncheck button
      await tester.tap(find.byKey(TestKey.activityUncheckButton));
      await tester.pumpAndSettle();

      // Assert -- Check button showing and uncheck not showing
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityUncheckButton), findsNothing);
    });
  });
  group('Multiple alarms tests', () {
    final activity1StartTime = DateTime(2011, 11, 11, 11, 11);
    final day = DateTime(2011, 11, 11);
    final activity1 =
        FakeActivity.starts(activity1StartTime, duration: 2.minutes());
    final startTimeActivity1NotificationPayload =
        json.encode(NotificationPayload(
      activityId: activity1.id,
      day: day,
      onStart: true,
    ).toJson());

    final activity2StartTime = DateTime(2011, 11, 11, 11, 12);
    final activity2 =
        FakeActivity.starts(activity2StartTime, duration: 2.minutes());

    testWidgets('Start and end time alarm for same activity',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byKey(TestKey.onScreenAlarm);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - no more alarms is displayed
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Start alarm is displayed on top if tapped on notification',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byKey(TestKey.onScreenAlarm);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      mockNotificationSelected.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown since the start time alarm should have been moved to top
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Overlapping activities', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1, activity2]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byKey(TestKey.onScreenAlarm);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 1)));
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      mockTicker.add(activity1StartTime.add(Duration(minutes: 3)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      mockNotificationSelected.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm for activity1
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);
      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity1.id));

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm for activity 2
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);
      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity2.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm for activity 1
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);
      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity1.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the start time alarm for activity 2
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);
      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity2.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown
      expect(alarmScreenFinder, findsNothing);
    });
  });
}
