import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:seagull/bloc/all.dart';

class BatteryCubit extends Cubit<int> {
  final battery = Battery();
  late final StreamSubscription batterySubscription;
  BatteryCubit() : super(-1) {
    batterySubscription = battery.onBatteryStateChanged.listen((event) async {
      emit(await battery.batteryLevel);
    });
    init();
  }

  init() async {
    emit(await battery.batteryLevel);
  }

  @override
  Future<void> close() async {
    await batterySubscription.cancel();
    return super.close();
  }
}
