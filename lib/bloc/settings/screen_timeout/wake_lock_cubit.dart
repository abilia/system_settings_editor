import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/all.dart';

class WakeLockCubit extends Cubit<WakeLockState> {
  late final StreamSubscription _batterySubscription;
  late final StreamSubscription _memosettingsSubsription;

  WakeLockCubit({
    required Battery battery,
    required MemoplannerSettingBloc memoSettingsBloc,
    required Future<Duration?> screenTimeoutCallback,
  }) : super(WakeLockState(
          keepScreenAwakeSettings:
              memoSettingsBloc.state.settings.keepScreenAwakeSettings,
        )) {
    _batterySubscription = battery.onBatteryStateChanged.listen(
      (event) => emit(
        state.copyWith(
          batteryCharging:
              event == BatteryState.charging || event == BatteryState.full,
        ),
      ),
    );
    _memosettingsSubsription = memoSettingsBloc.stream.listen(
      (event) => emit(
        state.copyWith(
          keepScreenAwakeSettings: event.settings.keepScreenAwakeSettings,
        ),
      ),
    );
    _init(screenTimeoutCallback);
  }

  Future _init(Future<Duration?> screenTimeoutCallback) async =>
      setScreenTimeout(await screenTimeoutCallback);

  void setScreenTimeout(Duration? duration) =>
      emit(state.copyWith(systemScreenTimeout: duration));

  @override
  Future<void> close() async {
    await _batterySubscription.cancel();
    await _memosettingsSubsription.cancel();
    return super.close();
  }
}

class WakeLockState extends Equatable {
  final Duration systemScreenTimeout;
  final KeepScreenAwakeSettings keepScreenAwakeSettings;
  final bool batteryCharging;

  bool get alwaysOn =>
      systemScreenTimeout == Duration.zero ||
      keepScreenAwakeSettings.keepScreenOnAlways;
  bool get onNow =>
      alwaysOn ||
      keepScreenAwakeSettings.keepScreenOnWhileCharging && batteryCharging;
  Duration get screenTimeout => alwaysOn ? Duration.zero : systemScreenTimeout;

  const WakeLockState({
    required this.keepScreenAwakeSettings,
    this.systemScreenTimeout = const Duration(milliseconds: -1),
    this.batteryCharging = false,
  });

  WakeLockState copyWith({
    Duration? systemScreenTimeout,
    KeepScreenAwakeSettings? keepScreenAwakeSettings,
    bool? batteryCharging,
  }) =>
      WakeLockState(
        systemScreenTimeout: systemScreenTimeout ?? this.systemScreenTimeout,
        keepScreenAwakeSettings:
            keepScreenAwakeSettings ?? this.keepScreenAwakeSettings,
        batteryCharging: batteryCharging ?? this.batteryCharging,
      );

  @override
  List<Object?> get props => [
        systemScreenTimeout,
        keepScreenAwakeSettings,
        batteryCharging,
      ];
}
