import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/main.dart';
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
      expect(find.byType(CurrentDot), findsOneWidget);
    });
    testWidgets('Past dots shows', (WidgetTester tester) async {
      await goToTimePillar(tester);
      expect(find.byType(PastDot), findsWidgets);
    });
    testWidgets('Future dots shows', (WidgetTester tester) async {
      await goToTimePillar(tester);
      expect(find.byType(FutureDot), findsWidgets);
    });
    testWidgets('Yesterday shows only past dots', (WidgetTester tester) async {
      await goToTimePillar(tester);
      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(PastDots), findsWidgets);
      expect(find.byType(CurrentDot), findsNothing);
      expect(find.byType(FutureDot), findsNothing);
      expect(find.byType(FutureDots), findsNothing);
    });
    testWidgets('Tomorrow shows only future dots', (WidgetTester tester) async {
      await goToTimePillar(tester);
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(FutureDots), findsWidgets);
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(CurrentDot), findsNothing);
      expect(find.byType(FutureDot), findsNothing);
    });
    group('Categories', () {
      Finder leftCollapsedFinder;
      Finder rightCollapsedFinder;
      Finder leftFinder;
      Finder rightFinder;
      setUp(() {
        final translator = Translated.dictionaries[Locale('en')];
        final right = translator.right;
        final left = translator.left;
        leftFinder = find.text(left);
        rightFinder = find.text(right);
        leftCollapsedFinder = find.text(left.substring(0, 1));
        rightCollapsedFinder = find.text(right.substring(0, 1));
      });

      testWidgets('Starts collapsed', (WidgetTester tester) async {
        await goToTimePillar(tester);
        expect(leftCollapsedFinder, findsOneWidget);
        expect(rightCollapsedFinder, findsOneWidget);
        expect(leftFinder, findsNothing);
        expect(rightFinder, findsNothing);
      });
      testWidgets('Tap right', (WidgetTester tester) async {
        await goToTimePillar(tester);
        await tester.tap(rightCollapsedFinder);
        await tester.pumpAndSettle();
        expect(leftCollapsedFinder, findsOneWidget);
        expect(rightCollapsedFinder, findsNothing);
        expect(leftFinder, findsNothing);
        expect(rightFinder, findsOneWidget);
      });
      testWidgets('Tap left', (WidgetTester tester) async {
        await goToTimePillar(tester);
        await tester.tap(leftCollapsedFinder);
        await tester.pumpAndSettle();
        expect(leftCollapsedFinder, findsNothing);
        expect(rightCollapsedFinder, findsOneWidget);
        expect(leftFinder, findsOneWidget);
        expect(rightFinder, findsNothing);
      });
      testWidgets('Tap left, change day', (WidgetTester tester) async {
        await goToTimePillar(tester);
        await tester.tap(leftCollapsedFinder);
        await tester.tap(previusDayButtonFinder);
        await tester.pumpAndSettle();
        expect(leftCollapsedFinder, findsNothing);
        expect(rightCollapsedFinder, findsOneWidget);
        expect(leftFinder, findsOneWidget);
        expect(rightFinder, findsNothing);
      });

      testWidgets('Tap right, change day', (WidgetTester tester) async {
        await goToTimePillar(tester);
        await tester.tap(rightCollapsedFinder);
        await tester.tap(nextDayButtonFinder);

        await tester.pumpAndSettle();
        expect(leftCollapsedFinder, findsOneWidget);
        expect(rightCollapsedFinder, findsNothing);
        expect(leftFinder, findsNothing);
        expect(rightFinder, findsOneWidget);
      });
    });
  });
}
