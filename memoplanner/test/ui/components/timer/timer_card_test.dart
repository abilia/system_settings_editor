import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/abilia_timer.dart';
import 'package:memoplanner/models/occasion/event_occasion.dart';
import 'package:memoplanner/models/occasion/timer_occasion.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_fakes/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';

void main() {
  final nowTime = DateTime(2022, 01, 29, 13, 37);
  final startTime = DateTime(2022, 01, 29, 13, 50);
  final day = DateTime(2022, 01, 29);
  late MockDayEventsCubit dayEventsCubitMock;

  setUp(() async {
    dayEventsCubitMock = MockDayEventsCubit();
    final expected = EventsState(
      activities: const [],
      timers: const [],
      fullDayActivities: const [],
      day: day,
      occasion: Occasion.current,
    );

    when(() => dayEventsCubitMock.state).thenReturn(expected);
    when(() => dayEventsCubitMock.stream)
        .thenAnswer((_) => Stream.fromIterable([expected]));
    GetItInitializer()
      ..ticker = Ticker.fake(initialTime: nowTime)
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  Widget wrap(Widget child) => Directionality(
        textDirection: TextDirection.ltr,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<SpeechSettingsCubit>(
              create: (context) => FakeSpeechSettingsCubit(),
            ),
            BlocProvider<DayEventsCubit>(
              create: (context) => dayEventsCubitMock,
            ),
            BlocProvider<MemoplannerSettingsBloc>(
              create: (context) => FakeMemoplannerSettingsBloc(),
            ),
            BlocProvider<ClockBloc>(
              create: (context) => ClockBloc.fixed(startTime),
            ),
          ],
          child: child,
        ),
      );

  testWidgets('timer card duration before tick is correct', (tester) async {
    const timerTitle = 'timer title';
    final timerOccasion = TimerOccasion(
      AbiliaTimer.createNew(
        title: timerTitle,
        startTime: nowTime.subtract(const Duration(minutes: 30)),
        duration: const Duration(hours: 1),
      ),
      Occasion.current,
    );
    await tester.pumpWidget(
      wrap(TimerCard(timerOccasion: timerOccasion, day: nowTime)),
    );

    expect(find.text(timerTitle), findsOneWidget);
    expect(find.text('01:00:00'), findsNothing);
    expect(find.text('30:00'), findsOneWidget);
  });

  testWidgets('Long titles does not cause a RenderFlex overflow (bug SGC-1420)',
      (tester) async {
    //Test will fail with a RenderFlex overflowed error if title overflows

    const timerTitle =
        'A very very very very very very very very long timer title';
    final timerOccasion = TimerOccasion(
      AbiliaTimer.createNew(
        title: timerTitle,
        startTime: nowTime.subtract(const Duration(minutes: 30)),
        duration: const Duration(hours: 1),
      ),
      Occasion.current,
    );
    await tester.pumpWidget(
      wrap(
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: TimerCard(timerOccasion: timerOccasion, day: nowTime),
          ),
        ),
      ),
    );
  });

  testWidgets('timer card does not use opacity', (tester) async {
    const timerTitle = 'timer title';
    final timerOccasion = TimerOccasion(
      AbiliaTimer.createNew(
        title: timerTitle,
        startTime: nowTime.subtract(const Duration(minutes: 30)),
        duration: const Duration(hours: 1),
      ),
      Occasion.current,
    );
    await tester.pumpWidget(
      wrap(TimerCard(
        timerOccasion: timerOccasion,
        day: nowTime,
      )),
    );
    final finder = find.byType(Opacity).first;
    final op = finder.evaluate().single.widget as Opacity;
    expect(op.opacity, 1.0);
  });

  testWidgets('timer card uses opacity', (tester) async {
    const timerTitle = 'timer title';
    final timerOccasion = TimerOccasion(
      AbiliaTimer.createNew(
        title: timerTitle,
        startTime: nowTime.subtract(const Duration(minutes: 30)),
        duration: const Duration(hours: 1),
      ),
      Occasion.current,
    );
    await tester.pumpWidget(
      wrap(TimerCard(
        timerOccasion: timerOccasion,
        day: nowTime,
        useOpacity: true,
      )),
    );
    final finder = find.byType(Opacity).first;
    final op = finder.evaluate().single.widget as Opacity;
    expect(op.opacity, 0.4);
  });
}
