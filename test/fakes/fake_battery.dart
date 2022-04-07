import 'package:battery_plus/battery_plus.dart';

import '../mocks/mocks.dart';

class FakeBattery extends Fake implements Battery {
  static FakeBattery? _singleton;

  @override
  FakeBattery._();

  @override
  factory FakeBattery() {
    _singleton ??= FakeBattery._();
    return _singleton!;
  }

  @override
  Future<int> get batteryLevel => Future.value(100);

  @override
  Future<bool> get isInBatterySaveMode => Future.value(false);

  @override
  Future<BatteryState> get batteryState =>
      Future.value(BatteryState.discharging);

  @override
  Stream<BatteryState> get onBatteryStateChanged => const Stream.empty();
}
