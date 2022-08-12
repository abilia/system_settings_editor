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
  late MemoplannerSettingBloc settingsBloc;
  final initialTime = DateTime(2000);
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
        .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings()));
    when(() => settingsBloc.stream)
        .thenAnswer((invocation) => const Stream.empty());
    fakeTicker =
        Ticker.fake(initialTime: initialTime, stream: tickerController.stream);
    activityDetectionCubit = TouchDetectionCubit();
    timers = StreamController<TimerAlarmState>();
    notificationAlarm = StreamController<NotificationAlarm?>();
  });

  tearDown(() {
    tickerController.close();
    timers.close();
    notificationAlarm.close();
  });

  blocTest<InactivityCubit, InactivityState>(
    'initial state',
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
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
              screensaver: TimeoutSettings(
                duration: 10.minutes(),
              ),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
    ),
    act: (c) {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(6.minutes()));
    },
    expect: () => [
      CalendarInactivityThresholdReached(initialTime),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'ticks first calendar inactivity then activity timeout',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              screensaver: TimeoutSettings(duration: 10.minutes()),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
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
      CalendarInactivityThresholdReached(initialTime),
      const HomeScreenInactivityThresholdReached(),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'ticks first activity timeout then calendar inactivity',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              screensaver: TimeoutSettings(duration: 1.minutes()),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
    ),
    act: (c) {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(6.minutes()));
    },
    expect: () => [
      CalendarInactivityThresholdReached(initialTime),
      const HomeScreenInactivityThresholdReached(),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'activity one sec before flat min does not emit',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              screensaver: TimeoutSettings(duration: 1.minutes()),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
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
    'SGC-1487 zero timout disables',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              screensaver: TimeoutSettings(duration: Duration.zero),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 5),
      fakeTicker,
      settingsBloc,
      activityDetectionCubit.stream,
      notificationAlarm.stream,
      timers.stream,
    ),
    act: (c) async {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(2.minutes()));
      tickerController.add(initialTime.add(3.minutes()));
      tickerController.add(initialTime.add(4.minutes()));
      tickerController.add(initialTime.add(5.minutes()));
    },
    expect: () => [CalendarInactivityThresholdReached(initialTime)],
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
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              screensaver: TimeoutSettings(duration: Duration.zero),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 5),
      fakeTicker,
      settingsBloc,
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
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            functions: FunctionsSettings(
              screensaver: TimeoutSettings(duration: Duration.zero),
            ),
          ),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 5),
      fakeTicker,
      settingsBloc,
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
}
