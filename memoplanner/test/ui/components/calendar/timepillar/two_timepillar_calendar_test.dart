import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:seagull_fakes/all.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../../fakes/activity_db_in_memory.dart';
import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  late StreamController<DateTime> mockTicker;
  late ActivityDbInMemory mockActivityDb;
  final time = DateTime(2021, 09, 02, 12, 47);
  const leftTitle = 'LeftCategoryActivity',
      rightTitle = 'RightCategoryActivity';

  GenericResponse genericResponse = () => [];
  TimerResponse timerResponse = () => [];

  final nextDayButtonFinder = find.byIcon(AbiliaIcons.goToNextPage);
  final previusDayButtonFinder = find.byIcon(AbiliaIcons.returnToPreviousPage);
  bool applyCrossOver() =>
      (find.byType(CrossOver).evaluate().first.widget as CrossOver).applyCross;

  final twoTimepillarGeneric = Generic.createNew<MemoplannerSettingData>(
    data: MemoplannerSettingData.fromData(
        data: DayCalendarType.twoTimepillars.index,
        identifier: DayCalendarViewOptionsSettings.viewOptionsCalendarTypeKey),
  );

  setUpAll(() {
    tz.initializeTimeZones();
    setupPermissions();
    setupFakeTts();
  });

  setUp(() async {
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;

    mockTicker = StreamController<DateTime>();
    mockActivityDb = ActivityDbInMemory();

    final mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));
    when(() => mockGenericDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    final mockTimerDb = MockTimerDb();
    when(() => mockTimerDb.getAllTimers())
        .thenAnswer((_) => Future.value(timerResponse()));
    when(() => mockTimerDb.getRunningTimersFrom(any()))
        .thenAnswer((_) => Future.value(timerResponse()));

    genericResponse = () => [twoTimepillarGeneric];

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..genericDb = mockGenericDb
      ..timerDb = mockTimerDb
      ..sortableDb = FakeSortableDb()
      ..ticker = Ticker.fake(stream: mockTicker.stream, initialTime: time)
      ..fireBasePushService = FakeFirebasePushService()
      ..client = Fakes.client(
        genericResponse: genericResponse,
      )
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..database = FakeDatabase()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() {
    genericResponse = () => [];
    timerResponse = () => [];
    mockTicker.close();
    GetIt.I.reset();
  });

  testWidgets('Shows', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
  });

  testWidgets('Go to today button shows for next day but not when going back',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.byType(GoToTodayButton), findsNothing);
    await tester.tap(nextDayButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(GoToTodayButton), findsOneWidget);
    await tester.tap(previusDayButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byType(GoToTodayButton), findsNothing);
  });

  group('timepillar', () {
    testWidgets('timepillar shows', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsNWidgets(2));
    });

    testWidgets('tts', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      final hour = DateFormat('h').format(time);
      await tester.verifyTts(find.text(hour).at(0), contains: hour);
    });

    testWidgets('tts on 24 h two timepillar', (WidgetTester tester) async {
      addTearDown(
        tester.binding.platformDispatcher.clearAlwaysUse24HourTestValue,
      );
      tester.binding.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      final hour = DateFormat('H').format(time);
      await tester.verifyTts(find.text(hour), contains: hour);
    });
  });

  group('timepillar dots', () {
    testWidgets('Current and future dots shows', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(AnimatedDot), findsWidgets);
      expect(find.byType(CurrentDots), findsWidgets);
      expect(find.byType(FutureDots), findsNothing);
    });

    testWidgets('Yesterday shows only past dots', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(PastDots), findsWidgets);
      expect(find.byType(AnimatedDot), findsNothing);
      expect(find.byType(FutureDots), findsNothing);
    });

    testWidgets('Tomorrow shows only future dots', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(FutureDots), findsWidgets);
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(AnimatedDot), findsNothing);
    });

    testWidgets('Only one current dot', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == currentDotShape),
          hasLength(1));
    });

    testWidgets('Alwasy only one current dots', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      for (var i = 0; i < 20; i++) {
        mockTicker.add(time.add(i.minutes()));
        await tester.pumpAndSettle();
        expect(
            tester
                .widgetList<AnimatedDot>(find.byType(AnimatedDot))
                .where((d) => d.decoration == currentDotShape),
            hasLength(1));
      }
    });
  });

  group('Timeline', () {
    testWidgets('Exists', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsWidgets);
    });

    testWidgets('Dont Exists if settings say so', (WidgetTester tester) async {
      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: TimepillarSettings.settingDisplayTimelineKey,
              ),
            ),
          ];
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('hides timeline after push update',
        (WidgetTester tester) async {
      final pushCubit = PushCubit();

      await tester.pumpWidget(App(
        pushCubit: pushCubit,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsWidgets);

      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: TimepillarSettings.settingDisplayTimelineKey,
              ),
            ),
          ];
      pushCubit.fakePush();
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('Tomorrow does not show timeline', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('Yesterday does not show timline', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('timeline is at same y pos as current-time-dot',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      final currentDot = tester
          .widgetList<AnimatedDot>(find.byType(AnimatedDot))
          .firstWhere((d) => d.decoration == currentDotShape);

      final currentDotPosition = tester.getCenter(find.byWidget(currentDot));

      for (final element in find.byType(Timeline).evaluate()) {
        final box = element.renderObject as RenderBox?;
        if (box == null) throw AssertionError('box is null');
        final timeLinePosition =
            box.localToGlobal(box.size.center(Offset.zero));
        expect(timeLinePosition.dy, closeTo(currentDotPosition.dy, 0.0001));
      }
    });

    testWidgets('hourTimeline hidden by default', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNothing);
    });

    testWidgets('hourTimeline shows if setting is set',
        (WidgetTester tester) async {
      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: TimepillarSettings.settingDisplayHourLinesKey,
              ),
            ),
          ];
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNWidgets(2));
    });

    testWidgets('hourTimeline shows on push', (WidgetTester tester) async {
      final pushCubit = PushCubit();
      await tester.pumpWidget(App(pushCubit: pushCubit));
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNothing);

      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: TimepillarSettings.settingDisplayHourLinesKey,
              ),
            ),
          ];
      pushCubit.fakePush();
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNWidgets(2));
    });
  });

  group('categories', () {
    final leftFinder = find.byType(CategoryLeft),
        rightFinder = find.byType(CategoryRight);

    testWidgets('Categories Exists', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);
    });

    testWidgets('Categories dont Exists if settings say so',
        (WidgetTester tester) async {
      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: CategoriesSettings.calendarActivityTypeShowTypesKey,
              ),
            ),
          ];
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(CategoryLeft), findsNothing);
      expect(find.byType(CategoryRight), findsNothing);
    });

    testWidgets('memoplanner settings - show category push update ',
        (WidgetTester tester) async {
      final pushCubit = PushCubit();

      await tester.pumpWidget(App(
        pushCubit: pushCubit,
      ));
      await tester.pumpAndSettle();

      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);

      genericResponse = () => [
            twoTimepillarGeneric,
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
    });
    group('category colors', () {
      const rightCategoryActiveColor = AbiliaColors.green,
          rightCategoryInactiveColor = AbiliaColors.green40,
          leftCategoryActiveColor = AbiliaColors.black60,
          noCategoryColor = AbiliaColors.white140;

      void expectCorrectColor(
        WidgetTester tester,
        String title,
        Color expectedColor,
      ) {
        final boxDecoration = tester
            .widget<Container>(find.descendant(
                of: find.widgetWithText(ActivityTimepillarCard, title),
                matching: find.byType(Container)))
            .decoration as BoxDecoration?;
        expect(
          boxDecoration?.border?.top.color,
          expectedColor,
        );
        expect(
          boxDecoration?.border?.bottom.color,
          expectedColor,
        );
      }

      testWidgets('correct color - two timepillar',
          (WidgetTester tester) async {
        final soon = time.add(30.minutes());
        final just = time.subtract(30.minutes());

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
        mockActivityDb.initWithActivities([a1, a2, a3, a4]);

        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        expectCorrectColor(tester, a1.title, leftCategoryActiveColor);
        expectCorrectColor(tester, a2.title, rightCategoryActiveColor);
        expectCorrectColor(tester, a3.title, noCategoryColor);
        expectCorrectColor(tester, a4.title, rightCategoryInactiveColor);
      });

      testWidgets('correct no color', (WidgetTester tester) async {
        final soon = time.add(30.minutes());
        final just = time.subtract(30.minutes());

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
        mockActivityDb.initWithActivities([a1, a2, a3, a4]);
        genericResponse = () => [
              twoTimepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier:
                      CategoriesSettings.calendarActivityTypeShowColorKey,
                ),
              ),
            ];

        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();

        expectCorrectColor(tester, a1.title, noCategoryColor);
        expectCorrectColor(tester, a2.title, noCategoryColor);
        expectCorrectColor(tester, a3.title, noCategoryColor);
        expectCorrectColor(tester, a4.title, noCategoryColor);
      });
    });
  });

  group('Timers', () {
    find.byType(TimerTimepillarCard);

    final t1 = AbiliaTimer.createNew(
          title: '22 minutes',
          startTime: time,
          duration: 22.minutes(),
        ),
        t2 = AbiliaTimer.createNew(
          title: '22 minutes',
          fileId: 'fileid',
          startTime: time,
          duration: 22.minutes(),
        );
    setUp(() => timerResponse = () => [t1]);

    testWidgets('Shows timers title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(TimerTimepillarCard), findsOneWidget);
      expect(find.text(t1.title), findsOneWidget);
    });

    testWidgets('Shows timers with image', (WidgetTester tester) async {
      // Arrange
      timerResponse = () => [t2];

      await mockNetworkImages(() async {
        // Act
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        // Assert
        expect(find.byType(TimerTimepillarCard), findsOneWidget);
        expect(find.text(t2.title), findsNothing);
        expect(find.byType(EventImage), findsOneWidget);
      });
    });

    testWidgets('tts', (WidgetTester tester) async {
      // Arrange
      timerResponse = () => [t1, t2];
      await mockNetworkImages(() async {
        // Act
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        // Assert
        await tester.verifyTts(find.text(t1.title), contains: t1.title);
        await tester.verifyTts(find.byType(EventImage), contains: t2.title);
      });
    });

    testWidgets('timer at night', (WidgetTester tester) async {
      // Arrange
      final nightTime = DateTime(time.year, time.month, time.day + 1, 02, 00);
      final nightTimer = AbiliaTimer.createNew(
        title: 'timer in the middle of the night',
        startTime: nightTime,
        duration: 30.minutes(),
      );
      timerResponse = () => [nightTimer];

      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(TimerTimepillarCard), findsOneWidget);
      expect(find.text(nightTimer.title), findsOneWidget);
    });

    testWidgets('timer spanning into night', (WidgetTester tester) async {
      // Arrange
      final nightTimer = AbiliaTimer.createNew(
        title: 'timer in the middle of the night',
        startTime: DateTime(time.year, time.month, time.day, 23, 00),
        duration: 4.hours(),
      );
      timerResponse = () => [nightTimer];

      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(TimerTimepillarCard), findsOneWidget);
      expect(find.text(nightTimer.title), findsOneWidget);
    });

    testWidgets('starting night before', (WidgetTester tester) async {
      // Arrange
      final nightTimer = AbiliaTimer.createNew(
        title: 'timer in the middle of the night',
        startTime: DateTime(time.year, time.month, time.day, 04, 00),
        duration: 8.hours(),
      );
      timerResponse = () => [nightTimer];

      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(TimerTimepillarCard), findsOneWidget);
      expect(find.text(nightTimer.title), findsOneWidget);
    });
  });

  group('Activities', () {
    final leftActivityFinder = find.text(leftTitle);
    final rightActivityFinder = find.text(rightTitle);
    final cardFinder = find.byType(ActivityTimepillarCard);
    final atNightTime = time.add(12.hours());
    setUp(() {
      mockActivityDb.initWithActivities([
        Activity.createNew(
          startTime: atNightTime,
          duration: 1.hours(),
          alarmType: alarmSilent,
          title: rightTitle,
          checkable: true,
        ),
        Activity.createNew(
          startTime: atNightTime,
          duration: 1.hours(),
          alarmType: alarmSilent,
          title: leftTitle,
          category: Category.left,
        ),
      ]);
    });

    testWidgets('Shows activity', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(leftActivityFinder, findsOneWidget);
      expect(rightActivityFinder, findsOneWidget);
      expect(cardFinder, findsNWidgets(2));
    });

    testWidgets(
        'Shows activity starting close to beginning of night interval - BUG SGC-1789',
        (WidgetTester tester) async {
      // Arrange
      final startTime = time.copyWith(hour: 22, minute: 55);
      mockActivityDb.initWithActivities([
        Activity.createNew(
          startTime: startTime,
          duration: 1.hours(),
          alarmType: alarmSilent,
          title: rightTitle,
        ),
        Activity.createNew(
          startTime: startTime,
          duration: 1.hours(),
          alarmType: alarmSilent,
          title: leftTitle,
          category: Category.left,
        ),
      ]);
      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(leftActivityFinder, findsNWidgets(2));
      expect(rightActivityFinder, findsNWidgets(2));
      expect(cardFinder, findsNWidgets(4));
    });

    testWidgets('tts', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      await tester.verifyTts(leftActivityFinder, contains: leftTitle);
      await tester.verifyTts(rightActivityFinder, contains: rightTitle);
    });

    testWidgets('tapping activity shows activity info',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Act
      await tester.tap(leftActivityFinder);
      await tester.pumpAndSettle();
      // Assert
      expect(leftActivityFinder, findsOneWidget);
      expect(rightActivityFinder, findsNothing);
      expect(find.byType(ActivityPage), findsOneWidget);
    });

    testWidgets('changing activity shows in timepillar card',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Act
      await tester.tap(rightActivityFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.activityBackButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CheckMark), findsOneWidget);
    });

    testWidgets('setting no dots shows SideTime', (WidgetTester tester) async {
      // Arrange
      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier:
                      DayCalendarViewOptionsSettings.viewOptionsDotsKey),
            ),
          ];
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(SideTime), findsNWidgets(2));
    });

    testWidgets('current activity shows no CrossOver',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivities(
          [Activity.createNew(title: 'title', startTime: time)]);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(applyCrossOver(), false);
    });

    testWidgets('past activity shows CrossOver', (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivities([
        Activity.createNew(
            title: 'title', startTime: time.subtract(10.minutes()))
      ]);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(applyCrossOver(), true);
    });

    testWidgets('past activity with endtime shows CrossOver',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivities([
        Activity.createNew(
          title: 'title',
          startTime: time.subtract(9.hours()),
          duration: 8.hours(),
        )
      ]);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(applyCrossOver(), true);
    });

    testWidgets('signed off past activity shows CrossOver',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivities([
        Activity.createNew(
            title: 'title',
            startTime: time.subtract(40.minutes()),
            checkable: true,
            signedOffDates: [time].map(whaleDateFormat))
      ]);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(applyCrossOver(), true);
    });

    testWidgets('Recurring activity - on night will show up',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivities([
        Activity.createNew(
          title: 'title',
          startTime: time.onlyDays().add(2.hours()),
          recurs: Recurs.everyDay,
        ),
      ]);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('title'), findsOneWidget);
    });

    testWidgets('Recurring activity - last activity will show up',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivities([
        Activity.createNew(
          title: 'title',
          startTime: time.addDays(-5),
          recurs: Recurs.weeklyOnDays(const [1, 2, 3, 4, 5, 6, 7],
              ends: time.onlyDays()),
        ),
      ]);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('title'), findsOneWidget);
    });
  });

  group('Night', () {
    testWidgets('Only one timepillar at night', (WidgetTester tester) async {
      final night = DateTime(2022, 04, 26, 23, 30);
      mockTicker.add(night);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(TwoTimepillarCalendar), findsNothing);
      expect(find.byType(OneTimepillarCalendar), findsOneWidget);
    });

    testWidgets('Moving from day to night', (WidgetTester tester) async {
      final night = DateTime(2022, 04, 26, 22, 59);
      mockTicker.add(night);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
      mockTicker.add(night.add(1.minutes()));
      await tester.pumpAndSettle();
      expect(find.byType(TwoTimepillarCalendar), findsNothing);
      expect(find.byType(OneTimepillarCalendar), findsOneWidget);
    });

    testWidgets(
        'Navigating to next day when before midnight shows next day with two timepillars',
        (WidgetTester tester) async {
      final night = DateTime(2022, 04, 26, 23, 30);
      mockTicker.add(night);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
    });

    testWidgets(
        'Navigating to previous day when before midnight shows the current day with two timepillars',
        (WidgetTester tester) async {
      final night = DateTime(2022, 04, 26, 23, 30);
      mockTicker.add(night);
      const dayActivityTitle = 'Day activity';

      mockActivityDb.initWithActivities([
        Activity.createNew(
          title: dayActivityTitle,
          startTime: DateTime(2022, 04, 26, 13, 00),
          duration: 1.hours(),
        )
      ]);

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.text(dayActivityTitle), findsNothing);

      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
      expect(find.text(dayActivityTitle), findsOneWidget);

      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(TwoTimepillarCalendar), findsNothing);
    });

    testWidgets(
        'Navigating to previous day when after midnight shows previous day',
        (WidgetTester tester) async {
      final night = DateTime(2022, 04, 27, 01, 00);
      mockTicker.add(night);
      const previousDayTitle = 'prevday';

      mockActivityDb.initWithActivities([
        Activity.createNew(
          title: previousDayTitle,
          startTime: DateTime(2022, 04, 26, 13, 00),
          duration: 1.hours(),
        )
      ]);

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.text(previousDayTitle), findsNothing);
      expect(find.byType(TwoTimepillarCalendar), findsNothing);

      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
      expect(find.text(previousDayTitle), findsOneWidget);
    });

    testWidgets(
        'Navigating to next day when after midnight shows the full current day',
        (WidgetTester tester) async {
      final night = DateTime(2022, 04, 27, 01, 00);
      mockTicker.add(night);
      const dayActivityTitle = 'day activity';

      mockActivityDb.initWithActivities([
        Activity.createNew(
          title: dayActivityTitle,
          startTime: DateTime(2022, 04, 27, 13, 00),
          duration: 1.hours(),
        )
      ]);

      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.text(dayActivityTitle), findsNothing);
      expect(find.byType(TwoTimepillarCalendar), findsNothing);

      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
      expect(find.text(dayActivityTitle), findsOneWidget);
    });
  });

  group('Timepillar widths', () {
    testWidgets(
        'When night is longer than day, timepillars have the same width',
        (WidgetTester tester) async {
      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: 10 * Duration.millisecondsPerHour,
                identifier: DayParts.morningIntervalStartKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: 19 * Duration.millisecondsPerHour,
                identifier: DayParts.nightIntervalStartKey,
              ),
            ),
          ];
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      final oneTimepillars = find.ancestor(
          of: find.byType(OneTimepillarCalendar),
          matching: find.byType(Flexible));
      expect(oneTimepillars, findsNWidgets(2));
      final dayOnetimepillarWidth = tester.getSize(oneTimepillars.first).width;
      final nightOnetimepillarWidth = tester.getSize(oneTimepillars.last).width;
      expect(dayOnetimepillarWidth, nightOnetimepillarWidth);
    });

    testWidgets(
        'When day is longer than night, day timepillar is wider than night timepillar',
        (WidgetTester tester) async {
      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: 5 * Duration.millisecondsPerHour,
                identifier: DayParts.morningIntervalStartKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: 22 * Duration.millisecondsPerHour,
                identifier: DayParts.nightIntervalStartKey,
              ),
            ),
          ];
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      final oneTimepillars = find.ancestor(
          of: find.byType(OneTimepillarCalendar),
          matching: find.byType(Flexible));
      expect(oneTimepillars, findsNWidgets(2));
      final dayOnetimepillarWidth = tester.getSize(oneTimepillars.first).width;
      final nightOnetimepillarWidth = tester.getSize(oneTimepillars.last).width;
      expect(dayOnetimepillarWidth, greaterThan(nightOnetimepillarWidth));
    });
  });
}
