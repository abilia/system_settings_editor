import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';

import '../../../fakes/fake_db_and_repository.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  const timout = Duration(minutes: 30);
  late MockBattery mockBattery;
  late StreamController<BatteryState> batteryStreamController;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockBattery = MockBattery();
    batteryStreamController = StreamController<BatteryState>();
    when(() => mockBattery.onBatteryStateChanged)
        .thenAnswer((invocation) => batteryStreamController.stream);
  });

  tearDown(() {
    batteryStreamController.close();
  });

  blocTest<WakeLockCubit, WakeLockState>(
    'set screen on while charging',
    build: () => WakeLockCubit(
      settingsDb: FakeSettingsDb(),
      battery: mockBattery,
      hasBattery: true,
    )..setScreenTimeout(const Duration(minutes: 30)),
    act: (cubit) => batteryStreamController.add(BatteryState.charging),
    expect: () => [
      const WakeLockState(
        hasBattery: true,
        screenTimeout: timout,
        batteryCharging: true,
      )
    ],
  );

  const newTimeout = Duration(minutes: 15);
  blocTest<WakeLockCubit, WakeLockState>(
    'set timeout to 15 minutes',
    build: () => WakeLockCubit(
      settingsDb: FakeSettingsDb(),
      battery: mockBattery,
      hasBattery: true,
    ),
    act: (cubit) => cubit.setScreenTimeout(newTimeout),
    expect: () => [
      const WakeLockState(
        hasBattery: true,
        screenTimeout: newTimeout,
      ),
    ],
  );

  blocTest<WakeLockCubit, WakeLockState>(
    'set timeout to 0 minutes',
    build: () => WakeLockCubit(
      settingsDb: FakeSettingsDb(),
      battery: mockBattery,
      hasBattery: true,
    ),
    act: (cubit) => cubit.setScreenTimeout(Duration.zero),
    expect: () => [
      const WakeLockState(
        hasBattery: true,
        screenTimeout: Duration.zero,
      ),
    ],
  );

  blocTest<WakeLockCubit, WakeLockState>(
    'when battery stream changes to charging',
    build: () => WakeLockCubit(
      settingsDb: FakeSettingsDb(),
      battery: mockBattery,
      hasBattery: true,
    ),
    act: (cubit) => batteryStreamController
      ..add(BatteryState.charging)
      ..add(BatteryState.discharging)
      ..add(BatteryState.full),
    expect: () => [
      const WakeLockState(
        hasBattery: true,
        batteryCharging: true,
      ),
      const WakeLockState(
        hasBattery: true,
        batteryCharging: false,
      ),
      const WakeLockState(
        hasBattery: true,
        batteryCharging: true,
      ),
    ],
  );
}
