import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

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
    dayPartCubit = DayPartCubit(settingsBloc, ClockBloc.withTicker(fakeTicker));
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
    ),
    verify: (c) => expect(
      c.state,
      SomethingHappened(initialTime),
    ),
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
    ),
    act: (c) {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(6.minutes()));
    },
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
    ),
    act: (c) {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(6.minutes()));
      tickerController.add(initialTime.add(10.minutes()));
    },
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
    ),
    act: (c) {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(6.minutes()));
    },
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
    ),
    act: (c) async {
      tickerController.add(initialTime.add(59.seconds()));
      await c.ticker.seconds.any((element) => true);
      activityDetectionCubit.onPointerDown();
      tickerController.add(initialTime.add(1.minutes()));
    },
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
    ),
    act: (c) {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(2.minutes()));
      tickerController.add(initialTime.add(3.minutes()));
      tickerController.add(initialTime.add(4.minutes()));
      tickerController.add(initialTime.add(5.minutes()));
    },
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
    ),
    act: (c) {
      notificationAlarm.add(activityAlarm);
    },
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
      ),
      act: (c) {
        tickerController.add(initialTime.add(1.minutes()));
        tickerController.add(initialTime.add(5.minutes()));
        tickerController.add(initialTime.add(10.minutes()));
        tickerController.add(initialTime.add(20.minutes()));
      },
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
      ),
      act: (c) {
        tickerController.add(initialTime.add(1.minutes()));
        tickerController.add(initialTime.add(5.minutes()));
        tickerController.add(initialTime.add(10.minutes()));
        tickerController.add(initialTime.add(20.minutes()));
      },
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
      ),
      act: (c) {
        tickerController.add(initialTime.add(1.minutes()));
        tickerController.add(initialTime.add(5.minutes()));
        tickerController.add(initialTime.add(10.minutes()));
        tickerController.add(initialTime.add(20.minutes()));
      },
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
      ),
      act: (c) {
        tickerController.add(initialTime.add(1.minutes()));
        tickerController.add(initialTime.add(5.minutes()));
        tickerController.add(initialTime.add(10.minutes()));
        tickerController.add(initialTime.add(20.minutes()));
        tickerController.add(night);
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
      ),
      act: (c) async {
        tickerController.add(initialTime.add(1.minutes()));
        tickerController.add(initialTime.add(5.minutes()));
        tickerController.add(initialTime.add(10.minutes()));
        tickerController.add(initialTime.add(20.minutes()));
        tickerController.add(night);
        await c.dayPartCubit.stream.firstWhere((state) => state.isNight);
        tickerController.add(morning);
      },
      expect: () => [
        ReturnToTodayThresholdReached(initialTime),
        HomeScreenThresholdReached(initialTime),
        const ScreensaverState(),
        SomethingHappened(morning),
      ],
    );
  });
}
