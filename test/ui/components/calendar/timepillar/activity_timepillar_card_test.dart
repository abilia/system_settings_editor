import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final title = 'title';
  final startTime = DateTime(1987, 05, 22, 04, 04);

  StreamController<DateTime> streamController;
  Stream<DateTime> stream;

  setUp(() {
    streamController = StreamController<DateTime>();
    stream = streamController.stream;
  });

  Widget multiWrap(Iterable<Activity> activities,
      {occasion = Occasion.current, DateTime initialTime}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlocProvider(
        create: (context) =>
            ClockBloc(stream, initialTime: initialTime ?? startTime),
        child: Stack(
          children: activities
              .map<Widget>(
                (a) => ActivityTimepillarCard(
                  key: ObjectKey(a),
                  activityOccasion: ActivityOccasion.forTest(a, occasion),
                ),
              )
              .toList()
                ..add(Timeline(width: 40.0)),
        ),
      ),
    );
  }

  Widget wrap(activity, {occasion = Occasion.current}) =>
      multiWrap([activity], occasion: occasion);

  testWidgets('shows title', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        Activity.createNew(
          title: title,
          startTime: startTime,
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
          .map((st) => Activity.createNew(
              title: st.toString(), startTime: st))
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
          .map((st) => Activity.createNew(
              title: st.toString(), startTime: st))
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
  });

  group('side dots', () {
    testWidgets('only start does not show dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          Activity.createNew(
            title: title,
            startTime: startTime,
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsNothing);
    });
    testWidgets('7 minutes does not show dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          Activity.createNew(
            title: title,
            startTime: startTime,
            duration: 7.minutes(),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsNothing);
    });
    testWidgets('8 minutes shows one dot', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          Activity.createNew(
            title: title,
            startTime: startTime,
            duration: 8.minutes(),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsOneWidget);
    });
    testWidgets('22 minutes shows one dot', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          Activity.createNew(
            title: title,
            startTime: startTime,
            duration: 22.minutes(),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsOneWidget);
    });
    testWidgets('23 minutes shows two dot', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          Activity.createNew(
            title: title,
            startTime: startTime,
            duration: 23.minutes(),
          ),
        ),
      );
      expect(find.byType(AnimatedDot), findsNWidgets(2));
    });
    testWidgets('All different dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          Activity.createNew(
            title: title,
            startTime: startTime.subtract(30.minutes()),
            duration: 60.minutes(),
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
