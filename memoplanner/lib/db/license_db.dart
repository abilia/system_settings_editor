import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseDb {
  final String _licenseKey = 'licenseKey';
  final SharedPreferences prefs;

  const LicenseDb(this.prefs);

  Future persistLicenses(List<License> licenses) =>
      prefs.setString(_licenseKey, json.encode(licenses));

  List<License> getLicenses() {
    try {
      final licensesString = prefs.getString(_licenseKey);
      if (licensesString == null) throw 'licenses is null';
      return (json.decode(licensesString) as List)
          .map((e) => License.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future delete() => prefs.remove(_licenseKey);

  License? getMemoplannerLicense() => getLicenses().firstWhereOrNull(
      (license) => license.product.contains(memoplannerLicenseName));
}
