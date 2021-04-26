import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDb {
  static final _log = Logger((SettingsDb).toString());
  static const String _LANGUAGE_RECORD = 'language',
      _ALWAYS_USE_24_RECORD = 'ALWAYS_USE_24',
      _TEXT_TO_SPEECH_RECORD = 'TEXT_TO_SPEECH',
      _CATEGORY_LEFT_EXPANDED = 'CATEGORY_LEFT_EXPANDED',
      _CATEGORY_RIGHT_EXPANDED = 'CATEGORY_RIGHT_EXPANDED';

  final SharedPreferences preferences;

  SettingsDb(this.preferences);

  Future setLanguage(String language) =>
      preferences.setString(_LANGUAGE_RECORD, language);

  String get language {
    try {
      return preferences.getString(_LANGUAGE_RECORD);
    } catch (_) {
      return null;
    }
  }

  Future setAlwaysUse24HourFormat(bool alwaysUse24HourFormat) =>
      preferences.setBool(_ALWAYS_USE_24_RECORD, alwaysUse24HourFormat);

  bool get alwaysUse24HourFormat => _tryGetBool(_ALWAYS_USE_24_RECORD, true);

  Future setTextToSpeech(bool textToSpeech) =>
      preferences.setBool(_TEXT_TO_SPEECH_RECORD, textToSpeech);

  bool get textToSpeech => _tryGetBool(_TEXT_TO_SPEECH_RECORD, true);

  Future setRightCategoryExpanded(bool expanded) =>
      preferences.setBool(_CATEGORY_RIGHT_EXPANDED, expanded);

  bool get rightCategoryExpanded => _tryGetBool(_CATEGORY_RIGHT_EXPANDED, true);

  Future setLeftCategoryExpanded(bool expanded) =>
      preferences.setBool(_CATEGORY_LEFT_EXPANDED, expanded);

  bool get leftCategoryExpanded => _tryGetBool(_CATEGORY_LEFT_EXPANDED, true);

  bool _tryGetBool(String key, bool fallback) {
    try {
      return preferences.getBool(key) ?? fallback;
    } catch (_) {
      _log.warning('Could not get $key settings. Defaults to $fallback.');
      return fallback;
    }
  }
}
