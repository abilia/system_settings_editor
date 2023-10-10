import 'package:bloc_test/bloc_test.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull_fakes/all.dart';

void main() {
  final now = DateTime(2033, 01, 27, 11, 55);
  final defaultTimer = AbiliaTimer.createNew(
    title: 'test timer',
    duration: const Duration(minutes: 5),
    startTime: now,
  );

  final defaultState = TimerState(timers: [defaultTimer]);

  late MockTimerDb mockTimerDb;

  setUpAll(() {
    registerFallbackValue(
      AbiliaTimer(
        id: '',
        title: '',
        startTime: DateTime(2),
        duration: Duration.zero,
      ),
    );
  });

  setUp(() async {
    mockTimerDb = MockTimerDb();
    when(() => mockTimerDb.getAllTimers())
        .thenAnswer((_) => Future(() => [defaultTimer]));
    when(() => mockTimerDb.delete(any())).thenAnswer((_) => Future(() => 1));
    when(() => mockTimerDb.insert(any())).thenAnswer((_) => Future(() => 1));
  });

  blocTest<TimerCubit, TimerState>(
    'loadTimers returns one timer',
    build: () => TimerCubit(
      timerDb: mockTimerDb,
      analytics: FakeSeagullAnalytics(),
    ),
    act: (timerBloc) async => timerBloc.loadTimers(),
    expect: () => [defaultState],
  );

  blocTest<TimerCubit, TimerState>(
    'deleteTimer emits no timers',
    build: () => TimerCubit(
      timerDb: mockTimerDb,
      analytics: FakeSeagullAnalytics(),
    ),
    act: (timerBloc) async {
      await timerBloc.loadTimers();
      await timerBloc.deleteTimer(defaultTimer);
    },
    expect: () => [defaultState, TimerState(timers: const [])],
  );

  final newTimer = AbiliaTimer.createNew(
    title: 'test timer 2',
    duration: const Duration(minutes: 15),
    startTime: now,
  );

  blocTest<TimerCubit, TimerState>(
    'addTimer returns two timers',
    build: () => TimerCubit(
      timerDb: mockTimerDb,
      analytics: FakeSeagullAnalytics(),
    ),
    act: (timerBloc) async {
      await timerBloc.loadTimers();
      await timerBloc.addTimer(newTimer);
    },
    expect: () => [
      defaultState,
      TimerState(timers: [defaultTimer, newTimer]),
    ],
  );
}
