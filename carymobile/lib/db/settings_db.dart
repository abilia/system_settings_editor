import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDb {
  static final _log = Logger((SettingsDb).toString());
  static const String productionGuideDoneRecord = 'cary_production_guide_done';

  final SharedPreferences preferences;

  SettingsDb(this.preferences);

  Future setProductionGuideDone() =>
      preferences.setBool(productionGuideDoneRecord, true);

  bool get productionGuideDone => _tryGetBool(productionGuideDoneRecord, false);

  bool _tryGetBool(String key, bool fallback) {
    try {
      return preferences.getBool(key) ?? fallback;
    } catch (_) {
      _log.warning('Could not get $key settings. Defaults to $fallback.');
      return fallback;
    }
  }
}
