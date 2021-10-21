import 'package:seagull/repository/end_point.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlDb {
  static const String _baseUrlRecord = 'base-url';
  final SharedPreferences prefs;

  const BaseUrlDb(this.prefs);

  Future setBaseUrl(String baseUrl) => prefs.setString(_baseUrlRecord, baseUrl);

  String getBaseUrl() => prefs.getString(_baseUrlRecord) ?? prod;

  Future deleteBaseUrl() => prefs.remove(_baseUrlRecord);

  Future<String> initialize() async => prefs.containsKey(_baseUrlRecord)
      ? getBaseUrl()
      : await setBaseUrl(prod).then((_) => prod);
}
