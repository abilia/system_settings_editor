import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final title = 'title';
  final time = DateTime(1987, 05, 22, 04, 04);
  final startTime = time.millisecondsSinceEpoch;
  StreamController<DateTime> streamController;
  Stream<DateTime> stream;

  setUp(() {
    streamController = StreamController<DateTime>();
    stream = streamController.stream;
  });

  Widget multiWrap(List<ActivityOccasion> activityOccasions,
      {DateTime initialTime}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocProvider(
        create: (context) =>
            ClockBloc(stream, initialTime: initialTime ?? time),
        child: Stack(
          children: <Widget>[
            Timeline(width: 40),
            ActivityBoard(
              activities: activityOccasions,
              categoryMinWidth: 400,
            ),
          ],
        ),
      ),
    );
  }

  Widget wrap(ActivityOccasion activityOccasion,
          {occasion = Occasion.current}) =>
      multiWrap([activityOccasion]);

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
  group('position', () {
    testWidgets('Has same position', (WidgetTester tester) async {
      final time = DateTime(2020, 04, 21, 07, 30);

      final activities = [
        time.subtract(7.minutes()),
        time,
        time.add(7.minutes()),
      ]
          .map(
            (st) => ActivityOccasion.forTest(
              Activity.createNew(
                  title: st.toString(), startTime: st.millisecondsSinceEpoch),
            ),
          )
          .toList();

      await tester.pumpWidget(multiWrap(activities, initialTime: time));
      await tester.pumpAndSettle();

      final timelineYPostion =
          await tester.getTopLeft(find.byType(Timeline).first).dy;
      final activityYPos = activities.map(
        (a) => tester.getTopLeft(find.byKey(ObjectKey(a))).dy,
      );

      print(timelineYPostion);
      for (final y in activityYPos) {
        expect(y, closeTo(timelineYPostion, dotSize / 2));
      }
    });

    testWidgets('Has not same position', (WidgetTester tester) async {
      final time = DateTime(2020, 04, 21, 07, 30);
      final activities = [
        time.subtract(8.minutes()),
        time.add(8.minutes()),
      ]
          .map(
            (st) => ActivityOccasion.forTest(
              Activity.createNew(
                title: st.toString(),
                startTime: st.millisecondsSinceEpoch,
              ),
            ),
          )
          .toList();

      await tester.pumpWidget(multiWrap(activities));
      expect(find.byType(Timeline), findsOneWidget);

      final timelineYPostion =
          await tester.getTopLeft(find.byType(Timeline).first).dy;
      final activityYPos = activities.map(
        (a) => tester.getTopLeft(find.byKey(ObjectKey(a))).dy,
      );

      for (final y in activityYPos) {
        expect((y - timelineYPostion).abs(), greaterThan(dotDistance));
      }
    });

    testWidgets('Is not placed at same horizontal position',
        (WidgetTester tester) async {
      final activities = List.generate(
        10,
        (i) => ActivityOccasion.forTest(
          Activity.createNew(
            title: 'activity $i',
            startTime: startTime,
            duration: ((i * 10) % 60).minutes().inMilliseconds,
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
      final activities = List.generate(
        12 * 60,
        (i) => ActivityOccasion.forTest(
          Activity.createNew(
            title: 'activity $i',
            startTime:
                DateTime(2020, 04, 23).add(i.minutes()).millisecondsSinceEpoch,
          ),
        ),
      );
      final cards = ActivityBoard.positionTimepillarCards(activities);
      final uniques = cards.map((f) => {f.top, f.column});

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
              duration: 7.minutes().inMilliseconds,
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
              duration: 8.minutes().inMilliseconds,
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
              duration: 22.minutes().inMilliseconds,
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
              duration: 23.minutes().inMilliseconds,
            ),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsNWidgets(2));
    });
    testWidgets('All different dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          ActivityOccasion.forTest(
            Activity.createNew(
              title: title,
              startTime: time.subtract(30.minutes()).millisecondsSinceEpoch,
              duration: 60.minutes().inMilliseconds,
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
              .where((d) => d.decoration == pastSideDotShape),
          hasLength(2));
      expect(
          tester
              .widgetList<AnimatedDot>(find.byType(AnimatedDot))
              .where((d) => d.decoration == futureSideDotShape),
          hasLength(1));
    });
  });
}
