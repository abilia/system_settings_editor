import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/device.dart';

void main() {
  const MethodChannel systemSettingsChannel =
      MethodChannel('system_settings_editor');
  TestWidgetsFlutterBinding.ensureInitialized();
  var hasBatteryResponse = () => true;

  setUp(() {
    systemSettingsChannel.setMockMethodCallHandler(
        (MethodCall methodCall) async => hasBatteryResponse());
  });

  group('MPGO', () {
    group('Android', () {
      test('Device with battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        hasBatteryResponse = () => true;
        final device = await Device.init();
        expect(device.hasBattery, isTrue);
      });

      test('Device with no battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        hasBatteryResponse = () => false;
        final device = await Device.init();
        expect(device.hasBattery, isFalse);
      });
    });

    group('IOS', () {
      test('Device with battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        hasBatteryResponse = () => true;
        final device = await Device.init();
        expect(device.hasBattery, isTrue);
      });

      test('Device with no battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        hasBatteryResponse = () => false;
        final device = await Device.init();
        expect(device.hasBattery, isTrue);
      });
    });
  });
}
