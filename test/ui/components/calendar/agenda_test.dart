// @dart=2.9

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  final now = DateTime(2020, 06, 04, 11, 24);
  ActivityResponse activityResponse = () => [];
  GenericResponse genericResponse = () => [];

  final translate = Locales.language.values.first;

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

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    final mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activityResponse()));
    final mockGenericDb = MockGenericDb();
    when(mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));

    final mockUserFileDb = MockUserFileDb();
    when(
      mockUserFileDb.getMissingFiles(limit: anyNamed('limit')),
    ).thenAnswer(
      (value) => Future.value([]),
    );

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..genericDb = mockGenericDb
      ..ticker =
          Ticker(stream: StreamController<DateTime>().stream, initialTime: now)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client()
      ..fileStorage = MockFileStorage()
      ..userFileDb = mockUserFileDb
      ..alarmScheduler = noAlarmScheduler
      ..database = MockDatabase()
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  tearDown(() async {
    activityResponse = () => [];
    genericResponse = () => [];
    await GetIt.I.reset();
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
    activityResponse = () => [FakeActivity.starts(now)];

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsNothing);
  });

  testWidgets(
      'Agenda with one activity and a lot of passed activities should show the activity',
      (WidgetTester tester) async {
    final key = 'KEYKEYKEYKEYKEY';
    activityResponse = () => [
          for (int i = 0; i < 10; i++)
            Activity.createNew(
                title: 'past $i',
                startTime: now.subtract(Duration(minutes: i * 2)),
                alarmType: ALARM_SILENT),
          Activity.createNew(title: key, startTime: now),
        ];

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
    activityResponse = () => [];

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
    activityResponse = () => [firstFullDay];
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
    activityResponse = () => [
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

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

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
    activityResponse = () => [firstFullDay, secondFullDay];
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.byType(ShowAllFullDayActivitiesButton), findsNothing);
  });

  testWidgets(
      'two full day and show-all-full-day-button shows, but not third full day',
      (WidgetTester tester) async {
    activityResponse = () => [firstFullDay, secondFullDay, thirdFullDay];
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsNothing);
    expect(find.byType(ShowAllFullDayActivitiesButton), findsOneWidget);
  });

  testWidgets('tapping show-all-full-day-button shows all full days',
      (WidgetTester tester) async {
    activityResponse = () => [
          firstFullDay,
          secondFullDay,
          thirdFullDay,
          forthFullDay,
        ];
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
    activityResponse = () => [firstFullDay];

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.text(firstFullDayTitle));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPage), findsOneWidget);
  });

  testWidgets(
      'tapping show-all-full-day-button then on a full day shows all the tapped full day',
      (WidgetTester tester) async {
    activityResponse = () => [
          firstFullDay,
          secondFullDay,
          thirdFullDay,
          forthFullDay,
        ];

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ShowAllFullDayActivitiesButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(forthFullDayTitle));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPage), findsOneWidget);
    expect(find.text(forthFullDayTitle), findsOneWidget);
  });

  testWidgets('past day activities are correctly sorted',
      (WidgetTester tester) async {
    final yesterdayMorningTitle = 'yeterdayMorningTitle',
        yesterdayEveningTitle = 'yeterdayEveningTitle';
    activityResponse = () => [
          Activity.createNew(
            title: yesterdayMorningTitle,
            startTime: now.subtract(1.days()),
          ),
          Activity.createNew(
            title: yesterdayEveningTitle,
            startTime: now.subtract(1.days()).copyWith(hour: 22),
          ),
        ];

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(ActivityCard), findsNothing);

    await tester.tap(find.byIcon(AbiliaIcons.return_to_previous_page));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityCard), findsNWidgets(2));
    final morningPos = tester.getTopLeft(find.text(yesterdayMorningTitle));
    final eveningPos = tester.getTopLeft(find.text(yesterdayEveningTitle));
    expect(morningPos.dy, lessThan(eveningPos.dy));
  });

  testWidgets('category left is left of category right, and vice versa',
      (WidgetTester tester) async {
    final leftTitle =
            'leftTitleleftTitleleftTitleleftTitleleftTitleleftTitleleftTitleleftTitle',
        rightTitle =
            'rightTitlerightTitlerightTitlerightTitlerightTitlerightTitlerightTitle';
    activityResponse = () => [
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
        ];

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
    activityResponse = () => [
          Activity.createNew(
            title: 'test',
            startTime: now.subtract(1.hours()),
            duration: 30.minutes(),
          ),
        ];

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(CrossOver), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    final activity = Activity.createNew(
      title: 'normal',
      startTime: now,
      duration: 1.hours(),
    );
    activityResponse = () => [activity, firstFullDay];
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    await tester.verifyTts(find.text(activity.title), contains: activity.title);
    await tester.verifyTts(find.text(firstFullDay.title),
        contains: firstFullDay.title);
    await tester.verifyTts(find.text(firstFullDay.title),
        contains: translate.fullDay);

    await tester.verifyTts(find.byType(AppBarTitle), contains: '${now.day}');
  });

  testWidgets('tts no activities', (WidgetTester tester) async {
    activityResponse = () => [];
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    await tester.verifyTts(find.text(translate.noActivities),
        exact: translate.noActivities);
  });

  group('Categories', () {
    final translated = Locales.language.values.first;
    final right = translated.right;
    final left = translated.left;
    final leftCollapsedFinder = find.text(left.substring(0, 1));
    final rightCollapsedFinder = find.text(right.substring(0, 1));
    final leftFinder = find.text(left);
    final rightFinder = find.text(right);
    final nextDayButtonFinder = find.byIcon(AbiliaIcons.go_to_next_page);
    final previusDayButtonFinder =
        find.byIcon(AbiliaIcons.return_to_previous_page);

    testWidgets('Exists', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(CategoryLeft), findsOneWidget);
      expect(find.byType(CategoryRight), findsOneWidget);
    });

    testWidgets('Starts expanded', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);
      expect(leftCollapsedFinder, findsNothing);
      expect(rightCollapsedFinder, findsNothing);
    });

    testWidgets('Tap right', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(rightFinder);
      await tester.pumpAndSettle();
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsNothing);
      expect(leftCollapsedFinder, findsNothing);
      expect(rightCollapsedFinder, findsOneWidget);
    });

    testWidgets('Tap left', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(leftFinder);
      await tester.pumpAndSettle();
      expect(leftFinder, findsNothing);
      expect(rightFinder, findsOneWidget);
      expect(leftCollapsedFinder, findsOneWidget);
      expect(rightCollapsedFinder, findsNothing);
    });

    testWidgets('tts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.verifyTts(leftFinder, exact: translated.left);
      await tester.verifyTts(rightFinder, exact: translated.right);
      await tester.tap(leftFinder);
      await tester.tap(rightFinder);
      await tester.pumpAndSettle();
      await tester.verifyTts(leftCollapsedFinder, exact: translated.left);
      await tester.verifyTts(rightCollapsedFinder, exact: translated.right);
    });

    testWidgets('Tap left, change day', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(leftFinder);
      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();
      expect(leftFinder, findsNothing);
      expect(rightFinder, findsOneWidget);
      expect(leftCollapsedFinder, findsOneWidget);
      expect(rightCollapsedFinder, findsNothing);
    });

    testWidgets('Tap right, change day', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(rightFinder);
      await tester.tap(nextDayButtonFinder);

      await tester.pumpAndSettle();
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsNothing);
      expect(leftCollapsedFinder, findsNothing);
      expect(rightCollapsedFinder, findsOneWidget);
    });

    testWidgets('memoplanner settings - category name ',
        (WidgetTester tester) async {
      final leftCategoryName = 'New Left', rightCategoryName = 'New Right';
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: leftCategoryName,
                identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: rightCategoryName,
                identifier: MemoplannerSettings.calendarActivityTypeRightKey,
              ),
            )
          ];

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.text(leftCategoryName), findsOneWidget);
      expect(find.text(rightCategoryName), findsOneWidget);
      expect(leftFinder, findsNothing);
      expect(rightFinder, findsNothing);
    });

    testWidgets('memoplanner settings - show categories ',
        (WidgetTester tester) async {
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier:
                    MemoplannerSettings.calendarActivityTypeShowTypesKey,
              ),
            ),
          ];

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(CategoryLeft), findsNothing);
      expect(find.byType(CategoryRight), findsNothing);
    });

    testWidgets(' memoplanner settings - category name push update ',
        (WidgetTester tester) async {
      final leftCategoryName = 'Something unique',
          rightCategoryName = 'Another not seen before string';
      final pushBloc = PushBloc();

      await tester.pumpWidget(App(pushBloc: pushBloc));
      await tester.pumpAndSettle();

      expect(find.text(leftCategoryName), findsNothing);
      expect(find.text(rightCategoryName), findsNothing);
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);

      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: leftCategoryName,
                identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: rightCategoryName,
                identifier: MemoplannerSettings.calendarActivityTypeRightKey,
              ),
            )
          ];
      pushBloc.add(PushEvent('collapse_key'));

      await tester.pumpAndSettle();

      expect(find.text(leftCategoryName), findsOneWidget);
      expect(find.text(rightCategoryName), findsOneWidget);
      expect(leftFinder, findsNothing);
      expect(rightFinder, findsNothing);
    });

    testWidgets(' memoplanner settings - show category push update ',
        (WidgetTester tester) async {
      final pushBloc = PushBloc();
      await tester.pumpWidget(App(pushBloc: pushBloc));
      await tester.pumpAndSettle();

      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);
      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);

      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier:
                    MemoplannerSettings.calendarActivityTypeShowTypesKey,
              ),
            ),
          ];
      pushBloc.add(PushEvent('collapse_key'));

      await tester.pumpAndSettle();

      expect(leftFinder, findsNothing);
      expect(rightFinder, findsNothing);
      expect(find.byType(CategoryRight), findsNothing);
      expect(find.byType(CategoryLeft), findsNothing);
    });
  });
}
