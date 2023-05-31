// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/utils/all.dart';

class WakeLockCubit extends Cubit<WakeLockState> {
  late final StreamSubscription _batterySubscription;
  final SettingsDb settingsDb;
  WakeLockCubit({
    required Battery battery,
    required this.settingsDb,
    required bool hasBattery,
  }) : super(WakeLockState(
          keepScreenOnWhileCharging: settingsDb.keepScreenOnWhileCharging,
          hasBattery: hasBattery,
        )) {
    _batterySubscription = battery.onBatteryStateChanged.listen(
      (event) => emit(
        state.copyWith(
          batteryCharging:
              event == BatteryState.charging || event == BatteryState.full,
        ),
      ),
    );
  }

  void setScreenTimeout(Duration? duration) =>
      emit(state.copyWith(screenTimeout: duration));

  Future setKeepScreenOnWhileCharging(bool keepScreenOn) async {
    await settingsDb.setKeepScreenOnWhileCharging(keepScreenOn);
    emit(
      state.copyWith(
        keepScreenOnWhileCharging: settingsDb.keepScreenOnWhileCharging,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _batterySubscription.cancel();
    return super.close();
  }
}

class WakeLockState extends Equatable {
  final bool hasBattery;
  final Duration screenTimeout;
  final bool keepScreenOnWhileCharging, batteryCharging;

  bool get alwaysOn => !hasBattery || screenTimeout == maxScreenTimeoutDuration;
  bool get onNow => alwaysOn || keepScreenOnWhileCharging && batteryCharging;

  const WakeLockState({
    required this.hasBattery,
    this.keepScreenOnWhileCharging = false,
    this.screenTimeout = const Duration(milliseconds: -1),
    this.batteryCharging = false,
  });

  WakeLockState copyWith({
    Duration? screenTimeout,
    bool? keepScreenOnWhileCharging,
    bool? batteryCharging,
  }) =>
      WakeLockState(
        hasBattery: hasBattery,
        screenTimeout: screenTimeout ?? this.screenTimeout,
        keepScreenOnWhileCharging:
            keepScreenOnWhileCharging ?? this.keepScreenOnWhileCharging,
        batteryCharging: batteryCharging ?? this.batteryCharging,
      );

  @override
  List<Object?> get props => [
        screenTimeout,
        keepScreenOnWhileCharging,
        batteryCharging,
      ];
}
