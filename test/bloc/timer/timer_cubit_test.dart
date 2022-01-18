import 'package:seagull/bloc/timer/timer_cubit.dart';
import 'package:seagull/models/abilia_timer.dart';
import 'package:test/test.dart';

import '../../mocks/mocks.dart';

void main() {
  final defaultTimer = AbiliaTimer(
      id: 'fake-id',
      title: 'test timer',
      duration: const Duration(minutes: 5),
      startTime: DateTime.now());

  final defaultState = TimerState(timers: [defaultTimer]);
  late TimerCubit timerCubit;
  late MockTimerDb mockTimerDb;

  setUpAll(() {
    registerFallbackValue(defaultTimer);
  });

  setUp(() {
    mockTimerDb = MockTimerDb();
    when(() => mockTimerDb.getAllTimers())
        .thenAnswer((_) => Future(() => [defaultTimer]));
    when(() => mockTimerDb.delete(any())).thenAnswer((_) => Future(() => 1));
    when(() => mockTimerDb.insert(any())).thenAnswer((_) => Future(() => null));

    timerCubit = TimerCubit(timerDb: mockTimerDb);
  });

  test('loadTimers returns one timer', () {
    timerCubit.loadTimers();
    expectLater(timerCubit.stream, emits(defaultState));
  });

  test('deleteTimer emits no timers', () {
    timerCubit.loadTimers();
    timerCubit.deleteTimer(defaultTimer);
    expectLater(timerCubit.stream,
        emitsInOrder([defaultState, const TimerState(timers: [])]));
  });

  test('addTimer returns two timers', () {
    timerCubit.loadTimers();
    final newTimer = AbiliaTimer(
        id: 'fake-id2',
        title: 'test timer 2',
        duration: const Duration(minutes: 15),
        startTime: DateTime.now());
    timerCubit.addTimer(newTimer);
    expectLater(
        timerCubit.stream,
        emitsInOrder([
          defaultState,
          TimerState(timers: [defaultTimer, newTimer])
        ]));
  });
}
