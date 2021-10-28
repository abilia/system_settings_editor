
import 'dart:async';

import 'package:flutter/services.dart';

class SystemSettingsEditor {
  static const MethodChannel _channel = MethodChannel('system_settings_editor');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
