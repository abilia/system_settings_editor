import 'package:bloc_test/bloc_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:seagull_fakes/all.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

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
    registerFallbackValue(defaultTimer);
  });

  setUp(() {
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
      ticker: Ticker.fake(initialTime: now),
      analytics: FakeSeagullAnalytics(),
    ),
    act: (timerBloc) => timerBloc.loadTimers(),
    expect: () => [defaultState],
  );

  blocTest<TimerCubit, TimerState>(
    'deleteTimer emits no timers',
    build: () => TimerCubit(
      timerDb: mockTimerDb,
      ticker: Ticker.fake(initialTime: now),
      analytics: FakeSeagullAnalytics(),
    ),
    act: (timerBloc) => timerBloc
      ..loadTimers()
      ..deleteTimer(defaultTimer),
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
      ticker: Ticker.fake(initialTime: now),
      analytics: FakeSeagullAnalytics(),
    ),
    act: (timerBloc) => timerBloc
      ..loadTimers()
      ..addTimer(newTimer, EditTimerMetaData(fromTemplate: false)),
    expect: () => [
      defaultState,
      TimerState(timers: [defaultTimer, newTimer]),
    ],
  );
}
