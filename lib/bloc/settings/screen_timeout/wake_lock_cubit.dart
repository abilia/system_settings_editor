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
            screenOnWhileCharging:
                screenAwakeSettings.keepScreenOnWhileCharging,
            screenTimeout: KeepScreenAwakeState.timeoutDisabled)) {
    _batterySubscription = batteryCubit.stream.listen((event) {
      onBatteryUpdated(event);
      _updateKeepScreenAwake();
    });
    _keepScreenAwakeWhilePluggedIn =
        screenAwakeSettings.keepScreenOnWhileCharging;
    _screenTimeoutDuration = screenAwakeSettings.keepScreenOnAlways
        ? KeepScreenAwakeState.timeoutDisabled
        : KeepScreenAwakeState.timeoutUnknown;
    _init();
  }

  final GenericBloc genericBloc;
  late final StreamSubscription _batterySubscription;
  late bool _keepScreenAwakeWhilePluggedIn;

  bool _batteryCharging = false;
  Duration _screenTimeoutDuration = KeepScreenAwakeState.timeoutUnknown;

  _init() async {
    if (_screenTimeoutDuration.isNegative) {
      _screenTimeoutDuration = await SystemSettingsEditor.screenOffTimeout ??
          KeepScreenAwakeState.timeoutOneMinute;
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
      if (timeout.inMinutes > 1) {
        _screenTimeoutDuration = KeepScreenAwakeState.timeoutThirtyMinutes;
      } else if (timeout.inMinutes > 0) {
        _screenTimeoutDuration = KeepScreenAwakeState.timeoutOneMinute;
      } else {
        _screenTimeoutDuration = KeepScreenAwakeState.timeoutDisabled;
      }
      genericBloc.add(
        GenericUpdated(
          [
            MemoplannerSettingData.fromData(
              data: timeout.inMilliseconds == 0,
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

  @visibleForTesting
  onBatteryUpdated(BatteryCubitState state) {
    _batteryCharging = state.batteryState == BatteryState.charging ||
        state.batteryState == BatteryState.full;
  }

  _updateKeepScreenAwake() async {
    if (_screenTimeoutDuration == KeepScreenAwakeState.timeoutDisabled ||
        (_keepScreenAwakeWhilePluggedIn && _batteryCharging)) {
      SystemSettingsEditor.setScreenOffTimeout(const Duration(days: 400));
    } else {
      SystemSettingsEditor.setScreenOffTimeout(_screenTimeoutDuration);
    }
    emit(KeepScreenAwakeState(
        screenTimeout: _screenTimeoutDuration,
        screenOnWhileCharging: _keepScreenAwakeWhilePluggedIn));
  }
}

class KeepScreenAwakeState extends Equatable {
  final Duration screenTimeout;
  final bool screenOnWhileCharging;

  static const Duration timeoutUnknown = Duration(minutes: -1);
  static const Duration timeoutDisabled = Duration(milliseconds: 0);
  static const Duration timeoutOneMinute = Duration(minutes: 1);
  static const Duration timeoutThirtyMinutes = Duration(minutes: 30);

  const KeepScreenAwakeState(
      {required this.screenTimeout, required this.screenOnWhileCharging});

  @override
  List<Object?> get props => [screenTimeout, screenOnWhileCharging];
}
