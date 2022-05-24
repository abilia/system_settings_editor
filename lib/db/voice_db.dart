import 'package:seagull/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceDb {
  static final _log = Logger((VoiceDb).toString());
  static const String _speechRate = 'SPEECH_RATE',
      _speakEveryWord = 'SPEAK_EVERY_WORD',
      _voice = 'VOICE';

  final SharedPreferences preferences;

  final String applicationSupportDirectory;

  VoiceDb(this.preferences, this.applicationSupportDirectory);

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
