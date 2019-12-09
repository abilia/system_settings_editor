import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlDb {
  static const String _BASE_URL_RECORD = 'base-url';

  Future setBaseUrl(String baseUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_BASE_URL_RECORD, baseUrl);
  }

  Future<String> getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getString(_BASE_URL_RECORD);
    } catch (_) {
      return null;
    }
  }

  deleteBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_BASE_URL_RECORD);
  }

  Future<String> initialize(String defaultUrl) async {
    final currentUrl = await getBaseUrl();
    if (currentUrl == null) {
      await setBaseUrl(defaultUrl);
      return defaultUrl;
    }
    return currentUrl;
  }
}
