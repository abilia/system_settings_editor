import 'package:memoplanner/repository/end_point.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlDb {
  static const String _baseUrlRecord = 'base-url';
  final SharedPreferences prefs;

  const BaseUrlDb(this.prefs);

  Future setBaseUrl(String baseUrl) => prefs.setString(_baseUrlRecord, baseUrl);

  String get baseUrl => prefs.getString(_baseUrlRecord) ?? prod;
  String get environment => backendEnvironments[baseUrl] ?? prodName;

  Future<void> initialize() async =>
      prefs.containsKey(_baseUrlRecord) ? baseUrl : await setBaseUrl(prod);
}
