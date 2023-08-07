import 'package:auth/models/license.dart';

extension LicensesExtension on Iterable<License> {
  bool anyValidLicense(DateTime now) {
    return any((l) => l.endTime.isAfter(now));
  }
}
