import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:memoplanner/bloc/all.dart';

import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:memoplanner/repository/ticker.dart';

import 'package:test/scaffolding.dart';

import '../../mocks/mock_bloc.dart';

void main() {
  final initialTime = DateTime(2021, 01, 26, 09, 26);
  late MockTimerCubit mockTimerCubit;
  late StreamController<DateTime> streamController;

  setUp(() {
    mockTimerCubit = MockTimerCubit();
    streamController = StreamController<DateTime>();
    when(() => mockTimerCubit.stream)
        .thenAnswer((invocation) => const Stream.empty());
    when(() => mockTimerCubit.state).thenReturn(TimerState());
  });

  tearDown(() {
    streamController.close();
  });

  final pastTimer = AbiliaTimer.createNew(
        title: 'past timer',
        startTime: initialTime.subtract(1.hours()),
        duration: 30.minutes(),
      ),
      ongoingTimer = AbiliaTimer.createNew(
        title: 'ongoing timer',
        startTime: initialTime.subtract(5.minutes()),
        duration: 10.minutes(),
      );

  final ongoingTimerOccasion = TimerOccasion(ongoingTimer, Occasion.current),
      pastTimerOccasion = TimerOccasion(pastTimer, Occasion.past);

  blocTest<TimerAlarmBloc, TimerAlarmState>(
    'Timer past is past',
    setUp: () => when(() => mockTimerCubit.stream)
        .thenAnswer((invocation) => Stream.fromIterable([
              TimerState(timers: [pastTimer]),
            ])),
    build: () => TimerAlarmBloc(
      ticker: Ticker.fake(initialTime: initialTime),
      timerCubit: mockTimerCubit,
    ),
    expect: () => [
      TimerAlarmState(
        timers: [pastTimerOccasion],
        queue: const [],
      ),
    ],
  );

  blocTest<TimerAlarmBloc, TimerAlarmState>(
    'One past and one current',
    setUp: () => when(() => mockTimerCubit.stream)
        .thenAnswer((invocation) => Stream.fromIterable([
              TimerState(timers: [
                pastTimer,
                ongoingTimer,
              ])
            ])),
    build: () => TimerAlarmBloc(
      ticker: Ticker.fake(initialTime: initialTime),
      timerCubit: mockTimerCubit,
    ),
    expect: () => [
      TimerAlarmState(timers: [
        pastTimerOccasion,
        ongoingTimerOccasion,
      ], queue: [
        ongoingTimerOccasion,
      ]),
    ],
  );

  blocTest<TimerAlarmBloc, TimerAlarmState>(
    'Timer current then time goes goes to past',
    build: () => TimerAlarmBloc(
      ticker: Ticker.fake(
        initialTime: initialTime,
        stream: streamController.stream,
      ),
      timerCubit: mockTimerCubit,
    ),
    seed: () => TimerAlarmState(
      timers: [ongoingTimerOccasion],
      queue: [ongoingTimerOccasion],
    ),
    act: (bloc) =>
        streamController.add(initialTime.add(5.minutes() + 1.seconds())),
    expect: () => [
      TimerAlarmState(
        timers: [ongoingTimerOccasion.toPast()],
        queue: const [],
      ),
    ],
  );

  blocTest<TimerAlarmBloc, TimerAlarmState>(
    'Timer updates',
    setUp: () {
      when(() => mockTimerCubit.stream).thenAnswer(
        (invocation) => Stream.fromIterable(
          [
            TimerState(timers: [pastTimer]),
            TimerState(timers: [
              pastTimer,
              ongoingTimer,
            ]),
            TimerState(timers: [pastTimer]),
          ],
        ),
      );
    },
    build: () => TimerAlarmBloc(
      ticker: Ticker.fake(
        initialTime: initialTime,
        stream: streamController.stream,
      ),
      timerCubit: mockTimerCubit,
    ),
    expect: () => [
      TimerAlarmState(
        timers: [pastTimerOccasion],
        queue: const [],
      ),
      TimerAlarmState(
        timers: [pastTimerOccasion, ongoingTimerOccasion],
        queue: [ongoingTimerOccasion],
      ),
      TimerAlarmState(
        timers: [pastTimerOccasion],
        queue: const [],
      ),
    ],
  );

  final t1 = TimerOccasion(
          AbiliaTimer.createNew(
            title: 't1',
            startTime: initialTime,
            duration: 10.minutes(),
          ),
          Occasion.current),
      t2 = TimerOccasion(
          AbiliaTimer.createNew(
            title: 't2',
            startTime: initialTime,
            duration: 10.minutes() + 1.seconds(),
          ),
          Occasion.current),
      t3 = TimerOccasion(
          AbiliaTimer.createNew(
            title: 't3',
            startTime: initialTime,
            duration: 10.minutes() - 1.seconds(),
          ),
          Occasion.current),
      t4 = TimerOccasion(
          AbiliaTimer.createNew(
            title: 't4',
            startTime: initialTime.subtract(1.seconds()),
            duration: 10.minutes(),
          ),
          Occasion.current);

  final timersOccasion = [t1, t2, t3, t4];
  final timers = timersOccasion.map((t) => t.timer);

  blocTest<TimerAlarmBloc, TimerAlarmState>(
    'Timer queue order by endtime correct',
    setUp: () {
      when(() => mockTimerCubit.stream).thenAnswer(
        (invocation) => Stream.fromIterable(
          [
            TimerState(timers: timers),
          ],
        ),
      );
    },
    build: () => TimerAlarmBloc(
      ticker: Ticker.fake(
        initialTime: initialTime,
        stream: streamController.stream,
      ),
      timerCubit: mockTimerCubit,
    ),
    expect: () => [
      TimerAlarmState(
        timers: timersOccasion,
        queue: [t3, t4, t1, t2],
      ),
    ],
  );

  final oldTimer = AbiliaTimer.createNew(
        title: 'old timer',
        startTime: initialTime.subtract(
          24.hours() + 1.minutes(),
        ),
        duration: 1.hours(),
      ),
      notSoOldTimer = AbiliaTimer.createNew(
        title: 'old timer',
        startTime: initialTime.subtract(
          23.hours() + 59.minutes(),
        ),
        duration: 5.minutes(),
      );

  blocTest<TimerAlarmBloc, TimerAlarmState>(
    'Timer older then 24h does not show',
    setUp: () {
      when(() => mockTimerCubit.stream).thenAnswer(
        (invocation) => Stream.fromIterable(
          [
            TimerState(timers: [oldTimer, notSoOldTimer]),
          ],
        ),
      );
    },
    build: () => TimerAlarmBloc(
      ticker: Ticker.fake(
        initialTime: initialTime,
        stream: streamController.stream,
      ),
      timerCubit: mockTimerCubit,
    ),
    act: (bloc) {
      streamController.add(initialTime);
      streamController.add(initialTime.add(1.minutes()));
    },
    expect: () => [
      TimerAlarmState(
        timers: [TimerOccasion(notSoOldTimer, Occasion.past)],
        queue: const [],
      ),
      TimerAlarmState(
        timers: const [],
        queue: const [],
      ),
    ],
  );
}
