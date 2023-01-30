import 'package:flutter/foundation.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class Device {
  const Device({this.hasBattery = true});

  final bool hasBattery;

  static Future<Device> init() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final hasBattery = await SystemSettingsEditor.hasBattery != false;
      return Device(hasBattery: hasBattery);
    }
    return const Device();
  }
}
