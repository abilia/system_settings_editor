import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../mocks/mock_bloc.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  late MemoplannerSettingsBloc settingsBloc;
  late DayPartCubit dayPartCubit;
  final initialTime = DateTime(2000, 01, 01, 14, 00);
  late StreamController<DateTime> tickerController;
  late Ticker fakeTicker;
  late TouchDetectionCubit activityDetectionCubit;
  late StreamController<TimerAlarmState> timers;
  late StreamController<NotificationAlarm?> notificationAlarm;

  setUpAll(registerFallbackValues);
  setUp(() {
    tickerController = StreamController<DateTime>();
    settingsBloc = MockMemoplannerSettingBloc();
    when(() => settingsBloc.state)
        .thenReturn(MemoplannerSettingsLoaded(const MemoplannerSettings()));
    when(() => settingsBloc.stream)
        .thenAnswer((invocation) => const Stream.empty());
    fakeTicker =
        Ticker.fake(initialTime: initialTime, stream: tickerController.stream);
    activityDetectionCubit = TouchDetectionCubit();
    timers = StreamController<TimerAlarmState>();
    notificationAlarm = StreamController<NotificationAlarm?>();
    dayPartCubit =
        DayPartCubit(settingsBloc, ClockCubit.withTicker(fakeTicker));
  });

  tearDown(() {
    tickerController.close();
    timers.close();
    notificationAlarm.close();
  });

  blocTest<InactivityCubit, InactivityState>(
    'initial state',
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    verify: (c) => expect(
      c.state,
      SomethingHappened(initialTime),
    ),
  );

  blocTest<InactivityCubit, InactivityState>(
    'Inactivity emits nothing without buffer delay',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              timeout: TimeoutSettings(
                duration: 10.minutes(),
              ),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    act: (c) async {
      tickerController
        ..add(initialTime.add(1.minutes()))
        ..add(initialTime.add(6.minutes()));
      // No delay here
    },
    expect: () => [],
  );

  blocTest<InactivityCubit, InactivityState>(
    'ticks calendar inactivity ',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              timeout: TimeoutSettings(
                duration: 10.minutes(),
              ),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    act: (c) async {
      tickerController
        ..add(initialTime.add(1.minutes()))
        ..add(initialTime.add(6.minutes()));
    },
    wait: Duration.zero,
    expect: () => [
      ReturnToTodayThresholdReached(initialTime),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'ticks first calendar inactivity then activity timeout',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              timeout: TimeoutSettings(duration: 10.minutes()),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    act: (c) async {
      tickerController
        ..add(initialTime.add(1.minutes()))
        ..add(initialTime.add(6.minutes()))
        ..add(initialTime.add(10.minutes()));
    },
    wait: Duration.zero,
    expect: () => [
      ReturnToTodayThresholdReached(initialTime),
      const HomeScreenFinalState(),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'ticks first activity timeout then calendar inactivity',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              timeout: TimeoutSettings(duration: 1.minutes()),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    act: (c) async {
      tickerController
        ..add(initialTime.add(1.minutes()))
        ..add(initialTime.add(6.minutes()));
    },
    wait: Duration.zero,
    expect: () => [
      const HomeScreenFinalState(),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'activity one sec before flat min does not emit',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              timeout: TimeoutSettings(duration: 1.minutes()),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    act: (c) async {
      tickerController.add(initialTime.add(59.seconds()));
      await c.ticker.seconds.any((element) => true);
      activityDetectionCubit.onPointerDown();
      tickerController.add(initialTime.add(1.minutes()));
    },
    wait: Duration.zero,
    expect: () => [
      SomethingHappened(initialTime.add(59.seconds())),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'SGC-1487 zero timeout disables',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            functions: FunctionsSettings(
              timeout: TimeoutSettings(duration: Duration.zero),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    act: (c) async {
      tickerController
        ..add(initialTime.add(1.minutes()))
        ..add(initialTime.add(2.minutes()))
        ..add(initialTime.add(3.minutes()))
        ..add(initialTime.add(4.minutes()))
        ..add(initialTime.add(5.minutes()));
    },
    wait: Duration.zero,
    expect: () => [const ReturnToTodayFinalState()],
  );

  final activityAlarm = StartAlarm(ActivityDay(
    Activity.createNew(
      startTime: initialTime.add(1.hours()),
    ),
    initialTime,
  ));
  blocTest<InactivityCubit, InactivityState>(
    'NotificationAlarm triggers new state',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            functions: FunctionsSettings(
              timeout: TimeoutSettings(duration: Duration.zero),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    act: (c) {
      notificationAlarm.add(activityAlarm);
    },
    wait: Duration.zero,
    expect: () => [SomethingHappened(activityAlarm.notificationTime)],
  );

  final timerAlarm = TimerAlarm(
    AbiliaTimer(
      id: '123',
      duration: 1.hours(),
      startTime: initialTime,
    ),
  );
  blocTest<InactivityCubit, InactivityState>(
    'TimerAlarm triggers new state',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            functions: FunctionsSettings(
              timeout: TimeoutSettings(duration: Duration.zero),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      fakeTicker,
      settingsBloc,
      dayPartCubit,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
      clockDelay: Duration.zero,
    ),
    act: (c) async {
      timers.add(
        TimerAlarmState(
          timers: const [],
          queue: const [],
          firedAlarm: timerAlarm,
        ),
      );
    },
    wait: Duration.zero,
    expect: () => [SomethingHappened(timerAlarm.notificationTime)],
  );

  group('screensaver', () {
    blocTest<InactivityCubit, InactivityState>(
      'screensaver on 10 minutes emits first Return to today then ',
      setUp: () {
        when(() => settingsBloc.state).thenReturn(
          MemoplannerSettingsLoaded(
            const MemoplannerSettings(
              functions: FunctionsSettings(
                timeout: TimeoutSettings(
                  duration: Duration(minutes: 10),
                  screensaver: true,
                ),
              ),
            ),
          ),
        );
      },
      build: () => InactivityCubit(
        fakeTicker,
        settingsBloc,
        dayPartCubit,
        activityDetectionCubit.stream,
        notificationAlarm.stream,
        timers.stream,
        clockDelay: Duration.zero,
      ),
      act: (c) async {
        tickerController
          ..add(initialTime.add(1.minutes()))
          ..add(initialTime.add(5.minutes()))
          ..add(initialTime.add(10.minutes()))
          ..add(initialTime.add(20.minutes()));
      },
      wait: Duration.zero,
      expect: () => [
        ReturnToTodayThresholdReached(initialTime),
        const ScreensaverState(),
      ],
    );

    blocTest<InactivityCubit, InactivityState>(
      'screensaver on 5 minutes emits only screensaver ',
      setUp: () {
        when(() => settingsBloc.state).thenReturn(
          MemoplannerSettingsLoaded(
            const MemoplannerSettings(
              functions: FunctionsSettings(
                timeout: TimeoutSettings(
                  duration: Duration(minutes: 5),
                  screensaver: true,
                ),
              ),
            ),
          ),
        );
      },
      build: () => InactivityCubit(
        fakeTicker,
        settingsBloc,
        dayPartCubit,
        activityDetectionCubit.stream,
        notificationAlarm.stream,
        timers.stream,
        clockDelay: Duration.zero,
      ),
      act: (c) async {
        tickerController
          ..add(initialTime.add(1.minutes()))
          ..add(initialTime.add(5.minutes()))
          ..add(initialTime.add(10.minutes()))
          ..add(initialTime.add(20.minutes()));
      },
      wait: Duration.zero,
      expect: () => [
        const ScreensaverState(),
      ],
    );

    blocTest<InactivityCubit, InactivityState>(
      'screensaver only during night does not emit screensaver state during day',
      setUp: () {
        when(() => settingsBloc.state).thenReturn(
          MemoplannerSettingsLoaded(
            const MemoplannerSettings(
              functions: FunctionsSettings(
                timeout: TimeoutSettings(
                  duration: Duration(minutes: 5),
                  screensaver: true,
                  screensaverOnlyDuringNight: true,
                ),
              ),
            ),
          ),
        );
      },
      build: () => InactivityCubit(
        fakeTicker,
        settingsBloc,
        dayPartCubit,
        activityDetectionCubit.stream,
        notificationAlarm.stream,
        timers.stream,
        clockDelay: Duration.zero,
      ),
      act: (c) async {
        tickerController
          ..add(initialTime.add(1.minutes()))
          ..add(initialTime.add(5.minutes()))
          ..add(initialTime.add(10.minutes()))
          ..add(initialTime.add(20.minutes()));
      },
      wait: Duration.zero,
      expect: () => [
        HomeScreenThresholdReached(initialTime),
      ],
    );

    final night = initialTime.onlyDays().add(const DayParts().night);

    blocTest<InactivityCubit, InactivityState>(
      'screensaver only during night emits screensaver when night',
      setUp: () {
        when(() => settingsBloc.state).thenReturn(
          MemoplannerSettingsLoaded(
            const MemoplannerSettings(
              functions: FunctionsSettings(
                timeout: TimeoutSettings(
                  duration: Duration(minutes: 10),
                  screensaver: true,
                  screensaverOnlyDuringNight: true,
                ),
              ),
            ),
          ),
        );
      },
      build: () => InactivityCubit(
        fakeTicker,
        settingsBloc,
        dayPartCubit,
        activityDetectionCubit.stream,
        notificationAlarm.stream,
        timers.stream,
        clockDelay: Duration.zero,
      ),
      wait: Duration.zero,
      act: (c) async {
        tickerController.add(initialTime.add(1.minutes()));
        await Future.delayed(Duration.zero);
        tickerController.add(initialTime.add(5.minutes()));
        await Future.delayed(Duration.zero);
        tickerController.add(initialTime.add(10.minutes()));
        await Future.delayed(Duration.zero);
        tickerController.add(initialTime.add(20.minutes()));
        await Future.delayed(Duration.zero);
        tickerController.add(night);
        await Future.delayed(Duration.zero);
      },
      expect: () => [
        ReturnToTodayThresholdReached(initialTime),
        HomeScreenThresholdReached(initialTime),
        const ScreensaverState(),
      ],
    );

    final morning = initialTime.onlyDays().add(const DayParts().morning);
    blocTest<InactivityCubit, InactivityState>(
      'screensaver only during night wakes screen in morning',
      setUp: () {
        when(() => settingsBloc.state).thenReturn(
          MemoplannerSettingsLoaded(
            const MemoplannerSettings(
              functions: FunctionsSettings(
                timeout: TimeoutSettings(
                  duration: Duration(minutes: 10),
                  screensaver: true,
                  screensaverOnlyDuringNight: true,
                ),
              ),
            ),
          ),
        );
      },
      build: () => InactivityCubit(
        fakeTicker,
        settingsBloc,
        dayPartCubit,
        activityDetectionCubit.stream,
        notificationAlarm.stream,
        timers.stream,
        clockDelay: Duration.zero,
      ),
      act: (c) async {
        tickerController.add(initialTime.add(1.minutes()));
        await Future.delayed(Duration.zero);
        tickerController.add(initialTime.add(5.minutes()));
        await Future.delayed(Duration.zero);
        tickerController.add(initialTime.add(10.minutes()));
        await Future.delayed(Duration.zero);
        tickerController.add(initialTime.add(20.minutes()));
        await Future.delayed(Duration.zero);
        tickerController.add(night);
        await c.dayPartCubit.stream.firstWhere((state) => state.isNight);
        tickerController.add(morning);
      },
      wait: Duration.zero,
      expect: () => [
        ReturnToTodayThresholdReached(initialTime),
        HomeScreenThresholdReached(initialTime),
        const ScreensaverState(),
        SomethingHappened(morning),
        HomeScreenThresholdReached(morning),
      ],
    );
  });
}
