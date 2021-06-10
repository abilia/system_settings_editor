import 'package:seagull/repository/end_point.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlDb {
  static const String _BASE_URL_RECORD = 'base-url';
  final SharedPreferences prefs;

  const BaseUrlDb(this.prefs);

  Future setBaseUrl(String baseUrl) =>
      prefs.setString(_BASE_URL_RECORD, baseUrl);

  String getBaseUrl() => prefs.getString(_BASE_URL_RECORD) ?? PROD;

  Future deleteBaseUrl() => prefs.remove(_BASE_URL_RECORD);

  Future<String> initialize() async => prefs.containsKey(_BASE_URL_RECORD)
      ? getBaseUrl()
      : await setBaseUrl(PROD).then((_) => PROD);
}
