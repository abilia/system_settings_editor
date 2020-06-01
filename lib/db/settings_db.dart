import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDb {
  static final _log = Logger((SettingsDb).toString());
  static const String _LANGUAGE_RECORD = 'language';
  static const String _ALWAYS_USE_24_RECORD = 'ALWAYS_USE_24';
  static const String _DOTS_IN_TIMEPILLAR_RECORD = 'DOTS_IN_TIMEPILLAR';

  final SharedPreferences preferences;

  SettingsDb(this.preferences);

  Future setLanguage(String language) async {
    await preferences.setString(_LANGUAGE_RECORD, language);
  }

  String getLanguage() {
    try {
      return preferences.getString(_LANGUAGE_RECORD);
    } catch (_) {
      return null;
    }
  }

  Future setAlwaysUse24HourFormat(bool alwaysUse24HourFormat) async {
    await preferences.setBool(_ALWAYS_USE_24_RECORD, alwaysUse24HourFormat);
  }

  bool getAlwaysUse24HourFormat() {
    try {
      return preferences.getBool(_ALWAYS_USE_24_RECORD) ?? true;
    } catch (_) {
      _log.warning('Could not get 24 hour format. Defaults to true.');
      return true;
    }
  }

  Future setDotsInTimepillar(bool dotsInTimepillar) async {
    await preferences.setBool(_DOTS_IN_TIMEPILLAR_RECORD, dotsInTimepillar);
  }

  bool getDotsInTimepillar() {
    try {
      final dots = preferences.getBool(_DOTS_IN_TIMEPILLAR_RECORD);
      return dots ?? true;
    } catch (_) {
      _log.warning('Could not get dots in timepillar. Defaults to true.');
      return true;
    }
  }
}
