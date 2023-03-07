import 'package:auth/models/license.dart';

extension LicensesExtension on Iterable<License> {
  bool anyValidLicense(DateTime now, LicenseType license) {
    return any(
        (l) => l.product.contains(license.name) && l.endTime.isAfter(now));
  }

  bool anyLicense(LicenseType license) {
    return any((l) => l.product.contains(license.name));
  }
}
