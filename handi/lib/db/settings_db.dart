import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDb {
  static final _log = Logger((SettingsDb).toString());
  static const String _ttsSettingsRecord = 'settings_tts';

  final SharedPreferences preferences;

  SettingsDb(this.preferences);

  Future setTts(bool alwaysUse24HourFormat) =>
      preferences.setBool(_ttsSettingsRecord, alwaysUse24HourFormat);

  bool get tts => _tryGetBool(_ttsSettingsRecord, false);

  bool _tryGetBool(String key, bool fallback) {
    try {
      return preferences.getBool(key) ?? fallback;
    } catch (_) {
      _log.warning('Could not get $key settings. Defaults to $fallback.');
      return fallback;
    }
  }
}
