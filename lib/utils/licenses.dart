import 'package:seagull/models/all.dart';

extension LicensesExtension on Iterable<License> {
  bool anyValidLicense(DateTime now) {
    return any(
        (l) => l.product == memoplannerLicenseName && l.endTime.isAfter(now));
  }

  bool anyMemoplannerLicense() {
    return any((l) => l.product == memoplannerLicenseName);
  }
}
