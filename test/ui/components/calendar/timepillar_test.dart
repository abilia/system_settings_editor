import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/calendar/all.dart';

import '../../../mocks.dart';

void main() {
  group('timepillar page widget test', () {
    MockActivityDb mockActivityDb;
    StreamController<DateTime> mockTicker;
    final changeViewButtonFinder = find.byKey(TestKey.changeView);
    final timePillarButtonFinder = find.byKey(TestKey.timePillarButton);
    final date = DateTime(2002, 03, 04, 05, 06);
    final activities = [FakeActivity.fullday(date)];

    ActivityResponse activityResponse = () => activities;

    setUp(() {
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      mockTicker = StreamController<DateTime>();
      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      mockActivityDb = MockActivityDb();
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(activities));
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = (() => mockTicker.stream)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..startTime = date
        ..httpClient = Fakes.client(activityResponse)
        ..init();
    });
    goToTimePillar(WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(changeViewButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(timePillarButtonFinder);
      await tester.pumpAndSettle();
    }

    testWidgets('Shows when selected', (WidgetTester tester) async {
      await goToTimePillar(tester);
      expect(find.byType(TimePillar), findsOneWidget);
    });

    testWidgets('Can navigate back to agenda view',
        (WidgetTester tester) async {
      await goToTimePillar(tester);
      await tester.tap(changeViewButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.agendaListButton));
      await tester.pumpAndSettle();
      expect(find.byType(TimePillar), findsNothing);
      expect(find.byType(Agenda), findsOneWidget);
    });

    testWidgets('Shows timepillar', (WidgetTester tester) async {
      await goToTimePillar(tester);
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });

    testWidgets('Shows all days activities', (WidgetTester tester) async {
      await goToTimePillar(tester);
      expect(find.byType(FullDayContainer), findsOneWidget);
    });

    testWidgets('Shows timepillar when scrolled in x',
        (WidgetTester tester) async {
      await goToTimePillar(tester);

      await tester.flingFrom(Offset(200, 200), Offset(200, 0), 200);
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });
    testWidgets('Shows timepillar when scrolled in y',
        (WidgetTester tester) async {
      await goToTimePillar(tester);

      await tester.flingFrom(Offset(200, 200), Offset(0, 200), 200);
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });
  });
}
