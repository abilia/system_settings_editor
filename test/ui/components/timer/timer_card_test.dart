import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/abilia_timer.dart';
import 'package:seagull/models/occasion/event_occasion.dart';
import 'package:seagull/models/occasion/timer_occasion.dart';
import 'package:seagull/repository/ticker.dart';
import 'package:seagull/ui/all.dart';

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

  Widget wrap(final Widget child) => Directionality(
        textDirection: TextDirection.ltr,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SettingsCubit(settingsDb: FakeSettingsDb()),
            ),
            BlocProvider<DayEventsCubit>(
              create: (context) => dayEventsCubitMock,
            ),
            BlocProvider<MemoplannerSettingBloc>(
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

  testWidgets('timer card doesn\'t use opacity', (tester) async {
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
    Finder finder = find.byType(Opacity).first;
    Opacity op = finder.evaluate().single.widget as Opacity;
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
    Finder finder = find.byType(Opacity).first;
    Opacity op = finder.evaluate().single.widget as Opacity;
    expect(op.opacity, 0.4);
  });
}
