import 'dart:async';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
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

import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  late StreamController<DateTime> mockTicker;
  final time = DateTime(2021, 09, 01, 12, 47);
  const leftTitle = 'LeftCategoryActivity',
      rightTitle = 'RigthCategoryActivity';

  ActivityResponse activityResponse = () => [];
  GenericResponse genericResponse = () => [];

  final nextDayButtonFinder = find.byIcon(AbiliaIcons.goToNextPage);
  final previusDayButtonFinder = find.byIcon(AbiliaIcons.returnToPreviousPage);

  final twoTimepillarGeneric = Generic.createNew<MemoplannerSettingData>(
    data: MemoplannerSettingData.fromData(
        data: DayCalendarType.twoTimepillars.index,
        identifier: MemoplannerSettings.viewOptionsTimeViewKey),
  );

  setUp(() async {
    setupPermissions();
    setupFakeTts();

    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    mockTicker = StreamController<DateTime>();
    final mockActivityDb = MockActivityDb();
    when(() => mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activityResponse()));
    when(() => mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value([]));
    when(() => mockActivityDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    final mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));

    genericResponse = () => [twoTimepillarGeneric];
    activityResponse = () => [];

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..genericDb = mockGenericDb
      ..sortableDb = FakeSortableDb()
      ..ticker = Ticker(stream: mockTicker.stream, initialTime: time)
      ..fireBasePushService = FakeFirebasePushService()
      ..client = Fakes.client(
        activityResponse: activityResponse,
        genericResponse: genericResponse,
      )
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..syncDelay = SyncDelays.zero
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('Shows', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
  });

  testWidgets('Go to now button shows for next day but not when going back',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsNothing);
    await tester.tap(nextDayButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsOneWidget);
    await tester.tap(previusDayButtonFinder);
    await tester.pumpAndSettle();
    expect(find.byKey(TestKey.goToNowButton), findsNothing);
  });

  group('timepillar', () {
    testWidgets('timepillar shows', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(SliverTimePillar), findsNWidgets(2));
    });

    testWidgets('tts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final hour = DateFormat('h').format(time);
      await tester.verifyTts(find.text(hour).at(0), contains: hour);
    });

    testWidgets('tts on 24 h two timepillar', (WidgetTester tester) async {
      tester.binding.window.alwaysUse24HourFormatTestValue = true;
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final hour = DateFormat('H').format(time);
      await tester.verifyTts(find.text(hour), contains: hour);
    });
  });

  group('timepillar dots', () {
    testWidgets('Current and future dots shows', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(PastDots), findsNothing);
      expect(find.byType(AnimatedDot), findsWidgets);
      expect(find.byType(CurrentDots), findsWidgets);
      expect(find.byType(FutureDots), findsWidgets);
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
    testWidgets('Exists', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(Timeline), findsWidgets);
    });

    testWidgets('Dont Exists if settings say so', (WidgetTester tester) async {
      genericResponse = () => [
            twoTimepillarGeneric,
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
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier: MemoplannerSettings.settingDisplayTimelineKey,
              ),
            ),
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
    }, skip: true); // Timeline is still wonky

    testWidgets('hourTimeline hidden by default', (WidgetTester tester) async {
      await tester.pumpWidget(App());
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
                identifier: MemoplannerSettings.settingDisplayHourLinesKey,
              ),
            ),
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNWidgets(2));
    });

    testWidgets('hourTimeline shows on push', (WidgetTester tester) async {
      final pushBloc = PushBloc();
      await tester.pumpWidget(App(pushBloc: pushBloc));
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNothing);

      genericResponse = () => [
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: MemoplannerSettings.settingDisplayHourLinesKey,
              ),
            ),
          ];
      pushBloc.add(PushEvent('collapse_key'));
      await tester.pumpAndSettle();
      expect(find.byType(HourLines), findsNWidgets(2));
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
            twoTimepillarGeneric,
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

    testWidgets('memoplanner settings - show category push update ',
        (WidgetTester tester) async {
      final pushBloc = PushBloc();

      await tester.pumpWidget(App(
        pushBloc: pushBloc,
      ));
      await tester.pumpAndSettle();

      expect(leftFinder, findsOneWidget);
      expect(rightFinder, findsOneWidget);

      genericResponse = () => [
            twoTimepillarGeneric,
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
    group('category colors', () {
      void expectCorrectColor(
        WidgetTester tester,
        String title,
        Color expectedColor,
      ) {
        final boxDecoration = tester
            .widget<Container>(find.descendant(
                of: find.widgetWithText(ActivityTimepillarCard, title),
                matching: find.byType(Container)))
            .decoration as BoxDecoration;
        expect(
          boxDecoration.border?.top.color,
          expectedColor,
        );
        expect(
          boxDecoration.border?.bottom.color,
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
        activityResponse = () => [a1, a2, a3, a4];

        await tester.pumpWidget(App());
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
        activityResponse = () => [a1, a2, a3, a4];
        genericResponse = () => [
              twoTimepillarGeneric,
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier:
                      MemoplannerSettings.calendarActivityTypeShowColorKey,
                ),
              ),
            ];

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();

        expectCorrectColor(tester, a1.title, noCategoryColor);
        expectCorrectColor(tester, a2.title, noCategoryColor);
        expectCorrectColor(tester, a3.title, noCategoryColor);
        expectCorrectColor(tester, a4.title, noCategoryColor);
      });
    });
  });

  group('Activities', () {
    final leftActivityFinder = find.text(leftTitle);
    final rightActivityFinder = find.text(rightTitle);
    final cardFinder = find.byType(ActivityTimepillarCard);
    final atNightTime = time.add(12.hours());
    setUp(() {
      activityResponse = () => [
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
            twoTimepillarGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier: MemoplannerSettings.dotsInTimepillarKey),
            ),
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
  });
}
