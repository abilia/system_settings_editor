import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

import '../../../../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final title = 'title';
  final startTime = DateTime(1987, 05, 22, 04, 04);

  StreamController<DateTime> streamController;
  Stream<DateTime> stream;
  MockSettingsDb mockSettingsDb;
  final textStyle = abiliaTextTheme.caption;

  setUp(() {
    streamController = StreamController<DateTime>();
    stream = streamController.stream;
    mockSettingsDb = MockSettingsDb();
    when(mockSettingsDb.dotsInTimepillar).thenReturn(true);
    GetItInitializer()
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  tearDown(GetIt.I.reset);

  Widget multiWrap(List<ActivityOccasion> activityOccasions,
      {DateTime initialTime}) {
    final startInterval = (initialTime ?? startTime).onlyDays();
    final interval = TimepillarInterval(
      start: startInterval,
      end: startInterval.add(1.days()),
    );
    final mockTimepillarBloc = MockTimepillarBloc();
    final ts = TimepillarState(interval, 1);
    when(mockTimepillarBloc.state).thenReturn(TimepillarState(
        TimepillarInterval(start: DateTime.now(), end: DateTime.now()), 1));
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) =>
                  ClockBloc(stream, initialTime: initialTime ?? startTime),
            ),
            BlocProvider<SettingsBloc>(
              create: (context) => SettingsBloc(settingsDb: mockSettingsDb),
            ),
            BlocProvider<TimepillarBloc>(
              create: (context) => mockTimepillarBloc,
            ),
          ],
          child: Stack(
            children: <Widget>[
              Timeline(
                width: 40,
                offset: -TimePillarCalendar.topMargin,
                timepillarState: ts,
              ),
              ActivityBoard(
                ActivityBoard.positionTimepillarCards(
                  activityOccasions,
                  textStyle,
                  1.0,
                  MemoplannerSettingsLoaded(MemoplannerSettings()).dayParts,
                  TimepillarSide.RIGHT,
                  ts,
                ),
                categoryMinWidth: 400,
                timepillarWidth: ts.totalWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget wrap(ActivityOccasion activityOccasion, {DateTime initialTime}) =>
      multiWrap([activityOccasion], initialTime: initialTime);
  testWidgets('shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        ActivityOccasion.forTest(
          Activity.createNew(
            title: title,
            startTime: startTime,
          ),
        ),
      ),
    );
    expect(find.text(title), findsOneWidget);
  });

  testWidgets('tts', (WidgetTester tester) async {
    final duration = 30.minutes();
    final endTime = startTime.add(duration);
    await initializeDateFormatting();
    final dateFormat = hourAndMinuteFromUse24(false, 'en');
    await tester.pumpWidget(
      wrap(
        ActivityOccasion.forTest(
          Activity.createNew(
            title: title,
            startTime: startTime,
            duration: duration,
          ),
        ),
      ),
    );
    await tester.verifyTts(find.text(title),
        exact: '$title, ${dateFormat(startTime)} - ${dateFormat(endTime)}');
  });

  group('position', () {
    testWidgets('Has same vertical position', (WidgetTester tester) async {
      final time = DateTime(2020, 04, 21, 07, 30);

      final activities = [
        time.subtract(7.minutes()),
        time,
        time.add(7.minutes()),
      ]
          .map(
            (st) => ActivityOccasion.forTest(
              Activity.createNew(
                title: st.toString(),
                startTime: st,
              ),
            ),
          )
          .toList();

      await tester.pumpWidget(multiWrap(activities, initialTime: time));
      await tester.pumpAndSettle();

      final timelineYPostion =
          tester.getTopLeft(find.byType(Timeline).first).dy;
      final activityYPos = activities.map(
        (a) => tester.getTopLeft(find.byKey(ObjectKey(a))).dy,
      );
      final interval = TimepillarInterval(start: time, end: time);
      final ts = TimepillarState(interval, 1);
      for (final y in activityYPos) {
        expect(y, closeTo(timelineYPostion, ts.dotSize / 2));
      }
    });

    testWidgets('Has not same vertical position', (WidgetTester tester) async {
      final time = DateTime(2020, 04, 21, 07, 30);
      final activities = [
        time.subtract(8.minutes()),
        time.add(8.minutes()),
      ]
          .map(
            (st) => ActivityOccasion.forTest(
              Activity.createNew(
                title: st.toString(),
                startTime: st,
              ),
            ),
          )
          .toList();

      await tester.pumpWidget(multiWrap(activities, initialTime: time));
      expect(find.byType(Timeline), findsOneWidget);

      final timelineYPostion =
          tester.getTopLeft(find.byType(Timeline).first).dy;
      final timelineMidPos = timelineYPostion + (Timeline.timelineHeight / 2);
      final activityYPos = activities.map(
        (a) => tester.getTopLeft(find.byKey(ObjectKey(a))).dy,
      );
      final ts = TimepillarState(
          TimepillarInterval(end: DateTime.now(), start: DateTime.now()), 1);
      for (final y in activityYPos) {
        final activityDotMidPos = y + ts.dotSize / 2;
        expect(
            (activityDotMidPos - timelineMidPos).abs(), equals(ts.dotDistance));
      }
    });
    testWidgets(
        'two activities with sufficient time distance has same horizonal position',
        (WidgetTester tester) async {
      final time = DateTime(2020, 04, 21, 07, 30);
      final activityA = ActivityOccasion.forTest(
        Activity.createNew(
          title: 'a',
          startTime: time,
        ),
      );
      final activityB = ActivityOccasion.forTest(
        Activity.createNew(
          title: 'b',
          startTime: time.add(2.hours()),
        ),
      );

      await tester
          .pumpWidget(multiWrap([activityA, activityB], initialTime: time));
      expect(find.byType(Timeline), findsOneWidget);

      final activityAXPos =
          tester.getTopLeft(find.byKey(ObjectKey(activityA))).dx;
      final activityBXPos =
          tester.getTopLeft(find.byKey(ObjectKey(activityB))).dx;

      expect(activityAXPos, activityBXPos);
    });
    testWidgets(
        'two activities to small time distance does not has same horizontal position',
        (WidgetTester tester) async {
      final time = DateTime(2020, 04, 21, 07, 30);
      final activityA = ActivityOccasion.forTest(
        Activity.createNew(
          title: 'a',
          startTime: time,
        ),
      );
      final activityB = ActivityOccasion.forTest(
        Activity.createNew(
          title: 'b',
          startTime: time.add(1.hours()),
        ),
      );

      await tester
          .pumpWidget(multiWrap([activityA, activityB], initialTime: time));
      expect(find.byType(Timeline), findsOneWidget);

      final activityAXPos =
          tester.getTopLeft(find.byKey(ObjectKey(activityA))).dx;
      final activityBXPos =
          tester.getTopLeft(find.byKey(ObjectKey(activityB))).dx;
      final ts = TimepillarState(
          TimepillarInterval(end: DateTime.now(), start: DateTime.now()), 1);
      expect((activityAXPos - activityBXPos).abs(),
          greaterThanOrEqualTo(ts.totalWidth));
    });
    testWidgets(
        'two activities to sufficient time distance but the first with a long title does not has same vertical position',
        (WidgetTester tester) async {
      final time = DateTime(2020, 04, 21, 07, 30);
      final activityA = ActivityOccasion.forTest(
        Activity.createNew(
          title:
              'aaAAaaaAaaaAaaAAAAAAAAAAAaaaaaaaaaaaaaaaaaaAaAaaaAAAaaaAaaAAAaAaaaAaAAAAaAaAaaAaaaaaaaaa',
          startTime: time,
        ),
      );
      final activityB = ActivityOccasion.forTest(
        Activity.createNew(
          title: 'b',
          startTime: time.add(2.hours()),
        ),
      );

      await tester
          .pumpWidget(multiWrap([activityA, activityB], initialTime: time));
      expect(find.byType(Timeline), findsOneWidget);

      final activityAXPos =
          tester.getTopLeft(find.byKey(ObjectKey(activityA))).dx;
      final activityBXPos =
          tester.getTopLeft(find.byKey(ObjectKey(activityB))).dx;

      final ts = TimepillarState(
          TimepillarInterval(end: DateTime.now(), start: DateTime.now()), 1);
      expect((activityAXPos - activityBXPos).abs(),
          greaterThanOrEqualTo(ts.totalWidth));
    });

    testWidgets('Is not placed at same horizontal position',
        (WidgetTester tester) async {
      final activities = List.generate(
        10,
        (i) => ActivityOccasion.forTest(
          Activity.createNew(
            title: 'activity $i',
            startTime: startTime,
            duration: ((i * 10) % 60).minutes(),
          ),
        ),
      );

      await tester.pumpWidget(multiWrap(activities));
      expect(find.byType(Timeline), findsOneWidget);

      final activityXPositions = activities.map(
        (a) => tester.getTopLeft(find.byKey(ObjectKey(a))).dx,
      );
      expect(activityXPositions.toSet().length, activityXPositions.length);
    });

    test('all position are unique', () async {
      final time = DateTime(2020, 04, 23);
      final interval = TimepillarInterval(
        start: time,
        end: time.add(1.days()),
      );
      final activities = List.generate(
        12 * 60,
        (i) => ActivityOccasion.forTest(
          Activity.createNew(
            title: 'activity $i',
            startTime: time.add(i.minutes()),
          ),
        ),
      );
      final boardData = ActivityBoard.positionTimepillarCards(
        activities,
        textStyle,
        1.0,
        DayParts(0, 0, 0, 0, 0),
        TimepillarSide.RIGHT,
        TimepillarState(interval, 1),
      );
      final uniques = boardData.cards.map((f) => {f.top, f.column});

      expect(uniques.toSet().length, uniques.length);
    });
  });

  group('side dots', () {
    testWidgets('only start does not show dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          ActivityOccasion.forTest(
            Activity.createNew(
              title: title,
              startTime: startTime,
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsNothing);
    });
    testWidgets('7 minutes does not show dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          ActivityOccasion.forTest(
            Activity.createNew(
              title: title,
              startTime: startTime,
              duration: 7.minutes(),
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsNothing);
    });
    testWidgets('8 minutes shows one dot', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          ActivityOccasion.forTest(
            Activity.createNew(
              title: title,
              startTime: startTime,
              duration: 8.minutes(),
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsOneWidget);
    });
    testWidgets('22 minutes shows one dot', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          ActivityOccasion.forTest(
            Activity.createNew(
              title: title,
              startTime: startTime,
              duration: 22.minutes(),
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsOneWidget);
    });
    testWidgets('23 minutes shows two dot', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          ActivityOccasion.forTest(
            Activity.createNew(
              title: title,
              startTime: startTime,
              duration: 23.minutes(),
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsNWidgets(2));
    });
    testWidgets('All different dots (day)', (WidgetTester tester) async {
      final start = DateTime(1987, 05, 22, 12, 04);
      await tester.pumpWidget(
        wrap(
          ActivityOccasion.forTest(
            Activity.createNew(
              title: title,
              startTime: start.subtract(30.minutes()),
              duration: 60.minutes(),
            ),
          ),
          initialTime: start,
        ),
      );
      expect(find.byType(AnimatedDot), findsNWidgets(4));
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == currentDotShape),
          hasLength(1));
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == pastSideDotShape),
          hasLength(2));
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == futureSideDotShape),
          hasLength(1));
    });

    testWidgets('All different dots (night)', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          ActivityOccasion.forTest(
            Activity.createNew(
              title: title,
              startTime: startTime.subtract(30.minutes()),
              duration: 60.minutes(),
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsNWidgets(4));
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == currentDotShape),
          hasLength(1));
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == pastNightDotShape),
          hasLength(2));
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == futureNightDotShape),
          hasLength(1));
    });
  });
}
