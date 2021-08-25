// @dart=2.9

import 'dart:async';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/intl.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../mocks.dart';

void main() {
  MockActivityDb mockActivityDb;
  StreamController<DateTime> mockTicker;
  final time = DateTime(2007, 08, 09, 13, 11);
  final leftTitle = 'LeftCategoryActivity',
      rightTitle = 'RigthCategoryActivity';

  ActivityResponse activityResponse = () => [];
  GenericResponse genericResponse = () => [];

  final nextDayButtonFinder = find.byIcon(AbiliaIcons.go_to_next_page);
  final previusDayButtonFinder =
      find.byIcon(AbiliaIcons.return_to_previous_page);

  final timepillarGeneric = Generic.createNew<MemoplannerSettingData>(
    data: MemoplannerSettingData.fromData(
        data: DayCalendarType.timepillar.index,
        identifier: MemoplannerSettings.viewOptionsTimeViewKey),
  );

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    mockTicker = StreamController<DateTime>();
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activityResponse()));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    final mockGenericDb = MockGenericDb();
    when(mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));

    final mockUserFileDb = MockUserFileDb();
    when(
      mockUserFileDb.getMissingFiles(limit: anyNamed('limit')),
    ).thenAnswer(
      (value) => Future.value([]),
    );

    genericResponse = () => [
          timepillarGeneric,
        ];

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..genericDb = mockGenericDb
      ..sortableDb = MockSortableDb()
      ..ticker = Ticker(stream: mockTicker.stream, initialTime: time)
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client(
        activityResponse: activityResponse,
        genericResponse: genericResponse,
      )
      ..fileStorage = MockFileStorage()
      ..userFileDb = mockUserFileDb
      ..syncDelay = SyncDelays.zero
      ..database = MockDatabase()
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  tearDown(() async {
    activityResponse = () => [];
    genericResponse = () => [];
    await GetIt.I.reset();
  });

  testWidgets('Shows when selected', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(TimepillarCalendar), findsOneWidget);
  });

  testWidgets('all days activity tts', (WidgetTester tester) async {
    final activity = Activity.createNew(
        title: 'fuyllday',
        startTime: time.onlyDays(),
        duration: 1.days() - 1.milliseconds(),
        fullDay: true,
        reminderBefore: [60 * 60 * 1000],
        alarmType: NO_ALARM);
    activityResponse = () => [activity];
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(FullDayContainer), findsOneWidget);
    await tester.verifyTts(find.byType(FullDayContainer),
        contains: activity.title);
  });

  group('timepillar', () {
    setUp(() {
      genericResponse = () => [
            timepillarGeneric,
          ];
    });

    testWidgets('timepillar shows', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });

    testWidgets('tts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final hour = DateFormat('h').format(time);
      await tester.verifyTts(find.text(hour).at(0), contains: hour);
    });

    testWidgets('tts on 24 h', (WidgetTester tester) async {
      tester.binding.window.alwaysUse24HourFormatTestValue = true;
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final hour = DateFormat('H').format(time);
      await tester.verifyTts(find.text(hour), contains: hour);
    });

    testWidgets('Shows timepillar when scrolled in x',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await tester.flingFrom(Offset(200, 200), Offset(200, 0), 200);
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });
    testWidgets('Shows timepillar when scrolled in y',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await tester.flingFrom(Offset(200, 200), Offset(0, 200), 200);
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsOneWidget);
    });

    testWidgets('Shows go to now button when scrolling',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
      await tester.flingFrom(Offset(200, 200), Offset(0, 200), 200);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsOneWidget);
    });
  });

  group('timepillar dots', () {
    setUp(() {
      genericResponse = () => [
            timepillarGeneric,
          ];
    });
    testWidgets('Current dots shows', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(AnimatedDot), findsWidgets);
      expect(find.byType(FutureDots), findsNothing);
    });
    testWidgets('Yesterday shows only past dots', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(PastDots), findsWidgets);
      expect(find.byType(AnimatedDot), findsNothing);
      expect(find.byType(FutureDots), findsNothing);
    });
    testWidgets('Tomorrow shows only future dots', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(FutureDots), findsWidgets);
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(AnimatedDot), findsNothing);
    });

    testWidgets('Only one current dot', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == currentDotShape),
          hasLength(1));
    });

    testWidgets('Alwasy only one current dots', (WidgetTester tester) async {
      await tester.pumpWidget(App());
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
    setUp(() {
      genericResponse = () => [
            timepillarGeneric,
          ];
    });
    testWidgets('Exists', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsWidgets);
    });

    testWidgets('Dont Exists if settings say so', (WidgetTester tester) async {
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: MemoplannerSettings.settingDisplayTimelineKey,
              ),
            ),
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('hides timeline after push update',
        (WidgetTester tester) async {
      final pushBloc = PushBloc();

      await tester.pumpWidget(App(
        pushBloc: pushBloc,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsWidgets);

      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: MemoplannerSettings.settingDisplayTimelineKey,
              ),
            ),
            timepillarGeneric,
          ];
      pushBloc.add(PushEvent('collapse_key'));
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('Tomorrow does not show timeline', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('Yesterday does not show timline', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(previusDayButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('timeline is at same y pos as current-time-dot',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
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
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNothing);
    });

    testWidgets('hourTimeline shows if setting is set',
        (WidgetTester tester) async {
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: MemoplannerSettings.settingDisplayHourLinesKey,
              ),
            ),
            timepillarGeneric,
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsOneWidget);
    });

    testWidgets('hourTimeline shows on push', (WidgetTester tester) async {
      final pushBloc = PushBloc();
      await tester.pumpWidget(App(
        pushBloc: pushBloc,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNothing);

      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: MemoplannerSettings.settingDisplayHourLinesKey,
              ),
            ),
            timepillarGeneric,
          ];
      pushBloc.add(PushEvent('collapse_key'));
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsOneWidget);
    });
  });

  group('categories', () {
    final leftFinder = find.byType(CategoryLeft),
        rightFinder = find.byType(CategoryRight);

    testWidgets('Categories Exists', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);
    });

    testWidgets('Categories dont Exists if settings say so',
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

    testWidgets(' memoplanner settings - show category push update ',
        (WidgetTester tester) async {
      final pushBloc = PushBloc();

      await tester.pumpWidget(App(
        pushBloc: pushBloc,
      ));
      await tester.pumpAndSettle();

      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);

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
    });
  });

  group('Activities', () {
    final leftActivityFinder = find.text(leftTitle);
    final rightActivityFinder = find.text(rightTitle);
    final cardFinder = find.byType(ActivityTimepillarCard);
    setUp(() {
      activityResponse = () => [
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
          ];

      genericResponse = () => [
            timepillarGeneric,
          ];
    });

    testWidgets('Shows activity', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Assert
      expect(leftActivityFinder, findsOneWidget);
      expect(rightActivityFinder, findsOneWidget);
      expect(cardFinder, findsNWidgets(2));
    });

    testWidgets('tts', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Assert
      await tester.verifyTts(leftActivityFinder, contains: leftTitle);
      await tester.verifyTts(rightActivityFinder, contains: rightTitle);
    });

    testWidgets('Activities is right or left of timeline',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
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
      await tester.pumpWidget(App());
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
      await tester.pumpWidget(App());
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
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier: MemoplannerSettings.dotsInTimepillarKey),
            ),
            timepillarGeneric,
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(SideTime), findsNWidgets(2));
    });

    testWidgets('current activity shows no CrossOver',
        (WidgetTester tester) async {
      // Arrange
      activityResponse =
          () => [Activity.createNew(title: 'title', startTime: time)];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(CrossOver), findsNothing);
    });

    testWidgets('past activity shows CrossOver', (WidgetTester tester) async {
      // Arrange
      activityResponse = () => [
            Activity.createNew(
                title: 'title', startTime: time.subtract(10.minutes()))
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(CrossOver), findsWidgets);
    });

    testWidgets('past activity with endtime shows CrossOver',
        (WidgetTester tester) async {
      // Arrange
      activityResponse = () => [
            Activity.createNew(
              title: 'title',
              startTime: time.subtract(9.hours()),
              duration: 8.hours(),
            )
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(CrossOver), findsWidgets);
    });

    testWidgets('past activity with endtime shows CrossOver',
        (WidgetTester tester) async {
      // Arrange
      activityResponse = () => [
            Activity.createNew(
              title: 'title',
              startTime: time.subtract(2.hours()),
              duration: 1.hours(),
            )
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(CrossOver), findsWidgets);
    });

    testWidgets('signed off past activity shows no CrossOver',
        (WidgetTester tester) async {
      // Arrange
      activityResponse = () => [
            Activity.createNew(
                title: 'title',
                startTime: time.subtract(40.minutes()),
                checkable: true,
                signedOffDates: [time.onlyDays()])
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(CrossOver), findsNothing);
    });

    group('category colors', () {
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
        activityResponse = () => [a1, a2, a3, a4];

        void expectCorrectColor(String title, Color expectedColor) {
          final boxDecoration = tester
              .widget<Container>(find.descendant(
                  of: find.widgetWithText(ActivityTimepillarCard, title),
                  matching: find.byType(Container)))
              .decoration as BoxDecoration;
          expect(
            boxDecoration.border.bottom.color,
            expectedColor,
          );
        }

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();

        expectCorrectColor(a1.title, leftCategoryActiveColor);
        expectCorrectColor(a2.title, rightCategoryActiveColor);
        expectCorrectColor(a3.title, noCategoryColor);
        expectCorrectColor(a4.title, rightCategoryInactiveColor);
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
        activityResponse = () => [a1, a2, a3, a4];
        genericResponse = () => [
              timepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier:
                      MemoplannerSettings.calendarActivityTypeShowColorKey,
                ),
              ),
            ];

        void expectCorrectColor(String title, Color expectedColor) {
          final boxDecoration = tester
              .widget<Container>(find.descendant(
                  of: find.widgetWithText(ActivityTimepillarCard, title),
                  matching: find.byType(Container)))
              .decoration as BoxDecoration;
          expect(
            boxDecoration.border.bottom.color,
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
    });
  });

  group('Timepillar intervals', () {
    setUp(() {
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: TimepillarIntervalType.INTERVAL.index,
                identifier: MemoplannerSettings.viewOptionsTimeIntervalKey,
              ),
            ),
            timepillarGeneric,
          ];
    });
    testWidgets('Activity outside interval is not visible',
        (WidgetTester tester) async {
      activityResponse = () => [
            Activity.createNew(
              title: 'title',
              startTime: time.copyWith(hour: 8, minute: 0),
            )
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsNothing);
    });

    testWidgets('Activity inside interval is visible',
        (WidgetTester tester) async {
      activityResponse = () => [
            Activity.createNew(
              title: 'title',
              startTime: time,
            )
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsOneWidget);
    });

    testWidgets('Activity spanning two intervals', (WidgetTester tester) async {
      final activityTime = DateTime(2020, 12, 01, 01, 00);
      activityResponse = () => [
            Activity.createNew(
              title: 'title',
              startTime: activityTime,
              duration: 6.hours(),
            )
          ];

      mockTicker.add(
          activityTime); // Shows night interval. Activity should be visible here.
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsOneWidget);

      mockTicker.add(DateTime(2020, 12, 01, 08,
          00)); // Morning starts at 6. Activity should be visible here.
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
      activityResponse = () => [
            Activity.createNew(
              title: 'title',
              startTime: activityStartTime,
            )
          ];

      mockTicker.add(DateTime(2020, 12, 01, 01, 01));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsNothing);

      mockTicker.add(DateTime(2020, 12, 01, 09, 59));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsNothing);

      mockTicker.add(DateTime(2020, 12, 01, 10, 00, 01));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsOneWidget);
    });

    testWidgets('Activity is shown when interval is whole day',
        (WidgetTester tester) async {
      final activityStartTime = DateTime(2020, 12, 01, 10, 00);
      activityResponse = () => [
            Activity.createNew(
              title: 'title',
              startTime: activityStartTime,
            )
          ];

      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: TimepillarIntervalType.DAY_AND_NIGHT.index,
                identifier: MemoplannerSettings.viewOptionsTimeIntervalKey,
              ),
            ),
            timepillarGeneric,
          ];

      mockTicker.add(DateTime(2020, 12, 01, 01, 01));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsOneWidget);
    });

    testWidgets(
        'Day activity is only shown in day interval when interval is DAY',
        (WidgetTester tester) async {
      final activityStartTime = DateTime(2020, 12, 01, 10, 00);
      activityResponse = () => [
            Activity.createNew(
              title: 'title',
              startTime: activityStartTime,
            )
          ];

      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: TimepillarIntervalType.DAY.index,
                identifier: MemoplannerSettings.viewOptionsTimeIntervalKey,
              ),
            ),
            timepillarGeneric,
          ];

      mockTicker.add(DateTime(2020, 12, 01, 01, 00));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsNothing);

      mockTicker.add(DateTime(2020, 12, 01, 07, 00));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsOneWidget);

      mockTicker.add(DateTime(2020, 12, 01, 23, 30));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityTimepillarCard), findsNothing);
    });
  });
}
