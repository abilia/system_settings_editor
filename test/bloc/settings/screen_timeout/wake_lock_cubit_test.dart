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
  const _timout = Duration(minutes: 30);
  late WakeLockCubit _wakeLockCubit;
  late MockMemoplannerSettingBloc _mockMemoplannerSettingBloc;
  late MockBattery _mockBattery;
  late _MockCallback _mockCallback;
  late StreamController<BatteryState> _batteryStreamController;
  late StreamController<MemoplannerSettingsState> _memoSettingsStreamController;

  setUpAll(registerFallbackValues);

  setUp(() {
    _memoSettingsStreamController =
        StreamController<MemoplannerSettingsState>();
    _mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => _mockMemoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsNotLoaded());
    when(() => _mockMemoplannerSettingBloc.stream)
        .thenAnswer((_) => _memoSettingsStreamController.stream);
    _mockBattery = MockBattery();
    _batteryStreamController = StreamController<BatteryState>();
    when(() => _mockBattery.onBatteryStateChanged)
        .thenAnswer((invocation) => _batteryStreamController.stream);

    _mockCallback = _MockCallback();
    when(() => _mockCallback.timeoutCallback())
        .thenAnswer((_) => Future.value(_timout));
    _wakeLockCubit = WakeLockCubit(
      screenTimeoutCallback: _mockCallback.timeoutCallback(),
      memoSettingsBloc: _mockMemoplannerSettingBloc,
      battery: _mockBattery,
    );
  });

  test('set screen on while charging', () {
    expectLater(
      _wakeLockCubit.stream,
      emits(
        const WakeLockState(
          systemScreenTimeout: _timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: true,
        ),
      ),
    );
    _batteryStreamController.add(BatteryState.charging);
  });

  test('set timeout to 15 minutes, defaults to 30', () {
    const newTimeout = Duration(minutes: 15);
    expectLater(
      _wakeLockCubit.stream,
      emits(
        const WakeLockState(
          systemScreenTimeout: newTimeout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: false,
        ),
      ),
    );
    _wakeLockCubit.setScreenTimeout(newTimeout);
  });

  test('set timeout to 0 minutes', () {
    const newTimeout = Duration.zero;
    expectLater(
      _wakeLockCubit.stream,
      emits(
        const WakeLockState(
          systemScreenTimeout: newTimeout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: false,
        ),
      ),
    );
    _wakeLockCubit.setScreenTimeout(newTimeout);
  });

  test('screenTimeoutCallback is called and emits', () {
    verify(() => _mockCallback.timeoutCallback()).called(1);
    expect(
      _wakeLockCubit.state,
      const WakeLockState(
        systemScreenTimeout: _timout,
        keepScreenAwakeSettings: KeepScreenAwakeSettings(),
        batteryCharging: false,
      ),
    );
  });

  test('when battery stream changes to charging', () {
    expectLater(
      _wakeLockCubit.stream,
      emitsInOrder([
        const WakeLockState(
          systemScreenTimeout: _timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: true,
        ),
        const WakeLockState(
          systemScreenTimeout: _timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: false,
        ),
        const WakeLockState(
          systemScreenTimeout: _timout,
          keepScreenAwakeSettings: KeepScreenAwakeSettings(),
          batteryCharging: true,
        ),
      ]),
    );
    _batteryStreamController.add(BatteryState.charging);
    _batteryStreamController.add(BatteryState.discharging);
    _batteryStreamController.add(BatteryState.full);
  });

  test('when KeepScreenAwakeSettings changes', () {
    expectLater(
      _wakeLockCubit.stream,
      emitsInOrder([
        const WakeLockState(
          systemScreenTimeout: _timout,
          keepScreenAwakeSettings:
              KeepScreenAwakeSettings(keepScreenOnAlways: true),
          batteryCharging: false,
        ),
        const WakeLockState(
          systemScreenTimeout: _timout,
          keepScreenAwakeSettings:
              KeepScreenAwakeSettings(keepScreenOnWhileCharging: true),
          batteryCharging: false,
        ),
      ]),
    );
    _memoSettingsStreamController.add(
      const MemoplannerSettingsLoaded(
        MemoplannerSettings(
          keepScreenAwakeSettings: KeepScreenAwakeSettings(
            keepScreenOnAlways: true,
          ),
        ),
      ),
    );
    _memoSettingsStreamController.add(
      const MemoplannerSettingsLoaded(
        MemoplannerSettings(
          keepScreenAwakeSettings: KeepScreenAwakeSettings(
            keepScreenOnWhileCharging: true,
          ),
        ),
      ),
    );
  });
}
