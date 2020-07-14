import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  MockActivityDb mockActivityDb;
  final now = DateTime(2020, 06, 04, 11, 24);
  ActivityResponse activityResponse = () => [];

  final firstFullDayTitle = 'first full day',
      secondFullDayTitle = 'second full day',
      thirdFullDayTitle = 'third full day',
      forthFullDayTitle = 'forth full day';
  final firstFullDay =
          FakeActivity.fullday(now).copyWith(title: firstFullDayTitle),
      secondFullDay =
          FakeActivity.fullday(now).copyWith(title: secondFullDayTitle),
      thirdFullDay =
          FakeActivity.fullday(now).copyWith(title: thirdFullDayTitle),
      forthFullDay =
          FakeActivity.fullday(now).copyWith(title: forthFullDayTitle);

  setUp(() {
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockTokenDb = MockTokenDb();
    when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activityResponse()));
    GetItInitializer()
      ..activityDb = mockActivityDb
      ..userDb = MockUserDb()
      ..ticker =
          Ticker(stream: StreamController<DateTime>().stream, initialTime: now)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..tokenDb = mockTokenDb
      ..httpClient = Fakes.client(activityResponse)
      ..fileStorage = MockFileStorage()
      ..settingsDb = MockSettingsDb()
      ..alarmScheduler = noAlarmScheduler
      ..init();
  });

  tearDown(() {
    activityResponse = () => [];
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
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(<Activity>[FakeActivity.starts(now)]));

    activityResponse = () => [FakeActivity.starts(now.add(1.hours()))];

    await tester.pumpWidget(App());
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
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(<Activity>[FakeActivity.starts(now)]));

    activityResponse = () => [FakeActivity.starts(now)];

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsNothing);
  });

  testWidgets(
      'Agenda with one activity and a lot of passed activities should show the activity',
      (WidgetTester tester) async {
    final key = 'KEYKEYKEYKEYKEY';
    final activities = [
      for (int i = 0; i < 10; i++)
        Activity.createNew(
            title: 'past $i',
            startTime: now.subtract(Duration(minutes: i * 2)),
            alarmType: ALARM_SILENT),
      Activity.createNew(title: key, startTime: now),
    ];

    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activities));

    activityResponse = () => activities;

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsNothing);
    expect(find.text(key), findsOneWidget);
  });

  testWidgets('Past days are crossed over, future days and present day is not',
      (WidgetTester tester) async {
    final crossOverFinder = find.byType(CrossOver);
    final previousDayButtonFinder =
        find.byIcon(AbiliaIcons.return_to_previous_page);
    final nextDayButtonFinder = find.byIcon(AbiliaIcons.go_to_next_page);
    when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([]));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(crossOverFinder, findsNothing);
    await tester.tap(nextDayButtonFinder);
    await tester.pumpAndSettle();
    expect(crossOverFinder, findsNothing);
    await tester.tap(previousDayButtonFinder);
    await tester.tap(previousDayButtonFinder);
    await tester.pumpAndSettle();
    expect(crossOverFinder, findsOneWidget);
  });

  testWidgets('full day shows', (WidgetTester tester) async {
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value([firstFullDay]));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
  });

  testWidgets('past activities are hidden by scroll',
      (WidgetTester tester) async {
    final pastTitle = 'past',
        pastTitle2 = 'past2',
        currentTitle = 'current',
        futureTitle = 'future';
    final activites = [
      Activity.createNew(
        title: pastTitle,
        startTime: now.subtract(2.hours()),
        duration: 30.minutes(),
      ),
      Activity.createNew(
        title: pastTitle2,
        startTime: now.subtract(1.hours()),
        duration: 30.minutes(),
      ),
      Activity.createNew(
        title: currentTitle,
        startTime: now.subtract(5.minutes()),
        duration: 30.minutes(),
      ),
      Activity.createNew(
        title: futureTitle,
        startTime: now.add(5.minutes()),
        duration: 30.minutes(),
      )
    ];

    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activites));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(pastTitle), findsNothing);
    expect(find.text(pastTitle2),
        findsOneWidget); // Default scroll is showingn part of the closest past activity
    expect(find.text(currentTitle), findsOneWidget);
    expect(find.text(futureTitle), findsOneWidget);

    await tester.drag(find.byType(Agenda), Offset(0.0, 300));
    await tester.pumpAndSettle();

    expect(find.text(pastTitle), findsOneWidget);
    expect(find.text(pastTitle2), findsOneWidget);
    expect(find.text(currentTitle), findsOneWidget);
    expect(find.text(futureTitle), findsOneWidget);
  });

  testWidgets('two full day shows, but no show all full days button',
      (WidgetTester tester) async {
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value([firstFullDay, secondFullDay]));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.byType(ShowAllFullDayActivitiesButton), findsNothing);
  });

  testWidgets(
      'two full day and show-all-full-day-button shows, but not third full day',
      (WidgetTester tester) async {
    when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value([firstFullDay, secondFullDay, thirdFullDay]));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsNothing);
    expect(find.byType(ShowAllFullDayActivitiesButton), findsOneWidget);
  });

  testWidgets('tapping show-all-full-day-button shows all full days',
      (WidgetTester tester) async {
    when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
          firstFullDay,
          secondFullDay,
          thirdFullDay,
          forthFullDay,
        ]));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsNothing);
    expect(find.text(forthFullDayTitle), findsNothing);
    expect(find.byType(ShowAllFullDayActivitiesButton), findsOneWidget);

    await tester.tap(find.byType(ShowAllFullDayActivitiesButton));
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsOneWidget);
    expect(find.text(forthFullDayTitle), findsOneWidget);
  });

  testWidgets('tapping on a full day shows the full day',
      (WidgetTester tester) async {
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value([firstFullDay]));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.text(firstFullDayTitle));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPage), findsOneWidget);
  });

  testWidgets(
      'tapping show-all-full-day-button then on a full day shows all the tapped full day',
      (WidgetTester tester) async {
    when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
          firstFullDay,
          secondFullDay,
          thirdFullDay,
          forthFullDay,
        ]));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ShowAllFullDayActivitiesButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(forthFullDayTitle));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPage), findsOneWidget);
    expect(find.text(forthFullDayTitle), findsOneWidget);
  });

  testWidgets('category left is left of category right, and vice versa',
      (WidgetTester tester) async {
    final leftTitle =
            'leftTitleleftTitleleftTitleleftTitleleftTitleleftTitleleftTitleleftTitle',
        rightTitle =
            'rightTitlerightTitlerightTitlerightTitlerightTitlerightTitlerightTitle';
    when(mockActivityDb.getAllNonDeleted()).thenAnswer(
      (_) => Future.value(
        [
          Activity.createNew(
            title: leftTitle,
            startTime: now,
            category: Category.left,
          ),
          Activity.createNew(
            title: rightTitle,
            startTime: now,
            category: Category.right,
          ),
        ],
      ),
    );

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    final leftFinder = find.text(leftTitle),
        rightFinder = find.text(rightTitle);

    expect(leftFinder, findsOneWidget);
    expect(rightFinder, findsOneWidget);
    final leftLeft = tester.getBottomLeft(leftFinder);
    final rightLeft = tester.getBottomLeft(rightFinder);
    expect(rightLeft.dx, greaterThan(leftLeft.dx));
    final leftRight = tester.getTopRight(leftFinder);
    final rightRight = tester.getTopRight(rightFinder);
    expect(rightRight.dx, greaterThan(leftRight.dx));
  });

  testWidgets('CrossOver for past activities', (WidgetTester tester) async {
    when(mockActivityDb.getAllNonDeleted()).thenAnswer(
      (_) => Future.value(
        [
          Activity.createNew(
            title: 'test',
            startTime: now.subtract(1.hours()),
            duration: 30.minutes(),
          ),
        ],
      ),
    );

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(CrossOver), findsOneWidget);
  });
}
