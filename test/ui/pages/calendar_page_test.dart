import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
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
    final changeViewButtonFinder = find.byKey(Key('changeView'));
    final timePillarButtonFinder = find.byKey(Key('timePillarButton'));

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

    testWidgets('Show timepillar when timepillar is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(Agenda), findsOneWidget);
      await tester.tap(changeViewButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(timePillarButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(TimePillar), findsOneWidget);
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
}
