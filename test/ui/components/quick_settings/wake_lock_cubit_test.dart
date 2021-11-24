import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/screen_timeout/wake_lock_cubit.dart';
import 'package:seagull/models/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  const MethodChannel systemSettingsChannel =
      MethodChannel('system_settings_editor');
  TestWidgetsFlutterBinding.ensureInitialized();

  late WakeLockCubit wakeLockCubit;
  late FakeGenericBloc fakeGenericBloc;

  setUp(() {
    registerFallbackValue(const BatteryCubitState(BatteryState.full, 100));
    fakeGenericBloc = FakeGenericBloc();
    systemSettingsChannel
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method.startsWith('getScreenOffTimeout')) {
        return 60000;
      }
      return null;
    });
    wakeLockCubit = WakeLockCubit(
        genericBloc: fakeGenericBloc,
        batteryCubit: BatteryCubit(battery: FakeBattery()),
        screenAwakeSettings: const KeepScreenAwakeSettings());
  });

  tearDown(() {
    systemSettingsChannel.setMockMethodCallHandler(null);
  });

  test('set screen on while charging', () {
    expectLater(
      wakeLockCubit.stream,
      emits(const KeepScreenAwakeState(
          screenOnWhileCharging: true, screenTimeout: Duration(minutes: 1))),
    );
    wakeLockCubit.setKeepScreenAwakeWhilePluggedIn(true);
  });

  test('set timeout to 15 minutes, defaults to 30', () {
    expectLater(
      wakeLockCubit.stream,
      emits(const KeepScreenAwakeState(
          screenOnWhileCharging: false, screenTimeout: Duration(minutes: 30))),
    );
    wakeLockCubit.setScreenTimeout(const Duration(minutes: 15));
  });

  test('set timeout to 0 minutes', () {
    expectLater(
      wakeLockCubit.stream,
      emits(const KeepScreenAwakeState(
          screenOnWhileCharging: false, screenTimeout: Duration(minutes: 0))),
    );
    wakeLockCubit.setScreenTimeout(const Duration(minutes: 0));
  });
}
