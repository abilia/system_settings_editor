import 'package:seagull/config.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlDb {
  static const String _BASE_URL_RECORD = 'base-url';
  final SharedPreferences prefs;

  const BaseUrlDb(this.prefs);

  Future setBaseUrl(String baseUrl) =>
      prefs.setString(_BASE_URL_RECORD, baseUrl);

  String getBaseUrl() {
    try {
      return prefs.getString(_BASE_URL_RECORD);
    } catch (_) {
      return null;
    }
  }

  Future deleteBaseUrl() => prefs.remove(_BASE_URL_RECORD);

  Future<String> initialize() async {
    final defaultUrl = Config.beta ? WHALE : PROD;
    final currentUrl = getBaseUrl();
    if (currentUrl == null || Config.release && currentUrl != defaultUrl) {
      await setBaseUrl(defaultUrl);
      return defaultUrl;
    }
    return currentUrl;
  }
}
