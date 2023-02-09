import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/activity_db_in_memory.dart';
import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/tts.dart';

void main() {
  final now = DateTime(2020, 06, 04, 11, 24);
  late ActivityDbInMemory activityDbInMemory;
  GenericResponse genericResponse = () => [];
  TimerResponse timerResponse = () => [];
  List<Activity> activityResponse = [];
  Response licenseResponse = Fakes.licenseResponseExpires(now.add(5.days()));

  final translate = Locales.language.values.first;

  const firstFullDayTitle = 'first full day',
      secondFullDayTitle = 'second full day',
      thirdFullDayTitle = 'third full day',
      forthFullDayTitle = 'forth full day';
  final firstFullDay =
          FakeActivity.fullDay(now).copyWith(title: firstFullDayTitle),
      secondFullDay =
          FakeActivity.fullDay(now).copyWith(title: secondFullDayTitle),
      thirdFullDay =
          FakeActivity.fullDay(now).copyWith(title: thirdFullDayTitle),
      forthFullDay =
          FakeActivity.fullDay(now).copyWith(title: forthFullDayTitle);

  late StreamController<DateTime> timeTicker;

  bool appBarCrossOver() => (find
          .descendant(
            of: find.byType(CalendarAppBar),
            matching: find.byType(CrossOver),
          )
          .evaluate()
          .first
          .widget as CrossOver)
      .applyCross;

  bool activityCardCrossOver() => (find
          .descendant(
            of: find.byType(ActivityCard),
            matching: find.byType(CrossOver),
            skipOffstage: false,
          )
          .evaluate()
          .first
          .widget as CrossOver)
      .applyCross;

  setUpAll(() {
    tz.initializeTimeZones();
    setupPermissions();
  });

  setUp(() async {
    setupPermissions();
    setupFakeTts();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;
    timeTicker = StreamController<DateTime>();
    activityDbInMemory = ActivityDbInMemory();

    genericResponse = () => [
          Generic.createNew<MemoplannerSettingData>(
            data: MemoplannerSettingData.fromData(
                data: DayCalendarType.list.index,
                identifier:
                    DayCalendarViewOptionsSettings.viewOptionsCalendarTypeKey),
          ),
        ];

    final mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));
    when(() => mockGenericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.getLastRevision())
        .thenAnswer((_) => Future.value(66));
    when(() => mockGenericDb.insert(any())).thenAnswer((_) => Future.value());

    final mockTimerDb = MockTimerDb();
    when(() => mockTimerDb.getAllTimers())
        .thenAnswer((_) => Future.value(timerResponse()));
    when(() => mockTimerDb.getRunningTimersFrom(any()))
        .thenAnswer((_) => Future.value(timerResponse()));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = activityDbInMemory
      ..genericDb = mockGenericDb
      ..timerDb = mockTimerDb
      ..sortableDb = FakeSortableDb()
      ..ticker = Ticker.fake(initialTime: now, stream: timeTicker.stream)
      ..fireBasePushService = FakeFirebasePushService()
      ..client = Fakes.client(
        licenseResponse: () => licenseResponse,
        activityResponse: () => activityResponse,
        genericResponse: () => genericResponse(),
      )
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..database = FakeDatabase()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() async {
    genericResponse = () => [];
    timerResponse = () => [];
    activityResponse = [];
    licenseResponse = Fakes.licenseResponseExpires(now.add(5.days()));
    timeTicker.close();
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
    activityDbInMemory
        .initWithActivity(FakeActivity.starts(now.add(1.hours())));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(ActivityCard), findsOneWidget);
  });

  testWidgets('Activity loaded from backend when license is valid',
      (WidgetTester tester) async {
    activityResponse = [FakeActivity.starts(now.add(1.hours()))];

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(ActivityCard), findsOneWidget);
  });

  testWidgets('Activity not loaded from backend when license is invalid',
      (WidgetTester tester) async {
    licenseResponse = Fakes.licenseResponseExpires(now.subtract(5.days()));
    activityResponse = [FakeActivity.starts(now.add(1.hours()))];

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(ActivityCard), findsNothing);
  });

  testWidgets('Empty agenda should not show Go to now-button',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsNothing);
  });

  testWidgets('Agenda with one activity should not show Go to now-button',
      (WidgetTester tester) async {
    activityDbInMemory.initWithActivity(FakeActivity.starts(now));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsNothing);
  });

  testWidgets('Agenda background is dark during night interval',
      (WidgetTester tester) async {
    timeTicker.add(now.add(const Duration(hours: 16)));
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    final background = tester
        .firstWidget(find.byKey(TestKey.calendarBackgroundColor)) as Container;
    expect(background.color, TimepillarCalendar.nightBackgroundColor);
  });

  testWidgets(
      'Agenda with one activity and a lot of passed activities should show the activity',
      (WidgetTester tester) async {
    const key = 'KEY KEY KEY KEY KEY';
    activityDbInMemory.initWithActivities([
      for (int i = 0; i < 10; i++)
        Activity.createNew(
            title: 'past $i',
            startTime: now.subtract(Duration(minutes: i * 2)),
            alarmType: alarmSilent),
      Activity.createNew(title: key, startTime: now),
    ]);

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsNothing);
    expect(find.text(key), findsOneWidget);
  });

  testWidgets('Past days are crossed over, future days and present day is not',
      (WidgetTester tester) async {
    final previousDayButtonFinder =
        find.byIcon(AbiliaIcons.returnToPreviousPage);
    final nextDayButtonFinder = find.byIcon(AbiliaIcons.goToNextPage);
    activityDbInMemory.initWithActivities([]);

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(appBarCrossOver(), false);
    await tester.tap(nextDayButtonFinder);
    await tester.pumpAndSettle();
    expect(appBarCrossOver(), false);
    await tester.tap(previousDayButtonFinder);
    await tester.tap(previousDayButtonFinder);
    await tester.pumpAndSettle();
    expect(appBarCrossOver(), true);
  });

  testWidgets('full day shows', (WidgetTester tester) async {
    activityDbInMemory.initWithActivity(firstFullDay);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.text(firstFullDayTitle), findsOneWidget);
  });

  testWidgets('past activities are hidden by scroll',
      (WidgetTester tester) async {
    const pastTitle = 'past',
        pastTitle2 = 'past2',
        currentTitle = 'current',
        futureTitle = 'future';
    activityDbInMemory.initWithActivities([
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
      ),
    ]);

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(pastTitle), findsNothing);
    // Default scroll is showing part of the closest past activity
    expect(find.text(pastTitle2), findsOneWidget);
    expect(find.text(currentTitle), findsOneWidget);
    expect(find.text(futureTitle), findsOneWidget);

    await tester.drag(find.byType(Agenda), const Offset(0.0, 300));
    await tester.pumpAndSettle();

    expect(find.text(pastTitle), findsOneWidget);
    expect(find.text(pastTitle2), findsOneWidget);
    expect(find.text(currentTitle), findsOneWidget);
    expect(find.text(futureTitle), findsOneWidget);
  });

  testWidgets('two full day shows, but no show all full days button',
      (WidgetTester tester) async {
    activityDbInMemory.initWithActivities([firstFullDay, secondFullDay]);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.byType(FullDayActivitiesButton), findsNothing);
  });

  testWidgets(
      'full day activities are placed in correct order both in FullDayContainer and FullDayList',
      (WidgetTester tester) async {
    activityDbInMemory
        .initWithActivities([firstFullDay, secondFullDay, thirdFullDay]);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    final t1AgendaPos = tester.getCenter(find.text(firstFullDayTitle));
    final t2AgendaPos = tester.getCenter(find.text(secondFullDayTitle));
    expect(t1AgendaPos.dx, lessThan(t2AgendaPos.dx));
    await tester.tap(find.byType(FullDayActivitiesButton));
    await tester.pumpAndSettle();
    expect(find.byType(FullDayListPage), findsOneWidget);
    final t1FullDayListPos = tester.getCenter(find.text(firstFullDayTitle));
    final t2FullDayListPos = tester.getCenter(find.text(secondFullDayTitle));
    final t3FullDayListPos = tester.getCenter(find.text(thirdFullDayTitle));
    expect(t1FullDayListPos.dy, lessThan(t2FullDayListPos.dy));
    expect(t2FullDayListPos.dy, lessThan(t3FullDayListPos.dy));
  });

  testWidgets(
      'two full day and show-all-full-day-button shows, but not third full day',
      (WidgetTester tester) async {
    activityDbInMemory
        .initWithActivities([firstFullDay, secondFullDay, thirdFullDay]);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsNothing);
    expect(find.byType(FullDayActivitiesButton), findsOneWidget);
  });

  testWidgets('tapping show-all-full-day-button shows all full days',
      (WidgetTester tester) async {
    activityDbInMemory.initWithActivities([
      firstFullDay,
      secondFullDay,
      thirdFullDay,
      forthFullDay,
    ]);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsNothing);
    expect(find.text(forthFullDayTitle), findsNothing);
    expect(
      find.byType(FullDayActivitiesButton),
      findsOneWidget,
    );

    await tester.tap(find.byType(FullDayActivitiesButton));
    await tester.pumpAndSettle();

    expect(find.text(firstFullDayTitle), findsOneWidget);
    expect(find.text(secondFullDayTitle), findsOneWidget);
    expect(find.text(thirdFullDayTitle), findsOneWidget);
    expect(find.text(forthFullDayTitle), findsOneWidget);
  });

  testWidgets('tapping on a full day shows the full day',
      (WidgetTester tester) async {
    activityDbInMemory.initWithActivities([firstFullDay]);

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.text(firstFullDayTitle));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPage), findsOneWidget);
  });

  testWidgets(
      'tapping show-all-full-day-button then on a full day shows all the tapped full day',
      (WidgetTester tester) async {
    activityDbInMemory.initWithActivities([
      firstFullDay,
      secondFullDay,
      thirdFullDay,
      forthFullDay,
    ]);

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FullDayActivitiesButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(forthFullDayTitle));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityPage), findsOneWidget);
    expect(find.text(forthFullDayTitle), findsOneWidget);
  });

  testWidgets('past day activities are correctly sorted',
      (WidgetTester tester) async {
    const yesterdayMorningTitle = 'yesterdayMorningTitle',
        yesterdayEveningTitle = 'yesterdayEveningTitle';
    activityDbInMemory.initWithActivities([
      Activity.createNew(
        title: yesterdayMorningTitle,
        startTime: now.subtract(1.days()),
      ),
      Activity.createNew(
        title: yesterdayEveningTitle,
        startTime: now.subtract(1.days()).copyWith(hour: 22),
      ),
    ]);

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(ActivityCard), findsNothing);

    await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityCard), findsNWidgets(2));
    final morningPos = tester.getTopLeft(find.text(yesterdayMorningTitle));
    final eveningPos = tester.getTopLeft(find.text(yesterdayEveningTitle));
    expect(morningPos.dy, lessThan(eveningPos.dy));
  });

  testWidgets('category left is left of category right, and vice versa',
      (WidgetTester tester) async {
    const leftTitle =
            'leftTitleLeftTitleLeftTitleLeftTitleLeftTitleLeftTitleLeftTitle',
        rightTitle =
            'RightTitleRightTitleRightTitleRightTitleRightTitleRightTitleRight';
    activityDbInMemory.initWithActivities([
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
    ]);

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

  group('category offset', () {
    testWidgets('category right has category offset',
        (WidgetTester tester) async {
      activityDbInMemory.initWithActivities([
        Activity.createNew(
          title: 'right title',
          startTime: now,
          category: Category.right,
        )
      ]);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      final padding = tester
          .widget<Padding>(
            find.ancestor(
              of: find.byType(ActivityCard),
              matching: find.byType(Padding),
            ),
          )
          .padding
          .resolve(TextDirection.ltr);
      expect(
        padding.left,
        greaterThanOrEqualTo(layout.eventCard.categorySideOffset),
      );
    });

    testWidgets('category left has category offset',
        (WidgetTester tester) async {
      activityDbInMemory.initWithActivities([
        Activity.createNew(
          title: 'left title',
          startTime: now,
          category: Category.left,
        )
      ]);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      final padding = tester
          .widget<Padding>(
            find.ancestor(
              of: find.byType(ActivityCard),
              matching: find.byType(Padding),
            ),
          )
          .padding
          .resolve(TextDirection.ltr);
      expect(
        padding.right,
        greaterThanOrEqualTo(layout.eventCard.categorySideOffset),
      );
    });
  });

  testWidgets('CrossOver for past activities', (WidgetTester tester) async {
    activityDbInMemory.initWithActivities([
      Activity.createNew(
        title: 'test',
        startTime: now.subtract(1.hours()),
        duration: 30.minutes(),
      ),
    ]);

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(ActivityCard), findsOneWidget);
    expect(activityCardCrossOver(), true);
  });

  testWidgets('signed off past activity shows CrossOver',
      (WidgetTester tester) async {
    // Arrange
    activityDbInMemory.initWithActivities([
      Activity.createNew(
        title: 'title',
        startTime: now.subtract(1.hours()),
        duration: 30.minutes(),
        checkable: true,
        signedOffDates: [now].map(whaleDateFormat),
      )
    ]);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    // Assert
    expect(activityCardCrossOver(), true);
  });

  testWidgets('tts', (WidgetTester tester) async {
    final activity = Activity.createNew(
      title: 'normal',
      startTime: now,
      duration: 1.hours(),
    );
    activityDbInMemory.initWithActivities([activity, firstFullDay]);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    await tester.verifyTts(find.text(activity.title), contains: activity.title);
    await tester.verifyTts(
      find.text(firstFullDay.title),
      contains: firstFullDay.title,
    );
    await tester.verifyTts(
      find.text(firstFullDay.title),
      contains: translate.fullDay,
    );

    await tester.verifyTts(find.byType(AppBarTitle), contains: '${now.day}');
  });

  testWidgets('tts no activities', (WidgetTester tester) async {
    activityDbInMemory.initWithActivities([]);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    await tester.verifyTts(find.text(translate.noActivities),
        exact: translate.noActivities);
  });

  group('Categories', () {
    final translated = Locales.language.values.first;
    final right = translated.right;
    final left = translated.left;
    final leftFinder = find.text(left);
    final rightFinder = find.text(right);
    final nextDayButtonFinder = find.byIcon(AbiliaIcons.goToNextPage);
    final previousDayButtonFinder =
        find.byIcon(AbiliaIcons.returnToPreviousPage);

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
    });

    testWidgets('Tap right', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(rightFinder);
      await tester.pumpAndSettle();
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsNothing);
    });

    testWidgets('Tap left', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(leftFinder);
      await tester.pumpAndSettle();
      expect(leftFinder, findsNothing);
      expect(rightFinder, findsOneWidget);
    });

    testWidgets('tts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.verifyTts(leftFinder, exact: translated.left);
      await tester.verifyTts(rightFinder, exact: translated.right);
      await tester.tap(leftFinder);
      await tester.tap(rightFinder);
      await tester.pumpAndSettle();
      await tester.verifyTts(
          find.descendant(
              of: find.byType(LeftCategory),
              matching: find.byType(CategoryImage)),
          exact: translated.left);
      await tester.verifyTts(
          find.descendant(
              of: find.byType(RightCategory),
              matching: find.byType(CategoryImage)),
          exact: translated.right);
    });

    testWidgets('Tap left, change day', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(leftFinder);
      await tester.tap(previousDayButtonFinder);
      await tester.pumpAndSettle();
      expect(leftFinder, findsNothing);
      expect(rightFinder, findsOneWidget);
    });

    testWidgets('Tap right, change day', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(rightFinder);
      await tester.tap(nextDayButtonFinder);

      await tester.pumpAndSettle();
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsNothing);
    });

    testWidgets('memoplanner settings - category name ',
        (WidgetTester tester) async {
      const leftCategoryName = 'New Left', rightCategoryName = 'New Right';
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: leftCategoryName,
                identifier: CategoriesSettings.calendarActivityTypeLeftKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: rightCategoryName,
                identifier: CategoriesSettings.calendarActivityTypeRightKey,
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
                identifier: CategoriesSettings.calendarActivityTypeShowTypesKey,
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
      const leftCategoryName = 'Something unique',
          rightCategoryName = 'Another not seen before string';
      final pushCubit = PushCubit();

      await tester.pumpWidget(App(pushCubit: pushCubit));
      await tester.pumpAndSettle();

      expect(find.text(leftCategoryName), findsNothing);
      expect(find.text(rightCategoryName), findsNothing);
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);

      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: leftCategoryName,
                identifier: CategoriesSettings.calendarActivityTypeLeftKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: rightCategoryName,
                identifier: CategoriesSettings.calendarActivityTypeRightKey,
              ),
            )
          ];
      pushCubit.fakePush();

      await tester.pumpAndSettle();

      expect(find.text(leftCategoryName), findsOneWidget);
      expect(find.text(rightCategoryName), findsOneWidget);
      expect(leftFinder, findsNothing);
      expect(rightFinder, findsNothing);
    });

    testWidgets(' memoplanner settings - show category push update ',
        (WidgetTester tester) async {
      final pushCubit = PushCubit();
      await tester.pumpWidget(App(pushCubit: pushCubit));
      await tester.pumpAndSettle();

      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);
      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);

      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: CategoriesSettings.calendarActivityTypeShowTypesKey,
              ),
            ),
          ];
      pushCubit.fakePush();

      await tester.pumpAndSettle();

      expect(leftFinder, findsNothing);
      expect(rightFinder, findsNothing);
      expect(find.byType(CategoryRight), findsNothing);
      expect(find.byType(CategoryLeft), findsNothing);
    });

    testWidgets('memoplanner settings - show colors true',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      final rightBoxDecoration = tester
          .widget<Container>(find.descendant(
              of: find.descendant(
                  of: find.byType(CategoryRight),
                  matching: find.byType(CategoryImage)),
              matching: find.byType(Container)))
          .decoration as BoxDecoration;

      expect(rightBoxDecoration.color, rightCategoryActiveColor);
      final leftBoxDecoration = tester
          .widget<Container>(find.descendant(
              of: find.descendant(
                  of: find.byType(CategoryLeft),
                  matching: find.byType(CategoryImage)),
              matching: find.byType(Container)))
          .decoration as BoxDecoration;

      expect(leftBoxDecoration.color, leftCategoryActiveColor);
    });

    testWidgets('memoplanner settings - show colors false',
        (WidgetTester tester) async {
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: CategoriesSettings.calendarActivityTypeShowColorKey,
              ),
            ),
          ];

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(CategoryImage), findsNothing);
    });

    testWidgets('memoplanner settings - show colors false, leftImageId',
        (WidgetTester tester) async {
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: CategoriesSettings.calendarActivityTypeShowColorKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: 'file id',
                identifier: CategoriesSettings.calendarActivityTypeLeftImageKey,
              ),
            ),
          ];

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(CategoryImage), findsOneWidget);
    });

    testWidgets(
        'memoplanner settings - show colors true, left, right, future, past, fullDay correct color',
        (WidgetTester tester) async {
      final soon = now.add(30.minutes());
      final just = now.subtract(30.minutes());

      final a1 = Activity.createNew(
            startTime: soon,
            title: 'left soon',
            category: Category.left,
          ),
          a2 = Activity.createNew(
            startTime: soon,
            title: 'right soon',
            category: Category.right,
          ),
          a3 = Activity.createNew(
            startTime: just,
            title: 'left just',
            category: Category.left,
          ),
          a4 = Activity.createNew(
            startTime: just,
            title: 'right just',
            category: Category.right,
          ),
          a5 = Activity.createNew(
            startTime: now.onlyDays(),
            title: 'fullDay',
            fullDay: true,
          );
      activityDbInMemory.initWithActivities([a1, a2, a3, a4, a5]);

      void expectCorrectColor(String title, Color expectedColor) {
        final boxDecoration = tester
            .widget<AnimatedContainer>(find
                .descendant(
                    of: find.widgetWithText(ActivityCard, title,
                        skipOffstage: false),
                    matching:
                        find.byType(AnimatedContainer, skipOffstage: false),
                    skipOffstage: false)
                .first)
            .decoration as BoxDecoration;
        expect(
          boxDecoration.border?.bottom.color,
          expectedColor,
        );
      }

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expectCorrectColor(a1.title, leftCategoryActiveColor);
      expectCorrectColor(a2.title, rightCategoryActiveColor);
      expectCorrectColor(a3.title, noCategoryColor);
      expectCorrectColor(a4.title, rightCategoryInactiveColor);
      expectCorrectColor(a5.title, noCategoryColor);
    });

    testWidgets(
        'memoplanner settings - show colors true, category false -> no colors',
        (WidgetTester tester) async {
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: CategoriesSettings.calendarActivityTypeShowColorKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: CategoriesSettings.calendarActivityTypeShowTypesKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                  data: DayCalendarType.list.index,
                  identifier: DayCalendarViewOptionsSettings
                      .viewOptionsCalendarTypeKey),
            ),
          ];

      final soon = now.add(30.minutes());
      final just = now.subtract(30.minutes());

      final a1 = Activity.createNew(
            startTime: soon,
            title: 'left soon',
            category: Category.left,
          ),
          a2 = Activity.createNew(
            startTime: soon,
            title: 'right soon',
            category: Category.right,
          ),
          a3 = Activity.createNew(
            startTime: just,
            title: 'left just',
            category: Category.left,
          ),
          a4 = Activity.createNew(
            startTime: just,
            title: 'right just',
            category: Category.right,
          );
      activityDbInMemory.initWithActivities([a1, a2, a3, a4]);

      void expectCorrectColor(String title, Color expectedColor) {
        final boxDecoration = tester
            .widget<AnimatedContainer>(find
                .descendant(
                    of: find.widgetWithText(ActivityCard, title,
                        skipOffstage: false),
                    matching:
                        find.byType(AnimatedContainer, skipOffstage: false),
                    skipOffstage: false)
                .first)
            .decoration as BoxDecoration;
        expect(
          boxDecoration.border?.bottom.color,
          expectedColor,
        );
      }

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expectCorrectColor(a1.title, noCategoryColor);
      expectCorrectColor(a2.title, noCategoryColor);
      expectCorrectColor(a3.title, noCategoryColor);
      expectCorrectColor(a4.title, noCategoryColor);
    });

    group('timers', () {
      testWidgets('Timer visible', (WidgetTester tester) async {
        final timer = AbiliaTimer.createNew(
          title: 'title',
          startTime: now,
          duration: 5.minutes(),
        );
        timerResponse = () => [timer];

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerCard), findsOneWidget);
        expect(find.text(timer.title), findsOneWidget);
      });

      testWidgets('Past Timer visible', (WidgetTester tester) async {
        final timer = AbiliaTimer.createNew(
          title: 'title',
          startTime: now.subtract(10.minutes()),
          duration: 5.minutes(),
        );
        timerResponse = () => [timer];

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerCard), findsOneWidget);
        expect(find.text(timer.title), findsOneWidget);
      });

      testWidgets('Starting after but ending before is shown before',
          (WidgetTester tester) async {
        final timerPast = AbiliaTimer.createNew(
              title: 'timerPast',
              startTime: now.subtract(10.minutes()),
              duration: 5.minutes(),
            ),
            timerOngoing = AbiliaTimer.createNew(
              title: 'timerOngoing',
              startTime: now.subtract(20.minutes()),
              duration: 30.minutes(),
            );
        timerResponse = () => [timerPast, timerOngoing];

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerCard), findsNWidgets(2));

        final ongoingPosition = tester.getBottomLeft(
          find.ancestor(
            of: find.text(timerOngoing.title),
            matching: find.byType(TimerCard),
          ),
        );

        final pastPosition = tester.getBottomLeft(
          find.ancestor(
            of: find.text(timerPast.title),
            matching: find.byType(TimerCard),
          ),
        );

        expect(ongoingPosition.dy, greaterThan(pastPosition.dy));
      });

      testWidgets('Timer when time ticks to past visible',
          (WidgetTester tester) async {
        final timer = AbiliaTimer.createNew(
          title: 'title',
          startTime: now,
          duration: 1.minutes(),
        );
        timerResponse = () => [timer];

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerCard), findsOneWidget);
        expect(find.text(timer.title), findsOneWidget);

        final timerCardBefore =
            tester.widget<TimerCard>(find.byType(TimerCard));
        expect(timerCardBefore.timerOccasion.occasion, Occasion.current);

        timeTicker.add(now.add(1.minutes() + 1.seconds()));
        await tester.pumpAndSettle();

        expect(find.byType(TimerAlarmPage), findsOneWidget);
        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();

        final timerCardAfter = tester.widget<TimerCard>(find.byType(TimerCard));
        expect(timerCardAfter.timerOccasion.occasion, Occasion.past);
      });

      testWidgets('Timer shows correct time left', (WidgetTester tester) async {
        final timer = AbiliaTimer.createNew(
          title: 'title',
          startTime: now,
          duration: 10.minutes(),
        );
        timerResponse = () => [timer];

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();

        expect(
          find.descendant(
              of: find.byType(TimerCard), matching: find.text('10:00')),
          findsOneWidget,
        );

        timeTicker.add(now.add(30.seconds()));
        await tester.pumpAndSettle();

        expect(
          find.descendant(
              of: find.byType(TimerCard), matching: find.text('09:30')),
          findsOneWidget,
        );
        timeTicker.add(now.add(10.minutes()));

        await tester.pumpAndSettle();
        expect(
          find.descendant(
              of: find.byType(TimerCard), matching: find.text('00:00')),
          findsOneWidget,
        );
      });

      testWidgets('Timer when time ticks every second',
          (WidgetTester tester) async {
        const duration = Duration(seconds: 30);
        final timer = AbiliaTimer.createNew(
          title: 'title',
          startTime: now,
          duration: duration,
        );
        timerResponse = () => [timer];

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();

        for (var i = 1; i <= duration.inSeconds; i++) {
          timeTicker.add(now.add(i.seconds()));
          await tester.pumpAndSettle();
          final sLeft = '${max(0, duration.inSeconds - i)}'.padLeft(2, '0');
          expect(find.text('00:$sLeft'), findsOneWidget);
        }
        timeTicker.add(now.add(duration).add(1.seconds()));
        await tester.pumpAndSettle();
        expect(find.byType(TimerAlarmPage), findsOneWidget);
      });

      testWidgets(
          'yesterdays timers shows on yesterday and today, disappear after 24h',
          (WidgetTester tester) async {
        final timer1 = AbiliaTimer.createNew(
          title: 'old timer',
          startTime: now.subtract(23.hours()),
          duration: 22.hours(),
        );
        timerResponse = () => [timer1];

        find.byIcon(AbiliaIcons.returnToPreviousPage);

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();

        expect(find.byType(TimerCard), findsOneWidget);
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
        await tester.pumpAndSettle();
        expect(find.byType(TimerCard), findsOneWidget);
        timeTicker.add(now.add(1.hours() + 1.minutes()));
        await tester.pumpAndSettle();
        expect(find.byType(TimerCard), findsNothing);
        await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
        await tester.pumpAndSettle();
        expect(find.byType(TimerCard), findsNothing);
      });
    });
  });

  group('Recurring', () {
    testWidgets(
        'SGC-2304 - Changing alarm on a recurring activity'
        'and choosing only this day will not change the day of the activity',
        (WidgetTester tester) async {
      final time = DateTime(2020, 06, 04, 10, 00);
      GetIt.I<Ticker>().setFakeTime(time, setTicker: false);
      activityDbInMemory.initWithActivities([
        Activity.createNew(
          title: 'test',
          startTime: time.subtract(10.days()),
          duration: 30.minutes(),
          recurs: Recurs.everyDay,
        ),
      ]);

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityCard), findsOneWidget);

      await tester.tap(find.byType(ActivityCard));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.editAlarm));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.noAlarm));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.onlyThisDay));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.navigationPrevious));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityCard), findsOneWidget);
    });

    testWidgets(
        'SGC-2304 - Changing alarm on a recurring activity and choosing this day and forward'
        'will not change the alarm of activities before the chosen activity',
        (WidgetTester tester) async {
      final time = DateTime(2020, 06, 04, 10, 00);
      GetIt.I<Ticker>().setFakeTime(time, setTicker: false);
      activityDbInMemory.initWithActivities([
        Activity.createNew(
          title: 'test',
          startTime: time.subtract(10.days()),
          duration: 30.minutes(),
          recurs: Recurs.everyDay,
        ),
      ]);

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityCard), findsOneWidget);

      await tester.tap(find.byType(ActivityCard));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.editAlarm));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.noAlarm));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.thisDayAndForward));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.navigationPrevious));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ActivityCard));
      await tester.pumpAndSettle();

      expect(find.byIcon(const Alarm(type: AlarmType.noAlarm).iconData()),
          findsNothing);
    });
  });

  testWidgets('Opacity for nighttime activities', (WidgetTester tester) async {
    final nightTime = DateTime(2020, 06, 04, 01, 24);
    GetIt.I<Ticker>().setFakeTime(nightTime, setTicker: false);
    activityDbInMemory.initWithActivities([
      Activity.createNew(
        title: 'test',
        startTime: nightTime.subtract(1.minutes()),
        duration: 30.minutes(),
      ),
    ]);

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();

    final finder = find.byType(Opacity).first;
    final op = finder.evaluate().single.widget as Opacity;
    expect(op.opacity, 0.4);
  });
}
