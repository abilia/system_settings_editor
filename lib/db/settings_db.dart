import 'package:shared_preferences/shared_preferences.dart';

class SettingsDb {
  static const String _LANGUAGE_RECORD = 'language';
  static const String _ALWAYS_USE_24_RECORD = 'ALWAYS_USE_24';

  Future setLanguage(String language) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_LANGUAGE_RECORD, language);
  }

  Future<String> getLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getString(_LANGUAGE_RECORD);
    } catch (_) {
      return null;
    }
  }

  Future setAlwaysUse24HourFormat(bool alwaysUse24HourFormat) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ALWAYS_USE_24_RECORD, alwaysUse24HourFormat);
  }

  Future<bool> getAlwaysUse24HourFormat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getBool(_ALWAYS_USE_24_RECORD);
    } catch (_) {
      print('Could not get 24 hour format');
      return true;
    }
  }
}
