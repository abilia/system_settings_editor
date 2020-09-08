import 'dart:convert';

import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseDb {
  static const String _LICENSE_RECORD = 'license';

  Future insertLicenses(List<License> licenses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _LICENSE_RECORD, json.encode(licenses.map((l) => l.toJson()).toList()));
  }

  Future<List<License>> getLicenses() async {
    final prefs = await SharedPreferences.getInstance();
    final licensesString = prefs.getString(_LICENSE_RECORD);
    return licensesString == null
        ? List<License>.empty()
        : (json.decode(licensesString) as List)
            .map((l) => License.fromJson(l))
            .toList();
  }

  Future deleteLicenses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_LICENSE_RECORD);
  }
}
