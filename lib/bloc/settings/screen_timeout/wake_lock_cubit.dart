import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/generic/generic.dart';
import 'package:seagull/models/settings/keep_screen_awake_settings.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class WakeLockCubit extends Cubit<KeepScreenAwakeState> {
  WakeLockCubit({
    required this.genericBloc,
    required BatteryCubit batteryCubit,
    required KeepScreenAwakeSettings screenAwakeSettings,
  }) : super(KeepScreenAwakeState(
            screenTimeout: timeoutOneMinute,
            screenOnWhileCharging:
                screenAwakeSettings.keepScreenOnWhileCharging)) {
    _batterySubscription = batteryCubit.stream.listen((event) {
      onBatteryUpdated(event);
    });
    _initDuration(screenAwakeSettings.keepScreenOnAlways);
  }

  static const int _maxInt = 2147483647;
  static const Duration timeoutUnknown = Duration(milliseconds: -1);
  static const Duration timeoutDisabled = Duration(milliseconds: 0);
  static const Duration timeoutOneMinute = Duration(minutes: 1);
  static const Duration timeoutThirtyMinutes = Duration(minutes: 30);

  final GenericBloc genericBloc;
  late final StreamSubscription _batterySubscription;

  _initDuration(bool keepScreenOnAlways) async {
    if (keepScreenOnAlways) {
      setScreenTimeout(timeoutDisabled);
    } else {
      setScreenTimeout(
          await SystemSettingsEditor.screenOffTimeout ?? timeoutOneMinute);
    }
  }

  setKeepScreenAwakeWhilePluggedIn(bool keepOn) {
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
    _updateKeepScreenAwake(state.screenTimeout, keepOn, state.batteryCharging);
  }

  // the timeout coming from SystemSettings could be set to very long
  // ("disabled"), but we don't know whether it's because the screen is always on
  // or because the charger is plugged in. Hence, if it's more than 30 minutes
  // it's ignored
  setScreenTimeout(Duration timeout) {
    Duration duration;
    if (timeout > timeoutThirtyMinutes) {
      duration = state.screenTimeout;
    } else if (timeout == timeoutDisabled) {
      duration = timeoutDisabled;
    } else if (timeout.inMinutes > 1) {
      duration = timeoutThirtyMinutes;
    } else {
      duration = timeoutOneMinute;
    }
    genericBloc.add(
      GenericUpdated(
        [
          MemoplannerSettingData.fromData(
            data: duration == timeoutDisabled,
            identifier: KeepScreenAwakeSettings.keepScreenOnAlwaysKey,
          ),
        ],
      ),
    );
    _updateKeepScreenAwake(
        duration, state.screenOnWhileCharging, state.batteryCharging);
  }

  @override
  Future<void> close() async {
    await _batterySubscription.cancel();
    return super.close();
  }

  @visibleForTesting
  onBatteryUpdated(BatteryCubitState batteryState) {
    final _batteryCharging =
        batteryState.batteryState == BatteryState.charging ||
            batteryState.batteryState == BatteryState.full;
    _updateKeepScreenAwake(
        state.screenTimeout, state.screenOnWhileCharging, _batteryCharging);
  }

  _updateKeepScreenAwake(Duration screenTimeoutDuration,
      bool keepScreenOnWhileCharging, bool batteryCharging) async {
    if (screenTimeoutDuration == timeoutDisabled ||
        (keepScreenOnWhileCharging && state.batteryCharging)) {
      SystemSettingsEditor.setScreenOffTimeout(
          const Duration(milliseconds: _maxInt));
    } else {
      SystemSettingsEditor.setScreenOffTimeout(screenTimeoutDuration);
    }
    emit(KeepScreenAwakeState(
        screenTimeout: screenTimeoutDuration,
        screenOnWhileCharging: keepScreenOnWhileCharging,
        batteryCharging: batteryCharging));
  }
}

class KeepScreenAwakeState extends Equatable {
  final Duration screenTimeout;
  final bool screenOnWhileCharging;
  final bool batteryCharging;

  const KeepScreenAwakeState(
      {required this.screenTimeout,
      required this.screenOnWhileCharging,
      this.batteryCharging = false});

  @override
  List<Object?> get props =>
      [screenTimeout, screenOnWhileCharging, batteryCharging];
}
