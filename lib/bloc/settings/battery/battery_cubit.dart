import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';

class BatteryCubit extends Cubit<BatteryCubitState> {
  final _battery = Battery();
  late final StreamSubscription _batterySubscription;

  BatteryCubit() : super(BatteryCubitState.initState) {
    _batterySubscription = _battery.onBatteryStateChanged.listen((state) async {
      emit(BatteryCubitState(state, await _battery.batteryLevel));
    });
    init();
  }

  init() async {
    emit(BatteryCubitState(BatteryState.unknown, await _battery.batteryLevel));
  }

  @override
  Future<void> close() async {
    await _batterySubscription.cancel();
    return super.close();
  }
}

class BatteryCubitState extends Equatable {
  const BatteryCubitState(this.batteryState, this.batteryLevel);

  static const initState = BatteryCubitState(BatteryState.unknown, -1);

  final int batteryLevel;
  final BatteryState batteryState;

  @override
  List<Object?> get props => [batteryState, batteryLevel];
}
