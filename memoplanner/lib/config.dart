import 'package:system_settings_editor/system_settings_editor.dart';

class Config {
  static const dev = String.fromEnvironment('release') == 'dev';
  static const release = !dev;

  static const isMP = String.fromEnvironment('flavor') == 'mp';
  static const isMPGO = !isMP;
  static const flavor = isMP ? Flavor.mp : Flavor.mpgo;

  static bool get isMPLarge => isMP && Device.isLarge;
}

class Flavor {
  final String name, id;

  const Flavor._(this.name, this.id);

  static const mpgo = Flavor._('MEMOplanner Go', 'memoplannergo');
  static const mp = Flavor._('MEMOplanner', 'memoplanner');
}

class Device {
  static late final bool isLarge;

  static Future<void> init() => _setIsLarge();

  static Future<void> _setIsLarge() async {
    if (Config.isMP && await SystemSettingsEditor.hasBattery == false) {
      isLarge = true;
    } else {
      isLarge = false;
    }
  }
}
