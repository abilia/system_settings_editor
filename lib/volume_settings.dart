import 'package:flutter/services.dart';

class VolumeSettings {
  static const MethodChannel _channel = MethodChannel('system_settings_editor');

  static Future<double?> get alarmVolume async {
    return await _channel.invokeMethod('getAlarmVolume');
  }

  static Future<double?> get mediaVolume async {
    return await _channel.invokeMethod('getMediaVolume');
  }

  static Future<int?> get alarmMaxVolume async {
    return await _channel.invokeMethod('getAlarmMaxVolume');
  }

  static Future<int?> get mediaMaxVolume async {
    return await _channel.invokeMethod('getMediaMaxVolume');
  }

  static Future<void> setAlarmVolume(double volume) async {
    await _channel.invokeMethod('setAlarmVolume', {'volume': volume});
  }

  static Future<void> setMediaVolume(double volume) async {
    await _channel.invokeMethod('setMediaVolume', {'volume': volume});
  }
}
