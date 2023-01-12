import 'package:system_settings_editor/system_settings_editor.dart';

class Config {
  static const dev = String.fromEnvironment('release') == 'dev';
  static const release = !dev;

  static const isMP = String.fromEnvironment('flavor') == 'mp';
  static const isMPGO = !isMP;
  static const flavor = isMP ? Flavor.mp : Flavor.mpgo;

  static late final bool isMPLarge;

  static Future<void> init() => _setIsMPLarge();

  static Future<void> _setIsMPLarge() async {
    if (isMP && await SystemSettingsEditor.hasBattery == false) {
      isMPLarge = true;
    } else {
      isMPLarge = false;
    }
  }
}

class Flavor {
  final String name, id;

  const Flavor._(this.name, this.id);

  static const mpgo = Flavor._('MEMOplanner Go', 'memoplannergo');
  static const mp = Flavor._('MEMOplanner', 'memoplanner');
}
