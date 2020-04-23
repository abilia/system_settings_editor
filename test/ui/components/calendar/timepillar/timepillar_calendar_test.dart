import 'dart:async';
import 'dart:ui';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/translations.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/calendar/all.dart';

import '../../../../mocks.dart';

void main() {
  MockActivityDb mockActivityDb;
  StreamController<DateTime> mockTicker;
  final changeViewButtonFinder = find.byKey(TestKey.changeView);
  final timePillarButtonFinder = find.byKey(TestKey.timePillarButton);
  final time = DateTime(2007, 08, 09, 10, 11);
  final leftTitle = 'LeftCategoryActivity',
      rightTitle = 'RigthCategoryActivity';
  final activities = [
    FakeActivity.fullday(time),
    FakeActivity.starts(
      time,
      title: rightTitle,
    ).copyWith(checkable: true),
    FakeActivity.starts(time.add(30.minutes())).copyWith(
      category: Category.left,
      title: leftTitle,
      fileId: 'fileId',
    )
  ];
  List<Activity> givenActivities = activities;

  ActivityResponse activityResponse = () => givenActivities;

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
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(givenActivities));
    GetItInitializer()
      ..activityDb = mockActivityDb
      ..userDb = MockUserDb()
      ..ticker = (() => mockTicker.stream)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..tokenDb = mockTokenDb
      ..startTime = time
      ..httpClient = Fakes.client(activityResponse)
      ..fileStorage = MockFileStorage()
      ..init();
  });
  tearDown(() {
    givenActivities = activities;
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
      givenActivities = [];

      await goToTimePillar(tester);
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == currentDotShape),
          hasLength(1));
    });

    testWidgets('Alwasy only one current dots', (WidgetTester tester) async {
      givenActivities = [];

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

    group('Timeline', () {
      testWidgets('Exists', (WidgetTester tester) async {
        await goToTimePillar(tester);
        expect(find.byType(Timeline), findsWidgets);
      });

      testWidgets('Tomorrow does not show timeline',
          (WidgetTester tester) async {
        await goToTimePillar(tester);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(Timeline), findsNothing);
      });

      testWidgets('Yesterday does not show timline',
          (WidgetTester tester) async {
        await goToTimePillar(tester);
        await tester.tap(previusDayButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(Timeline), findsNothing);
      });

      testWidgets('timeline is at same y pos as current-time-dot',
          (WidgetTester tester) async {
        await goToTimePillar(tester);
        final currentDot = tester
            .widgetList<AnimatedDot>(find.byType(AnimatedDot))
            .firstWhere((d) => d.decoration == currentDotShape);

        final currentDotPosition =
            await tester.getCenter(find.byWidget(currentDot));

        for (final element in find.byType(Timeline).evaluate()) {
          final RenderBox box = element.renderObject as RenderBox;
          final timeLinePostion =
              box.localToGlobal(box.size.center(Offset.zero));
          expect(timeLinePostion.dy, closeTo(currentDotPosition.dy, 0.0001));
        }
      });
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
    group('Activities', () {
      final leftActivityFinder = find.text(leftTitle);
      final rightActivityFinder = find.text(rightTitle);
      final cardFinder = find.byType(ActivityTimepillarCard);

      testWidgets('Shows activity', (WidgetTester tester) async {
        // Act
        await goToTimePillar(tester);
        // Assert
        expect(leftActivityFinder, findsOneWidget);
        expect(rightActivityFinder, findsOneWidget);
        expect(cardFinder, findsNWidgets(2));
      });

      testWidgets('Activities is right or left of timeline',
          (WidgetTester tester) async {
        // Arrange
        await goToTimePillar(tester);

        // Act
        final timelineXPostion =
            await tester.getCenter(find.byType(Timeline).first).dx;
        final leftActivityXPostion =
            await tester.getCenter(leftActivityFinder).dx;
        final rightActivityXPostion =
            await tester.getCenter(rightActivityFinder).dx;

        // Assert
        expect(leftActivityXPostion, lessThan(timelineXPostion));
        expect(rightActivityXPostion, greaterThan(timelineXPostion));
      });

      testWidgets('tapping activity shows activity info',
          (WidgetTester tester) async {
        // Arrange
        await goToTimePillar(tester);
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
        await goToTimePillar(tester);
        // Act
        await tester.tap(rightActivityFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CheckButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.activityBackButton));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(CheckMarkWithBorder), findsOneWidget);
      });
    });
  });
}
