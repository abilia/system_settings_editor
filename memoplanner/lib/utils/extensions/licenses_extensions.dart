import 'package:memoplanner/models/all.dart';

extension LicensesExtension on Iterable<License> {
  bool anyValidLicense(DateTime now) {
    return any((l) =>
        l.product.contains(memoplannerLicenseName) && l.endTime.isAfter(now));
  }

  bool anyMemoplannerLicense() {
    return any((l) => l.product.contains(memoplannerLicenseName));
  }
}
