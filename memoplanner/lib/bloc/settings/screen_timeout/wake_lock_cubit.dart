import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/settings/all.dart';

class WakeLockCubit extends Cubit<WakeLockState> {
  late final StreamSubscription _batterySubscription;
  late final StreamSubscription _memosettingsSubsription;

  WakeLockCubit({
    required Battery battery,
    required MemoplannerSettingsBloc memoSettingsBloc,
    required Future<Duration?> screenTimeoutCallback,
  }) : super(WakeLockState(
          keepScreenAwakeSettings: memoSettingsBloc.state.keepScreenAwake,
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
          keepScreenAwakeSettings: event.keepScreenAwake,
        ),
      ),
    );
    _init(screenTimeoutCallback);
  }

  Future _init(Future<Duration?> screenTimeoutCallback) async =>
      setScreenTimeout(await screenTimeoutCallback);

  void setScreenTimeout(Duration? duration) =>
      emit(state.copyWith(screenTimeout: duration));

  @override
  Future<void> close() async {
    await _batterySubscription.cancel();
    await _memosettingsSubsription.cancel();
    return super.close();
  }
}

class WakeLockState extends Equatable {
  final Duration screenTimeout;
  final KeepScreenAwakeSettings keepScreenAwakeSettings;
  final bool batteryCharging;

  bool get alwaysOn => keepScreenAwakeSettings.keepScreenOnAlways;
  bool get onNow =>
      alwaysOn ||
      keepScreenAwakeSettings.keepScreenOnWhileCharging && batteryCharging;

  const WakeLockState({
    required this.keepScreenAwakeSettings,
    this.screenTimeout = const Duration(milliseconds: -1),
    this.batteryCharging = false,
  });

  WakeLockState copyWith({
    Duration? screenTimeout,
    KeepScreenAwakeSettings? keepScreenAwakeSettings,
    bool? batteryCharging,
  }) =>
      WakeLockState(
        screenTimeout: screenTimeout ?? this.screenTimeout,
        keepScreenAwakeSettings:
            keepScreenAwakeSettings ?? this.keepScreenAwakeSettings,
        batteryCharging: batteryCharging ?? this.batteryCharging,
      );

  @override
  List<Object?> get props => [
        screenTimeout,
        keepScreenAwakeSettings,
        batteryCharging,
      ];
}
