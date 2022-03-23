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
  late Stream<PointerDown> activityDetectedStream;

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
    activityDetectedStream = activityDetectionCubit.stream;
  });

  tearDown(() {
    tickerController.close();
  });

  blocTest<InactivityCubit, InactivityState>(
    'initial state',
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
      activityDetectedStream,
    ),
    verify: (c) => expect(
      c.state,
      UserTouch(initialTime),
    ),
  );

  blocTest<InactivityCubit, InactivityState>(
    'ticks  calendar inactivity ',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(activityTimeout: 10.minutes().inMilliseconds),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
      activityDetectedStream,
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
          MemoplannerSettings(activityTimeout: 10.minutes().inMilliseconds),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
      activityDetectedStream,
    ),
    act: (c) {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(6.minutes()));
      tickerController.add(initialTime.add(10.minutes()));
    },
    expect: () => [
      CalendarInactivityThresholdReached(initialTime),
      HomeScreenInactivityThresholdReached(
        startView: StartView.values.first,
        showScreensaver: false,
      ),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'ticks first activity timeout then calendar inactivity',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(activityTimeout: 1.minutes().inMilliseconds),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
      activityDetectedStream,
    ),
    act: (c) {
      tickerController.add(initialTime.add(1.minutes()));
      tickerController.add(initialTime.add(6.minutes()));
    },
    expect: () => [
      CalendarInactivityThresholdReached(initialTime),
      HomeScreenInactivityThresholdReached(
        startView: StartView.values.first,
        showScreensaver: false,
      ),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'activity one sec before flat min does not emit',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(activityTimeout: 1.minutes().inMilliseconds),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 6),
      fakeTicker,
      settingsBloc,
      activityDetectedStream,
    ),
    act: (c) async {
      tickerController.add(initialTime.add(59.seconds()));
      await c.ticker.seconds.any((element) => true);
      activityDetectionCubit.onPointerDown();
      tickerController.add(initialTime.add(1.minutes()));
    },
    expect: () => [
      UserTouch(initialTime.add(59.seconds())),
    ],
  );

  blocTest<InactivityCubit, InactivityState>(
    'SGC-1487 zero timout disables',
    setUp: () {
      when(() => settingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(activityTimeout: 0),
        ),
      );
    },
    build: () => InactivityCubit(
      const Duration(minutes: 5),
      fakeTicker,
      settingsBloc,
      activityDetectedStream,
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
}
