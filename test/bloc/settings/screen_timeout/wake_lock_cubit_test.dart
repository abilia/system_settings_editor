import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

abstract class _Callback {
  Future<Duration> timeoutCallback();
}

class _MockCallback extends Mock implements _Callback {}

void main() {
  const timout = Duration(minutes: 30);
  late WakeLockCubit wakeLockCubit;
  late MockMemoplannerSettingBloc mockMemoplannerSettingBloc;
  late MockBattery mockBattery;
  late _MockCallback mockCallback;
  late StreamController<BatteryState> batteryStreamController;
  late StreamController<MemoplannerSettings> memoSettingsStreamController;

  setUpAll(registerFallbackValues);

  setUp(() {
    memoSettingsStreamController = StreamController<MemoplannerSettings>();
    mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsNotLoaded());
    when(() => mockMemoplannerSettingBloc.stream)
        .thenAnswer((_) => memoSettingsStreamController.stream);
    mockBattery = MockBattery();
    batteryStreamController = StreamController<BatteryState>();
    when(() => mockBattery.onBatteryStateChanged)
        .thenAnswer((invocation) => batteryStreamController.stream);

    mockCallback = _MockCallback();
    when(() => mockCallback.timeoutCallback())
        .thenAnswer((_) => Future.value(timout));
    wakeLockCubit = WakeLockCubit(
      screenTimeoutCallback: mockCallback.timeoutCallback(),
      memoSettingsBloc: mockMemoplannerSettingBloc,
      battery: mockBattery,
    );
  });

  tearDown(() {
    batteryStreamController.close();
    memoSettingsStreamController.close();
  });

  test('set screen on while charging', () {
    expectLater(
      wakeLockCubit.stream,
      emits(
        const WakeLockState(
          screenTimeout: timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: true,
        ),
      ),
    );
    batteryStreamController.add(BatteryState.charging);
  });

  test('set timeout to 15 minutes, defaults to 30', () {
    const newTimeout = Duration(minutes: 15);
    expectLater(
      wakeLockCubit.stream,
      emits(
        const WakeLockState(
          screenTimeout: newTimeout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: false,
        ),
      ),
    );
    wakeLockCubit.setScreenTimeout(newTimeout);
  });

  test('set timeout to 0 minutes', () {
    const newTimeout = Duration.zero;
    expectLater(
      wakeLockCubit.stream,
      emits(
        const WakeLockState(
          screenTimeout: newTimeout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: false,
        ),
      ),
    );
    wakeLockCubit.setScreenTimeout(newTimeout);
  });

  test('screenTimeoutCallback is called and emits', () {
    verify(() => mockCallback.timeoutCallback()).called(1);
    expect(
      wakeLockCubit.state,
      const WakeLockState(
        screenTimeout: timout,
        keepScreenAwakeSettings: KeepScreenAwakeSettings(),
        batteryCharging: false,
      ),
    );
  });

  test('when battery stream changes to charging', () {
    expectLater(
      wakeLockCubit.stream,
      emitsInOrder([
        const WakeLockState(
          screenTimeout: timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: true,
        ),
        const WakeLockState(
          screenTimeout: timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: false,
        ),
        const WakeLockState(
          screenTimeout: timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: true,
        ),
      ]),
    );
    batteryStreamController.add(BatteryState.charging);
    batteryStreamController.add(BatteryState.discharging);
    batteryStreamController.add(BatteryState.full);
  });

  test('when KeepScreenAwakeSettings changes', () {
    expectLater(
      wakeLockCubit.stream,
      emitsInOrder([
        const WakeLockState(
          screenTimeout: timout,
          keepScreenAwakeSettings:
              KeepScreenAwakeSettings(keepScreenOnAlways: true),
          batteryCharging: false,
        ),
        const WakeLockState(
          screenTimeout: timout,
          keepScreenAwakeSettings:
              KeepScreenAwakeSettings(keepScreenOnWhileCharging: true),
          batteryCharging: false,
        ),
      ]),
    );
    memoSettingsStreamController.add(
      MemoplannerSettingsLoaded(
        const MemoplannerSettings(
          keepScreenAwake: KeepScreenAwakeSettings(
            keepScreenOnAlways: true,
          ),
        ),
      ),
    );
    memoSettingsStreamController.add(
      MemoplannerSettingsLoaded(
        const MemoplannerSettings(
          keepScreenAwake: KeepScreenAwakeSettings(
            keepScreenOnWhileCharging: true,
          ),
        ),
      ),
    );
  });
}
