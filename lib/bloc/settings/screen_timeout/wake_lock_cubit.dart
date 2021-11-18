import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/models/settings/keep_screen_awake_settings.dart';
import 'package:system_settings_editor/system_settings_editor.dart';
import 'package:wakelock/wakelock.dart';

class WakeLockCubit extends Cubit<ScreenAwakeState> {
  WakeLockCubit({
    required this.genericBloc,
    required batteryCubit,
    required screenAwakeSettings,
  }) : super(ScreenAwakeState(
            screenOnWhileCharging:
                screenAwakeSettings.keepScreenOnWhileCharging,
            screenTimeout: timeoutDisabled,
            wakeLockEnabled: false)) {
    _batterySubscription = batteryCubit.stream.listen((event) {
      _onBatteryUpdated(event);
      _updateKeepScreenAwake();
    });
    _keepScreenAwakeWhilePluggedIn =
        screenAwakeSettings.keepScreenOnWhileCharging;
    _screenTimeoutDuration = screenAwakeSettings.keepScreenOnAlways
        ? timeoutDisabled
        : timeoutUnknown;
    _init();
  }

  final GenericBloc genericBloc;
  late final StreamSubscription _batterySubscription;
  late bool _keepScreenAwakeWhilePluggedIn;
  static Duration timeoutUnknown = const Duration(minutes: -1);
  static Duration timeoutDisabled = const Duration(minutes: 0);

  bool _batteryCharging = false;
  Duration _screenTimeoutDuration = timeoutUnknown;

  _init() async {
    if (_screenTimeoutDuration.isNegative) {
      _screenTimeoutDuration = await SystemSettingsEditor.screenOffTimeout ??
          const Duration(minutes: 1);
    }
    _updateKeepScreenAwake();
  }

  setKeepScreenAwakeWhilePluggedIn(bool keepOn) {
    _keepScreenAwakeWhilePluggedIn = keepOn;
    genericBloc.add(
      GenericUpdated(
        [
          MemoplannerSettingData.fromData(
            data: keepOn,
            identifier: KeepScreenAwakeSettings.keepScreenOnWhileChargingKey,
          ),
        ],
      ),
    );
    _updateKeepScreenAwake();
  }

  setScreenTimeout(Duration? timeout) {
    if (timeout != null) {
      _screenTimeoutDuration = timeout;
      genericBloc.add(
        GenericUpdated(
          [
            MemoplannerSettingData.fromData(
              data: timeout.inMinutes < 1,
              identifier: KeepScreenAwakeSettings.keepScreenOnAlwaysKey,
            ),
          ],
        ),
      );
      SystemSettingsEditor.setScreenOffTimeout(timeout);
      _updateKeepScreenAwake();
    }
  }

  @override
  Future<void> close() async {
    await _batterySubscription.cancel();
    return super.close();
  }

  _onBatteryUpdated(BatteryCubitState state) {
    _batteryCharging = state.batteryState == BatteryState.charging ||
        state.batteryState == BatteryState.full;
    // TODO: special case if batterlyLevel is low?
  }

  _updateKeepScreenAwake() async {
    if (_screenTimeoutDuration.inMinutes < 1 ||
        (_keepScreenAwakeWhilePluggedIn && _batteryCharging)) {
      Wakelock.enable();
    } else {
      Wakelock.disable();
    }
    emit(ScreenAwakeState(
        screenTimeout: _screenTimeoutDuration,
        screenOnWhileCharging: _keepScreenAwakeWhilePluggedIn,
        wakeLockEnabled: await Wakelock.enabled));
  }
}

class ScreenAwakeState extends Equatable {
  final Duration screenTimeout;
  final bool screenOnWhileCharging;
  final bool wakeLockEnabled;

  const ScreenAwakeState(
      {required this.screenTimeout,
      required this.screenOnWhileCharging,
      required this.wakeLockEnabled});

  @override
  List<Object?> get props =>
      [screenTimeout, screenOnWhileCharging, wakeLockEnabled];
}
