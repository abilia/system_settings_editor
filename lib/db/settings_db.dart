import 'package:logging/logging.dart';
import 'package:seagull/i18n/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsDb {
  static final _log = Logger((SettingsDb).toString());
  static const String _languageRecord = 'language',
      _alwaysUse24Record = 'ALWAYS_USE_24',
      _textToSpeechRecord = 'TEXT_TO_SPEECH',
      _categoryLeftExpanded = 'CATEGORY_LEFT_EXPANDED',
      _categoryRightExpanded = 'CATEGORY_RIGHT_EXPANDED',
      _speechRate = 'SPEECH_RATE',
      _speakEveryWord = 'SPEAK_EVERY_WORD',
      _voice = 'VOICE';

  final SharedPreferences preferences;

  SettingsDb(this.preferences);

  Future setLanguage(String language) =>
      preferences.setString(_languageRecord, language);

  String get language {
    final lang = preferences.getString(_languageRecord);
    if (lang == null) {
      _log.warning('language is missing in db, falls back to default');
      return Locales.language.keys.first.toLanguageTag();
    }
    return lang;
  }

  Future setAlwaysUse24HourFormat(bool alwaysUse24HourFormat) =>
      preferences.setBool(_alwaysUse24Record, alwaysUse24HourFormat);

  bool get alwaysUse24HourFormat => _tryGetBool(_alwaysUse24Record, true);

  Future setTextToSpeech(bool textToSpeech) =>
      preferences.setBool(_textToSpeechRecord, textToSpeech);

  bool get textToSpeech => _tryGetBool(_textToSpeechRecord, true);

  Future setRightCategoryExpanded(bool expanded) =>
      preferences.setBool(_categoryRightExpanded, expanded);

  bool get rightCategoryExpanded => _tryGetBool(_categoryRightExpanded, true);

  Future setLeftCategoryExpanded(bool expanded) =>
      preferences.setBool(_categoryLeftExpanded, expanded);

  bool get leftCategoryExpanded => _tryGetBool(_categoryLeftExpanded, true);

  Future setSpeechRate(double speechRate) =>
      preferences.setDouble(_speechRate, speechRate);

  double get speechRate => _tryGetDouble(_speechRate, 100);

  Future setSpeakEveryWord(bool speakEveryWord) =>
      preferences.setBool(_speakEveryWord, speakEveryWord);

  bool get speakEveryWord => _tryGetBool(_speakEveryWord, false);

  Future setVoice(String voice) => preferences.setString(_voice, voice);

  String get voice => preferences.getString(_voice) ?? '';

  bool _tryGetBool(String key, bool fallback) {
    try {
      return preferences.getBool(key) ?? fallback;
    } catch (_) {
      _log.warning('Could not get $key settings. Defaults to $fallback.');
      return fallback;
    }
  }

  double _tryGetDouble(String key, double fallback) {
    try {
      return preferences.getDouble(key) ?? fallback;
    } catch (_) {
      _log.warning('Could not get $key settings. Defaults to $fallback.');
      return fallback;
    }
  }
}
