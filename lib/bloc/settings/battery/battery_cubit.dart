import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:seagull/bloc/all.dart';

class BatteryCubit extends Cubit<BatteryCubitState> {
  final Battery battery;
  late final StreamSubscription _batterySubscription;

  BatteryCubit({required this.battery}) : super(BatteryCubitState.initState) {
    _batterySubscription = battery.onBatteryStateChanged.listen((state) async {
      emit(BatteryCubitState(state, await battery.batteryLevel));
    });
    init();
  }

  init() async {
    emit(BatteryCubitState(BatteryState.unknown, await battery.batteryLevel));
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
