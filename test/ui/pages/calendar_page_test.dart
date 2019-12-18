import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';

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

    testWidgets('Alarms shows', (WidgetTester tester) async {
      final activityWithAlarmTime = DateTime(2021, 12, 20, 21, 12);
      final response = [FakeActivity.onTime(activityWithAlarmTime)];
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(response));
      await tester.pumpWidget(App(
        httpClient: Fakes.client(response),
      ));
      await tester.pumpAndSettle();
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    });
  });
}
