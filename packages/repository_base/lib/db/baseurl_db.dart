import 'package:repository_base/end_point.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlDb {
  static const String baseUrlRecord = 'base-url';
  final SharedPreferences prefs;

  const BaseUrlDb(this.prefs);

  Future setBaseUrl(String baseUrl) => prefs.setString(baseUrlRecord, baseUrl);

  String get baseUrl => prefs.getString(baseUrlRecord) ?? prod;
  String get environment => backendName(baseUrl);
  String get environmentOrTest => backendName(baseUrl, testName);
}
