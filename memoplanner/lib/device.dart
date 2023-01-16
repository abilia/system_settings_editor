import 'dart:io';

import 'package:meta/meta.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

import 'package:memoplanner/config.dart';

class Device {
  static bool _isLarge = false;

  static bool get isLarge => _isLarge;

  static Future<void> init() async {
    if (Config.isMP && Platform.isAndroid) {
      final hasBattery = await SystemSettingsEditor.hasBattery;
      isLarge = hasBattery == false;
    }
  }

  @visibleForTesting
  static set isLarge(bool isLarge) => _isLarge = isLarge;
}
