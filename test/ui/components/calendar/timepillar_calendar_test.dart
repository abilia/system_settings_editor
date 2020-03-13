import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/calendar/all.dart';

import '../../../mocks.dart';

void main() {
  MockActivityDb mockActivityDb;
  StreamController<DateTime> mockTicker;
  final changeViewButtonFinder = find.byKey(TestKey.changeView);
  final timePillarButtonFinder = find.byKey(TestKey.timePillarButton);
  final time = DateTime(2007, 08, 09, 10, 11);
  final activities = [FakeActivity.fullday(time)];

  ActivityResponse activityResponse = () => activities;

  final nextDayButtonFinder = find.byIcon(AbiliaIcons.go_to_next_page);
  final previusDayButtonFinder =
      find.byIcon(AbiliaIcons.return_to_previous_page);

  setUp(() {
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    mockTicker = StreamController<DateTime>();
    final mockTokenDb = MockTokenDb();
    when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    mockActivityDb = MockActivityDb();
    when(mockActivityDb.getActivities())
        .thenAnswer((_) => Future.value(activities));
    GetItInitializer()
      ..activityDb = mockActivityDb
      ..userDb = MockUserDb()
      ..ticker = (() => mockTicker.stream)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..tokenDb = mockTokenDb
      ..startTime = time
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
    expect(find.byType(TimePillarCalendar), findsOneWidget);
  });

  testWidgets('Can navigate back to agenda view', (WidgetTester tester) async {
    await goToTimePillar(tester);
    await tester.tap(changeViewButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.agendaListButton));
    await tester.pumpAndSettle();
    expect(find.byType(TimePillarCalendar), findsNothing);
    expect(find.byType(Agenda), findsOneWidget);
  });
  testWidgets('Shows all days activities', (WidgetTester tester) async {
    await goToTimePillar(tester);
    expect(find.byType(FullDayContainer), findsOneWidget);
  });

  group('timepillar scroll behaivor', () {
    testWidgets('timepillar shows', (WidgetTester tester) async {
      await goToTimePillar(tester);
      expect(find.byType(SliverTimePillar), findsOneWidget);
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

  group('timepillar dots', () {
    testWidgets('Current dots shows', (WidgetTester tester) async {
      await goToTimePillar(tester);
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(AnimatedDot), findsWidgets);
      expect(find.byType(FutureDots), findsNothing);
    });
    testWidgets('Yesterday shows only past dots', (WidgetTester tester) async {
      await goToTimePillar(tester);
      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(PastDots), findsWidgets);
      expect(find.byType(AnimatedDot), findsNothing);
      expect(find.byType(FutureDots), findsNothing);
    });
    testWidgets('Tomorrow shows only future dots', (WidgetTester tester) async {
      await goToTimePillar(tester);
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(FutureDots), findsWidgets);
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(AnimatedDot), findsNothing);
    });

    testWidgets('Only one current dot', (WidgetTester tester) async {
      await goToTimePillar(tester);
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == currentDotShape),
          hasLength(1));
    });

    testWidgets('Alwasy only one current dots', (WidgetTester tester) async {
      await goToTimePillar(tester);
      for (var i = 0; i < 20; i++) {
        mockTicker.add(time.add(1.minutes()));
        await tester.pumpAndSettle();
        expect(
            tester
                .widgetList<AnimatedDot>(find.byType(AnimatedDot))
                .where((d) => d.decoration == currentDotShape),
            hasLength(1));
      }
    });
  });
}
