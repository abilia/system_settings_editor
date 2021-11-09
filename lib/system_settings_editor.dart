import 'dart:async';

import 'package:flutter/services.dart';

class SystemSettingsEditor {
  static const MethodChannel _channel = MethodChannel('system_settings_editor');

  static Future<double?> get brightness async {
    return await _channel.invokeMethod('getBrightness');
  }

  static Future<void> setBrightness(double brightness) async {
    await _channel.invokeMethod('setBrightness', {'brightness': brightness});
  }

  static Future<bool?> get soundEffectsEnabled async {
    return await _channel.invokeMethod('getSoundEffectsEnabled');
  }

  static Future<void> setSoundEffectsEnabled(bool on) async {
    await _channel
        .invokeMethod('setSoundEffectsEnabled', {'soundEffectsEnabled': on});
  }
}
