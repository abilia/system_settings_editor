import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:intl/intl.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_fakes/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/app_pumper.dart';
import '../../../../test_helpers/tts.dart';
import '../../../../fakes/activity_db_in_memory.dart';

void main() {
  late StreamController<DateTime> mockTicker;
  late ActivityDbInMemory mockActivityDb;
  final time = DateTime(2007, 08, 09, 13, 11);
  const leftTitle = 'LeftCategoryActivity',
      rightTitle = 'RightCategoryActivity';

  final timepillarGeneric = Generic.createNew<MemoplannerSettingData>(
    data: MemoplannerSettingData.fromData(
        data: DayCalendarType.oneTimepillar.index,
        identifier: DayCalendarViewOptionsSettings.viewOptionsCalendarTypeKey),
  );

  ActivityResponse activityResponse = () => [];
  GenericResponse genericResponse = () => [];
  TimerResponse timerResponse = () => [];

  final nextDayButtonFinder = find.byIcon(AbiliaIcons.goToNextPage);
  final previousDayButtonFinder = find.byIcon(AbiliaIcons.returnToPreviousPage);

  setUp(() async {
    setupPermissions();
    setupFakeTts();

    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;

    mockTicker = StreamController<DateTime>();
    mockActivityDb = ActivityDbInMemory();

    genericResponse = () => [timepillarGeneric];
    final mockGenericDb = MockGenericDb();
    registerFallbackValue(
      AbiliaTimer.createNew(startTime: time, duration: Duration.zero),
    );
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));
    when(() => mockGenericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.getLastRevision())
        .thenAnswer((_) => Future.value(11));
    when(() => mockGenericDb.insert(any())).thenAnswer((_) => Future.value());

    final mockTimerDb = MockTimerDb();
    when(() => mockTimerDb.getAllTimers())
        .thenAnswer((_) => Future.value(timerResponse()));
    when(() => mockTimerDb.delete(any())).thenAnswer((_) => Future.value(1));
    when(() => mockTimerDb.getRunningTimersFrom(any()))
        .thenAnswer((_) => Future.value(timerResponse()));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..genericDb = mockGenericDb
      ..timerDb = mockTimerDb
      ..sortableDb = FakeSortableDb()
      ..ticker = Ticker.fake(stream: mockTicker.stream, initialTime: time)
      ..fireBasePushService = FakeFirebasePushService()
      ..client = Fakes.client(
        activityResponse: activityResponse,
        genericResponse: () => genericResponse(),
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
    activityResponse = () => [];
    timerResponse = () => [];
    mockTicker.close();
    GetIt.I.reset();
  });

  testWidgets('Shows when selected', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.byType(TimepillarCalendar), findsOneWidget);
  });

  testWidgets('all days activity tts', (WidgetTester tester) async {
    final activity = Activity.createNew(
      title: 'fuyllday',
      startTime: time.onlyDays(),
      duration: 1.days() - 1.milliseconds(),
      fullDay: true,
    );
    mockActivityDb.initWithActivity(activity);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.byType(FullDayContainer), findsOneWidget);
    await tester.verifyTts(find.text(activity.title), contains: activity.title);
  });

  group('timepillar', () {
    testWidgets('timepillar shows', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });

    testWidgets('tts', (WidgetTester tester) async {
      await tester.pumpApp(use24: true);
      await tester.pumpAndSettle();
      final hour = DateFormat('H').format(time);
      await tester.verifyTts(find.text(hour).at(0), contains: hour);
    });

    testWidgets('tts on 24 h', (WidgetTester tester) async {
      addTearDown(
        tester.binding.platformDispatcher.clearAlwaysUse24HourTestValue,
      );
      tester.binding.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      final hour = DateFormat('H').format(time);
      await tester.verifyTts(find.text(hour), contains: hour);
    });

    testWidgets('Shows timepillar when scrolled in x',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      await tester.flingFrom(const Offset(200, 200), const Offset(200, 0), 200);
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });
    testWidgets('Shows timepillar when scrolled in y',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      await tester.flingFrom(const Offset(200, 200), const Offset(0, 200), 200);
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });

    testWidgets('Shows go to now button when scrolling',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
      await tester.flingFrom(const Offset(200, 200), const Offset(0, 200), 200);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsOneWidget);
    });

    testWidgets('BUG SGC-1427 GoToNowButton should not expand in width',
        (WidgetTester tester) async {
      final screenWidth = tester.binding.window.physicalSize.width /
          tester.binding.window.devicePixelRatio;
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.flingFrom(const Offset(200, 200), const Offset(0, 200), 200);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsOneWidget);

      final nowButton = find.byKey(TestKey.goToNowButton).evaluate().first;
      //Doesn't actually test that the width is exactly correct,
      //just that it won't expand to fill as much space as it can.
      expect(nowButton.size!.width, lessThan(screenWidth));
    });

    testWidgets('SGC-967 go to now button works more than once',
        (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
      await tester.flingFrom(const Offset(200, 200), const Offset(0, 200), 200);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsOneWidget);
      await tester.tap(find.byKey(TestKey.goToNowButton));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
      await tester.flingFrom(const Offset(200, 200), const Offset(0, 200), 200);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsOneWidget);
    });

    testWidgets(
        'SGC-1638 Full day activity should not be present in timepillar',
        (WidgetTester tester) async {
      mockActivityDb.initWithActivity(Activity.createNew(
        title: 'title',
        startTime: time,
        fullDay: true,
      ));
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsNothing);
    });
  });

  group('timepillar dots', () {
    testWidgets('Current dots shows', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(AnimatedDot), findsWidgets);
      expect(find.byType(FutureDots), findsNothing);
    });
    testWidgets('Yesterday shows only past dots', (WidgetTester tester) async {
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(previousDayButtonFinder);
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
            timepillarGeneric,
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
            timepillarGeneric,
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
      await tester.tap(previousDayButtonFinder);
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
        final box = element.renderObject as RenderBox;
        final timeLinePostion = box.localToGlobal(box.size.center(Offset.zero));
        expect(timeLinePostion.dy, closeTo(currentDotPosition.dy, 0.0001));
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
            timepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: TimepillarSettings.settingDisplayHourLinesKey,
              ),
            ),
          ];
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsOneWidget);
    });

    testWidgets('hourTimeline shows on push', (WidgetTester tester) async {
      final pushCubit = PushCubit();
      await tester.pumpWidget(App(pushCubit: pushCubit));
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNothing);

      genericResponse = () => [
            timepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: TimepillarSettings.settingDisplayHourLinesKey,
              ),
            ),
          ];
      pushCubit.fakePush();
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsOneWidget);
    });

    testWidgets(
      'Scrolling follows now - timeline stays in place',
      (WidgetTester tester) async {
        // Arrange
        genericResponse = () => [
              timepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: TimepillarIntervalType.dayAndNight.index,
                  identifier:
                      DayCalendarViewOptionsSettings.viewOptionsTimeIntervalKey,
                ),
              ),
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: TimepillarZoom.large.index,
                  identifier: DayCalendarViewOptionsSettings
                      .viewOptionsTimepillarZoomKey,
                ),
              ),
            ];

        double timeLinePosY() =>
            tester.getTopLeft(find.byType(Timeline).first).dy;

        double timeTextPosY() => tester
            .getTopLeft(
              find.descendant(
                of: find.byType(TimePillar),
                matching: find.text('3').first,
              ),
            )
            .dy;

        final testTime = time.copyWith(hour: 14, minute: 0);

        // Act
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        mockTicker.add(testTime);
        await tester.pumpAndSettle();
        final firstTimelinePositionY = timeLinePosY();
        final firstTimeTextPositionY = timeTextPosY();
        mockTicker.add(testTime.add(const Duration(minutes: 45)));
        await tester.pumpAndSettle();
        final secondTimelinePositionY = timeLinePosY();
        final secondTimeTextPositionY = timeTextPosY();

        // Assert
        expect(secondTimelinePositionY, firstTimelinePositionY);
        expect(secondTimeTextPositionY, isNot(firstTimeTextPositionY));
      },
      skip: !Config.isMP,
    );
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
            timepillarGeneric,
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

    testWidgets(' memoplanner settings - show category push update ',
        (WidgetTester tester) async {
      final pushCubit = PushCubit();

      await tester.pumpWidget(App(
        pushCubit: pushCubit,
      ));
      await tester.pumpAndSettle();

      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);

      genericResponse = () => [
            timepillarGeneric,
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
      void expectCorrectColor(
          WidgetTester tester, String title, Color expectedColor) {
        final boxDecoration = tester
            .widget<Container>(find.descendant(
                of: find.widgetWithText(ActivityTimepillarCard, title),
                matching: find.byType(Container)))
            .decoration as BoxDecoration;
        expect(
          boxDecoration.border?.bottom.color,
          expectedColor,
        );
      }

      group('day', () {
        const rightCategoryActiveColor = AbiliaColors.green,
            rightCategoryInactiveColor = AbiliaColors.green40,
            leftCategoryActiveColor = AbiliaColors.black60,
            noCategoryColor = AbiliaColors.white140;
        testWidgets('correct color', (WidgetTester tester) async {
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
                timepillarGeneric,
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
      group('night', () {
        final nightTime = time.copyWith(hour: 03);
        const rightCategoryActiveNightColor = AbiliaColors.green120,
            rightCategoryInactiveNightColor = AbiliaColors.green180,
            leftCategoryActiveNightColor = AbiliaColors.black60,
            leftCategoryInactiveNightColor = AbiliaColors.black75,
            noCategoryNightColor = AbiliaColors.black75;

        testWidgets('correct night color', (WidgetTester tester) async {
          // Arrange
          mockTicker.add(nightTime);
          final soon = nightTime.add(30.minutes());
          final just = nightTime.subtract(30.minutes());

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

          expectCorrectColor(tester, a1.title, leftCategoryActiveNightColor);
          expectCorrectColor(tester, a2.title, rightCategoryActiveNightColor);
          expectCorrectColor(tester, a3.title, leftCategoryInactiveNightColor);
          expectCorrectColor(tester, a4.title, rightCategoryInactiveNightColor);
        });

        testWidgets('correct no color', (WidgetTester tester) async {
          // Arrange
          mockTicker.add(nightTime);
          final soon = nightTime.add(30.minutes());
          final just = nightTime.subtract(30.minutes());

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
                timepillarGeneric,
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

          expectCorrectColor(tester, a1.title, noCategoryNightColor);
          expectCorrectColor(tester, a2.title, noCategoryNightColor);
          expectCorrectColor(tester, a3.title, noCategoryNightColor);
          expectCorrectColor(tester, a4.title, noCategoryNightColor);
        });
      });
    });
  });

  group('Activities', () {
    bool applyCrossOver() =>
        (find.byType(CrossOver).evaluate().first.widget as CrossOver)
            .applyCross;

    final leftActivityFinder = find.text(leftTitle);
    final rightActivityFinder = find.text(rightTitle);
    final cardFinder = find.byType(ActivityTimepillarCard);
    setUp(() {
      mockActivityDb.initWithActivities([
        FakeActivity.starts(
          time,
          title: rightTitle,
        ).copyWith(
          checkable: true,
        ),
        FakeActivity.starts(
          time,
          title: leftTitle,
        ).copyWith(
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

    testWidgets('Shows activity when categories are disabled - BUG SGC-1808',
        (WidgetTester tester) async {
      // Arrange
      genericResponse = () => [
            timepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: CategoriesSettings.calendarActivityTypeShowTypesKey,
              ),
            ),
          ];

      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(leftActivityFinder, findsOneWidget);
      expect(rightActivityFinder, findsOneWidget);
      expect(cardFinder, findsNWidgets(2));
    });

    testWidgets('tts', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      await tester.verifyTts(leftActivityFinder, contains: leftTitle);
      await tester.verifyTts(rightActivityFinder, contains: rightTitle);
    });

    testWidgets('Activities is right or left of timeline',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();

      // Act
      final timelineXPostion = tester.getCenter(find.byType(Timeline).first).dx;
      final leftActivityXPostion = tester.getCenter(leftActivityFinder).dx;
      final rightActivityXPostion = tester.getCenter(rightActivityFinder).dx;

      // Assert
      expect(leftActivityXPostion, lessThan(timelineXPostion));
      expect(rightActivityXPostion, greaterThan(timelineXPostion));
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
            timepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier:
                      DayCalendarViewOptionsSettings.viewOptionsDotsKey),
            ),
          ];
      await tester.pumpWidget(const App());
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
      // Assert
      expect(applyCrossOver(), true);
    });

    testWidgets('past activity with endtime shows CrossOver - long activity',
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
      // Assert
      expect(applyCrossOver(), true);
    });

    testWidgets('past activity with endtime shows CrossOver - short activity',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivities([
        Activity.createNew(
          title: 'title',
          startTime: time.subtract(2.hours()),
          duration: 1.hours(),
        )
      ]);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      // Assert
      expect(applyCrossOver(), true);
    });

    testWidgets('SGC-735 past activity with long title shows CrossOver',
        (WidgetTester tester) async {
      // Arrange
      mockActivityDb.initWithActivities([
        Activity.createNew(
          title: 'title title title title title title title '
              'title title title title title title title title '
              'title title title title title title title title ',
          startTime: time.subtract(2.hours()),
        )
      ]);
      await tester.pumpWidget(const App());
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

    group('Timers', () {
      Finder timerFinder(AbiliaTimer timer) => find.byType(TimerTimepillarCard);

      final t1 = AbiliaTimer.createNew(
            title: '22 minutes',
            startTime: time,
            duration: 22.minutes(),
          ),
          currentTimerWithImage = AbiliaTimer.createNew(
            title: '1 min ago',
            fileId: 'fileId',
            startTime: time.subtract(1.minutes()),
            duration: 10.minutes(),
          ),
          pastTimerWithImage = AbiliaTimer.createNew(
            title: '10 min ago',
            fileId: 'fileId',
            startTime: time.subtract(20.minutes()),
            duration: 10.minutes(),
          );

      setUp(() => timerResponse = () => [t1]);

      testWidgets('Shows timers right of timeline',
          (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        final timelineXPostion =
            tester.getCenter(find.byType(Timeline).first).dx;
        final poistion = tester.getCenter(timerFinder(t1)).dx;

        // Assert
        expect(timerFinder(t1), findsOneWidget);
        expect(poistion, greaterThan(timelineXPostion));
      });

      testWidgets('tts', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        // Assert
        await tester.verifyTts(timerFinder(t1), contains: t1.title);
      });

      testWidgets('tapping timer shows timer info',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        // Act
        await tester.tap(timerFinder(t1));
        await tester.pumpAndSettle();
        // Assert
        expect(find.byType(TimerPage), findsOneWidget);
        expect(find.byType(TimerWheel), findsOneWidget);
        expect(find.text(t1.title), findsOneWidget);
      });

      testWidgets('deleting timer does not shows in timepillar ',
          (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        // Act
        await tester.tap(timerFinder(t1));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.deleteAllClear));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(YesButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(TimerPage), findsNothing);
        expect(timerFinder(t1), findsNothing);
      });

      testWidgets('current timer with image shows no CrossOver',
          (WidgetTester tester) async {
        await mockNetworkImages(() async {
          // Arrange
          timerResponse = () => [currentTimerWithImage];
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          // Assert
          expect(find.byType(EventImage), findsWidgets);
          expect(applyCrossOver(), false);
        });
      });

      testWidgets('past timer with image shows CrossOver and no title',
          (WidgetTester tester) async {
        await mockNetworkImages(() async {
          // Arrange
          timerResponse = () => [pastTimerWithImage];
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          // Assert
          expect(find.byType(EventImage), findsWidgets);
          expect(applyCrossOver(), true);
          expect(find.text(pastTimerWithImage.title), findsNothing);
        });
      });

      testWidgets('past timer with long title', (WidgetTester tester) async {
        // Arrange
        final pastTimerLongTitle = AbiliaTimer.createNew(
          title: 'title title title title title title title '
              'title title title title title title title title '
              'title title title title title title title title ',
          startTime: time.subtract(2.hours()).subtract(30.minutes()),
          duration: 2.hours(),
        );
        timerResponse = () => [pastTimerLongTitle];
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        // Assert

        expect(timerFinder(pastTimerLongTitle), findsWidgets);
        expect(find.text(pastTimerLongTitle.title), findsWidgets);
      });
    });
  });

  group('Timepillar intervals', () {
    setUp(() {
      genericResponse = () => [
            timepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: TimepillarIntervalType.interval.index,
                identifier:
                    DayCalendarViewOptionsSettings.viewOptionsTimeIntervalKey,
              ),
            ),
          ];
    });
    group('Activities', () {
      testWidgets('Activity outside interval is not visible',
          (WidgetTester tester) async {
        mockActivityDb.initWithActivities([
          Activity.createNew(
            title: 'title',
            startTime: time.copyWith(hour: 8, minute: 0),
          )
        ]);
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsNothing);
      });

      testWidgets('Activity inside interval is visible',
          (WidgetTester tester) async {
        mockActivityDb.initWithActivities([
          Activity.createNew(
            title: 'title',
            startTime: time,
          )
        ]);
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsOneWidget);
      });

      testWidgets('Activity spanning two intervals',
          (WidgetTester tester) async {
        final activityTime = DateTime(2020, 12, 01, 01, 00);
        mockActivityDb.initWithActivities([
          Activity.createNew(
            title: 'title',
            startTime: activityTime,
            duration: 6.hours(),
          )
        ]);

        mockTicker.add(
            activityTime); // Shows night interval. Activity should be visible here.
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsOneWidget);

        mockTicker.add(DateTime(2020, 12, 01, 08,
            01)); // Morning starts at 6. Activity should be visible here.
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsOneWidget);

        mockTicker.add(DateTime(2020, 12, 01, 10,
            00)); // Forenoon interval starts at 10. Acitivity should not be visible here
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsNothing);
      });

      testWidgets('Activity without duration starts on interval',
          (WidgetTester tester) async {
        final activityStartTime = DateTime(2020, 12, 01, 10, 00);
        mockActivityDb.initWithActivities([
          Activity.createNew(
            title: 'title',
            startTime: activityStartTime,
            alarmType: noAlarm,
          )
        ]);

        mockTicker.add(DateTime(2020, 12, 01, 01, 01));
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsNothing);

        mockTicker.add(DateTime(2020, 12, 01, 09, 00));
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsNothing);

        mockTicker.add(DateTime(2020, 12, 01, 10, 00));
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsOneWidget);
      });

      testWidgets(
          'SGC-1891 - Activity that spans over two days only shows one card',
          (WidgetTester tester) async {
        final startTime = DateTime(2020, 12, 01, 10, 00);
        genericResponse = () => [
              timepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: TimepillarIntervalType.dayAndNight.index,
                  identifier:
                      DayCalendarViewOptionsSettings.viewOptionsTimeIntervalKey,
                ),
              ),
            ];
        mockActivityDb.initWithActivities([
          Activity.createNew(
            title: 'title',
            startTime: startTime,
            duration: 23.hours(),
            alarmType: noAlarm,
          )
        ]);

        mockTicker.add(startTime);
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsNWidgets(1));

        mockTicker.add(startTime.add(1.days()));
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsNWidgets(1));
      });

      testWidgets('Activity is shown when interval is whole day',
          (WidgetTester tester) async {
        final activityStartTime = DateTime(2020, 12, 01, 10, 00);
        mockActivityDb.initWithActivities([
          Activity.createNew(
            title: 'title',
            startTime: activityStartTime,
          )
        ]);

        genericResponse = () => [
              timepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: TimepillarIntervalType.dayAndNight.index,
                  identifier:
                      DayCalendarViewOptionsSettings.viewOptionsTimeIntervalKey,
                ),
              ),
            ];

        mockTicker.add(DateTime(2020, 12, 01, 01, 01));
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsOneWidget);
      });

      testWidgets(
          'Day activity is only shown in day interval when interval is DAY',
          (WidgetTester tester) async {
        final activityStartTime = DateTime(2020, 12, 01, 10, 00);
        mockActivityDb.initWithActivities([
          Activity.createNew(
            title: 'title',
            startTime: activityStartTime,
            alarmType: noAlarm,
          )
        ]);

        genericResponse = () => [
              timepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: TimepillarIntervalType.day.index,
                  identifier:
                      DayCalendarViewOptionsSettings.viewOptionsTimeIntervalKey,
                ),
              ),
            ];

        mockTicker.add(DateTime(2020, 12, 01, 01, 00));
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsNothing);

        mockTicker.add(DateTime(2020, 12, 01, 07, 01));
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsOneWidget);

        mockTicker.add(DateTime(2020, 12, 01, 23, 30));
        await tester.pumpAndSettle();
        expect(find.byType(ActivityTimepillarCard), findsNothing);
      });
    });

    group('Timers', () {
      testWidgets('Timers outside interval is not visible',
          (WidgetTester tester) async {
        timerResponse = () => [
              AbiliaTimer.createNew(
                title: 'title',
                startTime: time.copyWith(hour: 8, minute: 0),
                duration: 10.minutes(),
              )
            ];
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsNothing);
      });

      testWidgets('Timer inside interval is visible',
          (WidgetTester tester) async {
        timerResponse = () => [
              AbiliaTimer.createNew(
                title: 'title',
                startTime: time,
                duration: 10.minutes(),
              )
            ];
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsOneWidget);
      });

      testWidgets('timer spanning two intervals', (WidgetTester tester) async {
        final timerTime = DateTime(2020, 12, 01, 01, 00);
        timerResponse = () => [
              AbiliaTimer.createNew(
                title: 'title',
                startTime: timerTime,
                duration: 6.hours(),
              )
            ];

        // Shows night interval. Activity should be visible here.
        mockTicker.add(timerTime);
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsOneWidget);

        // Morning starts at 6. Activity should be visible here.
        mockTicker.add(DateTime(2020, 12, 01, 08, 01));
        await tester.pumpAndSettle();
        // The timer alarm page should have been triggered here so first close that
        expect(find.byType(TimerAlarmPage), findsOneWidget);
        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsOneWidget);

        // Forenoon interval starts at 10. Acitivity should not be visible here
        mockTicker.add(DateTime(2020, 12, 01, 10, 00));
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsNothing);
      });

      testWidgets('Timer is shown when interval is whole day',
          (WidgetTester tester) async {
        final timerStartTime = DateTime(2020, 12, 01, 10, 00);
        timerResponse = () => [
              AbiliaTimer.createNew(
                title: 'title',
                startTime: timerStartTime,
                duration: 5.minutes(),
              )
            ];

        genericResponse = () => [
              timepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: TimepillarIntervalType.dayAndNight.index,
                  identifier:
                      DayCalendarViewOptionsSettings.viewOptionsTimeIntervalKey,
                ),
              ),
            ];

        mockTicker.add(DateTime(2020, 12, 01, 01, 01));
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsOneWidget);
      });

      testWidgets(
          'Day timer is only shown in day interval when interval is DAY',
          (WidgetTester tester) async {
        final timerStartTime = DateTime(2020, 12, 01, 10, 00);
        timerResponse = () => [
              AbiliaTimer.createNew(
                title: 'title',
                startTime: timerStartTime,
                duration: 4.minutes(),
              )
            ];

        genericResponse = () => [
              timepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: TimepillarIntervalType.day.index,
                  identifier:
                      DayCalendarViewOptionsSettings.viewOptionsTimeIntervalKey,
                ),
              ),
            ];

        mockTicker.add(DateTime(2020, 12, 01, 01, 00));
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsNothing);

        mockTicker.add(DateTime(2020, 12, 01, 07, 01));
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsOneWidget);

        mockTicker.add(DateTime(2020, 12, 01, 23, 30));
        await tester.pumpAndSettle();
        expect(find.byType(TimerTimepillarCard), findsNothing);
      });
    });
  });

  group('Night', () {
    testWidgets('Night interval shows whole night',
        (WidgetTester tester) async {
      const nightActivityTitle = 'nighttitle';
      mockActivityDb.initWithActivities([
        Activity.createNew(
          startTime: DateTime(2022, 04, 27, 02, 00),
          title: nightActivityTitle,
        )
      ]);
      mockTicker.add(DateTime(2022, 04, 26, 23, 30));
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.text(nightActivityTitle), findsOneWidget);
    });

    testWidgets('Navigate next shows full next day',
        (WidgetTester tester) async {
      const nightActivityTitle = 'nighttitle';
      const eveningTitle = 'eveningtitle';
      mockActivityDb.initWithActivities([
        Activity.createNew(
          startTime: DateTime(2022, 04, 27, 02, 00),
          title: nightActivityTitle,
        ),
        Activity.createNew(
          startTime: DateTime(2022, 04, 27, 23, 30),
          title: eveningTitle,
        )
      ]);
      mockTicker.add(DateTime(2022, 04, 26, 23, 30));
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.text(nightActivityTitle), findsOneWidget);
      expect(find.text(eveningTitle), findsNothing);

      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text(eveningTitle), findsOneWidget);
    });

    testWidgets('Navigate previous when before midnight shows full current day',
        (WidgetTester tester) async {
      const dayActivity = 'nighttitle';
      mockActivityDb.initWithActivities([
        Activity.createNew(
          startTime: DateTime(2022, 04, 26, 13, 00),
          title: dayActivity,
        ),
      ]);
      mockTicker.add(DateTime(2022, 04, 26, 23, 30));
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.text(dayActivity), findsNothing);

      await tester.tap(previousDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text(dayActivity), findsOneWidget);
    });

    testWidgets('Night view: background is dark', (WidgetTester tester) async {
      mockTicker.add(DateTime(2022, 04, 27, 00, 30));
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      final background =
          tester.firstWidget(find.byKey(TestKey.calendarBackgroundColor))
              as Container;
      expect(background.color, TimepillarCalendar.nightBackgroundColor);
    });

    testWidgets('SGC-1632 Night view: Header should be dark',
        (WidgetTester tester) async {
      mockTicker.add(DateTime(2022, 04, 27, 00, 30));
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      final appBar =
          tester.firstWidget(find.byType(CalendarAppBar)) as CalendarAppBar;
      expect(appBar.calendarDayColor, DayColor.noColors);
    });

    testWidgets(
        'SGC-1633 Night view: Wrong day in header when navigating to rest of day',
        (WidgetTester tester) async {
      mockTicker.add(DateTime(2022, 04, 27, 00, 30));
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.text('night'), findsOneWidget);
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text('night'), findsNothing);
    });

    testWidgets(
        'SGC-2014 GoToNowButton should always go to the night calendar if it is night',
        (WidgetTester tester) async {
      mockTicker.add(DateTime(2022, 04, 26, 23, 30));
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(previousDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.flingFrom(
          const Offset(200, 200), const Offset(200, 400), 200);
      await tester.pumpAndSettle();

      var tp = tester
          .firstWidget<TimepillarCalendar>(find.byType(TimepillarCalendar));
      expect(tp.timepillarState.showNightCalendar, false);

      await tester.tap(find.byKey(TestKey.goToNowButton));
      await tester.pumpAndSettle();

      tp = tester
          .firstWidget<TimepillarCalendar>(find.byType(TimepillarCalendar));
      expect(tp.timepillarState.showNightCalendar, true);

      mockTicker.add(DateTime(2022, 04, 27, 01, 30));
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.flingFrom(
          const Offset(400, 200), const Offset(400, 400), 200);
      await tester.pumpAndSettle();

      tp = tester
          .firstWidget<TimepillarCalendar>(find.byType(TimepillarCalendar));
      expect(tp.timepillarState.showNightCalendar, false);

      await tester.tap(find.byKey(TestKey.goToNowButton));
      await tester.pumpAndSettle();

      tp = tester
          .firstWidget<TimepillarCalendar>(find.byType(TimepillarCalendar));
      expect(tp.timepillarState.showNightCalendar, true);
    });

    testWidgets(
        'SGC-2160 - Navigate to previous then to week and back to current day will show night',
        (WidgetTester tester) async {
      const dayActivity = 'dayActivity';
      const nightActivity = 'nightActivity';
      mockActivityDb.initWithActivities([
        Activity.createNew(
          startTime: DateTime(2022, 04, 26, 13, 00),
          title: dayActivity,
        ),
        Activity.createNew(
          startTime: DateTime(2022, 04, 27, 03, 00),
          title: nightActivity,
        ),
      ]);
      final currentTime = DateTime(2022, 04, 26, 23, 30);
      mockTicker.add(currentTime);
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      expect(find.text(dayActivity), findsNothing);
      expect(find.text(nightActivity), findsOneWidget);

      await tester.tap(previousDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.text(dayActivity), findsOneWidget);
      expect(find.text(nightActivity), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      expect(find.byType(WeekCalendar), findsOneWidget);
      final currentDayHeading =
          '${currentTime.day}\n${const Translator(Locale('en')).translate.shortWeekday(currentTime.weekday)}';
      await tester.tap(find.textContaining(currentDayHeading));
      await tester.pumpAndSettle();

      expect(find.byType(OneTimepillarCalendar), findsOneWidget);
      expect(find.text(dayActivity), findsNothing);
      expect(find.text(nightActivity), findsOneWidget);
    });
  });
}
