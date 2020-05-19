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
  final initialTime = activityWithAlarmTime.subtract(1.minutes());
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
      ..ticker = Ticker(stream: mockTicker.stream, initialTime: initialTime)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..tokenDb = mockTokenDb
      ..httpClient = Fakes.client(() => response)
      ..notificationStreamGetter = (() => mockNotificationSelected.stream)
      ..fileStorage = MockFileStorage()
      ..settingsDb = MockSettingsDb()
      ..syncDelay = SyncDelays.zero
      ..alarmScheduler = noAlarmScheduler
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
      expect(find.byType(AlarmPage), findsOneWidget);
    });

    testWidgets('Reminder shows', (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
            Activity.createNew(
              title: 'Reminder',
              startTime: activityWithAlarmTime.add(reminder),
              reminderBefore: [reminder.inMilliseconds],
            )
          ]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(ReminderPage), findsOneWidget);
    });

    testWidgets('Reminder for unchecked activity shows',
        (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
            Activity.createNew(
              title: 'unchecked reminder',
              startTime: activityWithAlarmTime.subtract(reminder),
              checkable: true,
            )
          ]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(ReminderPage), findsOneWidget);
    });

    testWidgets('Reminder for checked activity does not shows',
        (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
            Activity.createNew(
              title: 'Reminder',
              startTime: activityWithAlarmTime.subtract(reminder),
              checkable: true,
              signedOffDates: [activityWithAlarmTime.onlyDays()],
            )
          ]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(ReminderPage), findsNothing);
    });

    testWidgets('Alarms shows when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(AlarmPage), findsNothing);
      // Act
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlarmPage), findsOneWidget);
    });

    testWidgets('Alarms shows when notification selected before app start',
        (WidgetTester tester) async {
      // Act
      mockTicker.add(twoHoursAfter);
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlarmPage), findsOneWidget);
    });

    testWidgets('Alarms can be checked when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpAndSettle();

      // Assert -- Alarm is on screen and alarm is checkable
      expect(find.byType(AlarmPage), findsOneWidget);
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
      expect(find.byType(AlarmPage), findsOneWidget);
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
      final alarmScreenFinder = find.byType(AlarmPage);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

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
      final alarmScreenFinder = find.byType(AlarmPage);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      mockNotificationSelected.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

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
      final alarmScreenFinder = find.byType(AlarmPage);

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
      expect(alarmScreenFinder, findsOneWidget);
      expect(tester.widget<AlarmPage>(alarmScreenFinder).activity.id,
          equals(activity1.id));

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm for activity 2
      expect(alarmScreenFinder, findsOneWidget);

      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity2.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm for activity 1
      expect(alarmScreenFinder, findsOneWidget);

      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity1.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the start time alarm for activity 2
      expect(alarmScreenFinder, findsOneWidget);

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
