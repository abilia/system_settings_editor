import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  group('calendar page widget test', () {
    MockActivityDb mockActivityDb;
    StreamController<DateTime> mockTicker;

    setUp(() {
      mockTicker = StreamController<DateTime>();
      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      mockActivityDb = MockActivityDb();
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[]));
      GetItInitializer()
          .withActivityDb(mockActivityDb)
          .withUserDb(MockUserDb())
          .withTicker((() => mockTicker.stream))
          .withBaseUrlDb(MockBaseUrlDb())
          .withFireBasePushService(mockFirebasePushService)
          .withTokenDb(mockTokenDb)
          .withHttpClient(Fakes.client([]))
          .init();
    });

    testWidgets('Application starts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('Should show up empty', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);
    });

    testWidgets('Should show one activity', (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[FakeActivity.onTime()]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.future()]),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });

    testWidgets('Empty agenda should not show Go to now-button',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets('Agenda with one activity should not show Go to now-button',
        (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[FakeActivity.onTime()]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.onTime()]),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets(
        'Agenda with one activity and a lot of passed activities should show the activity',
        (WidgetTester tester) async {
      final key = 'KEYKEYKEYKEYKEY';
      final activities = FakeActivities.allPast
        ..add(FakeActivity.onTime().copyWith(title: key));
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(activities));
      await tester.pumpWidget(App(
        httpClient: Fakes.client(activities),
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
      expect(find.text(key), findsOneWidget);
    });
  });

  group('calendar page alarms test', () {
    StreamController<DateTime> mockTicker;
    StreamController<String> mockNotificationSelected;
    final DateTime activityWithAlarmTime = DateTime(2011, 11, 11, 11, 11);
    final DateTime twoHoursAfter = activityWithAlarmTime.add(2.hours());
    final Activity activity = FakeActivity.onTime(activityWithAlarmTime);
    final String payloadSerial = json.encode(
        NotificationPayload(activityId: activity.id, onStart: true).toJson());

    setUp(() {
      mockTicker = StreamController<DateTime>();
      mockNotificationSelected = StreamController<String>();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));

      final response = [activity];
      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(response));

      GetItInitializer()
          .withActivityDb(mockActivityDb)
          .withUserDb(MockUserDb())
          .withTicker((() => mockTicker.stream))
          .withBaseUrlDb(MockBaseUrlDb())
          .withFireBasePushService(mockFirebasePushService)
          .withTokenDb(mockTokenDb)
          .withHttpClient(Fakes.client(response))
          .withNotificationStreamGetter(() => mockNotificationSelected.stream)
          .init();
    });

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
  });

  group('Multiple alarms tests', () {
    StreamController<DateTime> mockTicker;
    StreamController<String> mockNotificationSelected;
    final DateTime activity1StartTime = DateTime(2011, 11, 11, 11, 11);
    final Activity activity1 =
        FakeActivity.onTime(activity1StartTime, Duration(minutes: 1));
    final String startTimeNotificationPayload = json.encode(
        NotificationPayload(activityId: activity1.id, onStart: true).toJson());

    setUp(() {
      mockTicker = StreamController<DateTime>();
      mockNotificationSelected = StreamController<String>();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));

      final response = [activity1];
      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(response));

      GetItInitializer()
          .withActivityDb(mockActivityDb)
          .withUserDb(MockUserDb())
          .withTicker((() => mockTicker.stream))
          .withBaseUrlDb(MockBaseUrlDb())
          .withFireBasePushService(mockFirebasePushService)
          .withTokenDb(mockTokenDb)
          .withHttpClient(Fakes.client(response))
          .withNotificationStreamGetter(() => mockNotificationSelected.stream)
          .init();
    });

    testWidgets('Start and end time alarm for same activity',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final Finder alarmScreenFinder = find.byKey(TestKey.onScreenAlarm);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 1)));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.alarmOkButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.alarmOkButton));
      await tester.pumpAndSettle();

      // Expect - no more alarms is displayed
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Start alarm is displayed on top if tapped on notification',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final Finder alarmScreenFinder = find.byKey(TestKey.onScreenAlarm);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 1)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      mockNotificationSelected.add(startTimeNotificationPayload);
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.alarmOkButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.alarmOkButton));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown since the start time alarm should have been moved to top
      expect(alarmScreenFinder, findsNothing);
    });
  });
}
