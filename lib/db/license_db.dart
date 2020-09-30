import 'dart:convert';

import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseDb {
  final String _licenseKey = 'licenseKey';

  Future persistLicenses(List<License> licenses) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(licenses);
    await prefs.setString(_licenseKey, encoded);
  }

  Future<List<License>> getLicenses() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final licensesString = prefs.getString(_licenseKey);
      return (json.decode(licensesString) as List)
          .map((e) => License.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_licenseKey);
  }
}
