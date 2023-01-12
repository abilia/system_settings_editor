import 'dart:async';

import 'package:flutter/services.dart';

class SystemSettingsEditor {
  static const MethodChannel _channel = MethodChannel('system_settings_editor');

  static Future<bool> get canWriteSettings async {
    return await _channel.invokeMethod('canWriteSettings');
  }

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

  static Future<void> setHapticFeedbackEnabled(bool on) async {
    await _channel.invokeMethod(
        'setHapticFeedbackEnabled', {'hapticFeedbackEnabled': on});
  }

  static Future<Duration?> get screenOffTimeout async {
    final r = await _channel.invokeMethod('getScreenOffTimeout');
    return Duration(milliseconds: r);
  }

  static Future<void> setScreenOffTimeout(Duration timout) async {
    await _channel.invokeMethod(
        'setScreenOffTimeout', {'timeout': timout.inMilliseconds});
  }

  static Future<bool?> get hasBattery async {
    return await _channel.invokeMethod('getHasBattery');
  }
}
