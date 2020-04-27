import 'package:shared_preferences/shared_preferences.dart';

class LanguageDb {
  static const String _LANGUAGE_RECORD = 'language';

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
}
