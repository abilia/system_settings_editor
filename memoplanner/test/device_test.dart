import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/device.dart';

void main() {
  const MethodChannel systemSettingsChannel =
      MethodChannel('system_settings_editor');
  TestWidgetsFlutterBinding.ensureInitialized();
  var hasBatteryResponse = () => true;

  setUp(() {
    systemSettingsChannel.setMockMethodCallHandler(
        (MethodCall methodCall) async => hasBatteryResponse());
  });

  tearDown(() {
    Device.isMPLarge = false;
  });

  group('MPGO', () {
    group('Android', () {
      test('Device with battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        hasBatteryResponse = () => true;
        await Device.init();
        expect(Device.isMPLarge, isFalse);
      });

      test('Device with no battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        hasBatteryResponse = () => false;
        await Device.init();
        expect(Device.isMPLarge, isFalse);
      });
    });

    group('IOS', () {
      test('Device with battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        hasBatteryResponse = () => true;
        await Device.init();
        expect(Device.isMPLarge, isFalse);
      });

      test('Device with no battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        hasBatteryResponse = () => false;
        await Device.init();
        expect(Device.isMPLarge, isFalse);
      });
    });
  }, skip: Config.isMP);

  group('MP', () {
    group('Android', () {
      test('Device with battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        hasBatteryResponse = () => true;
        await Device.init();
        expect(Device.isMPLarge, isFalse);
      });

      test('Device with no battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        hasBatteryResponse = () => false;
        await Device.init();
        expect(Device.isMPLarge, isTrue);
      });
    });

    group('IOS', () {
      test('Device with battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        hasBatteryResponse = () => true;
        await Device.init();
        expect(Device.isMPLarge, isFalse);
      });

      test('Device with no battery', () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        hasBatteryResponse = () => false;
        await Device.init();
        expect(Device.isMPLarge, isFalse);
      });
    });
  }, skip: Config.isMPGO);
}
