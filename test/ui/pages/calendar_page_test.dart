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
    MockTokenDb mockTokenDb;
    MockFirebasePushService mockFirebasePushService;
    MockActivityDb mockActivityDb;
    MockPushBloc mockPushBloc;
    StreamController<DateTime> mockTicker;

    setUp(() {
      mockTokenDb = MockTokenDb();
      mockTicker = StreamController<DateTime>();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      mockActivityDb = MockActivityDb();
      mockPushBloc = MockPushBloc();
      GetItInitializer()
          .withPushBloc(mockPushBloc)
          .withActivityDb(mockActivityDb)
          .withUserDb(MockUserDb())
          .withTicker((() => mockTicker.stream))
          .init();
    });

    testWidgets('Application starts', (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([]),
        baseUrl: '',
        firebasePushService: mockFirebasePushService,
        tokenDb: mockTokenDb,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('Should show up empty', (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([]),
        firebasePushService: mockFirebasePushService,
        tokenDb: mockTokenDb,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);
    });

    testWidgets('Should show one activity', (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[FakeActivity.onTime()]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.future()]),
        firebasePushService: mockFirebasePushService,
        tokenDb: mockTokenDb,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });

    testWidgets('Empty agenda should not show Go to now-button',
        (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([]),
        firebasePushService: mockFirebasePushService,
        tokenDb: mockTokenDb,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets('Agenda with one activity should not show Go to now-button',
        (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[FakeActivity.onTime()]));
      await tester.pumpWidget(App(
        httpClient: Fakes.client([FakeActivity.onTime()]),
        firebasePushService: mockFirebasePushService,
        tokenDb: mockTokenDb,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets(
        'Agenda with one activity hidden by passed activities should show Go to now-button',
        (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer((_) =>
          Future.value(FakeActivities.allPast..add(FakeActivity.onTime())));
      await tester.pumpWidget(App(
        httpClient:
            Fakes.client(FakeActivities.allPast..add(FakeActivity.onTime())),
        firebasePushService: mockFirebasePushService,
        tokenDb: mockTokenDb,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsOneWidget);
    });

    testWidgets('Alarms shows', (WidgetTester tester) async {
      final activityWithAlarmTime = DateTime(2021, 12, 20, 21, 12);
      final response = [FakeActivity.onTime(activityWithAlarmTime)];
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(response));
      await tester.pumpWidget(App(
        httpClient: Fakes.client(response),
        firebasePushService: mockFirebasePushService,
        tokenDb: mockTokenDb,
      ));
      await tester.pumpAndSettle();
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    });
  });
}
