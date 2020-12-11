import 'package:seagull/models/all.dart';

extension LicensesExtension on Iterable<License> {
  bool anyValidLicense(DateTime now) {
    return any(
        (l) => l.product == MEMOPLANNER_LICENSE_NAME && l.endTime.isAfter(now));
  }
}
