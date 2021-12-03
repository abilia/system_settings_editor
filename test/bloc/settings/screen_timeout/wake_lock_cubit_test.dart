import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  late WakeLockCubit wakeLockCubit;
  late MockMemoplannerSettingBloc mockMemoplannerSettingBloc;
  late MockBattery mockBattery;
  const timout = Duration(minutes: 30);
  late StreamController<BatteryState> streamController;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsNotLoaded());
    mockBattery = MockBattery();
    streamController = StreamController<BatteryState>();
    when(() => mockBattery.onBatteryStateChanged)
        .thenAnswer((invocation) => streamController.stream);

    wakeLockCubit = WakeLockCubit(
      screenTimeoutCallback: Future.value(timout),
      memoSettingsBloc: mockMemoplannerSettingBloc,
      battery: mockBattery,
    );
  });

  test('set screen on while charging', () {
    expectLater(
      wakeLockCubit.stream,
      emits(
        const WakeLockState(
          systemScreenTimeout: timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: true,
        ),
      ),
    );
    streamController.add(BatteryState.charging);
  });

  test('set timeout to 15 minutes, defaults to 30', () {
    const newTimeout = Duration(minutes: 15);
    expectLater(
      wakeLockCubit.stream,
      emits(
        const WakeLockState(
          systemScreenTimeout: newTimeout,
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
          systemScreenTimeout: newTimeout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: false,
        ),
      ),
    );
    wakeLockCubit.setScreenTimeout(newTimeout);
  });
}
