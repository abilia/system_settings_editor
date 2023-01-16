import 'dart:io';

import 'package:meta/meta.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

import 'package:memoplanner/config.dart';

class Device {
  static bool _isMPLarge = false;

  static bool get isMPLarge => _isMPLarge;

  static Future<void> init() async {
    if (Config.isMP && Platform.isAndroid) {
      final hasBattery = await SystemSettingsEditor.hasBattery;
      isMPLarge = hasBattery == false;
    }
  }

  @visibleForTesting
  static set isMPLarge(bool isMPLarge) => _isMPLarge = isMPLarge;
}
