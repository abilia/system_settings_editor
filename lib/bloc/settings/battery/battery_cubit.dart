import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:seagull/bloc/all.dart';

class BatteryCubit extends Cubit<int> {
  final _battery = Battery();
  late final StreamSubscription _batterySubscription;
  BatteryCubit() : super(-1) {
    _batterySubscription = _battery.onBatteryStateChanged.listen((event) async {
      emit(await _battery.batteryLevel);
    });
    init();
  }

  init() async {
    emit(await _battery.batteryLevel);
  }

  @override
  Future<void> close() async {
    await _batterySubscription.cancel();
    return super.close();
  }
}
