import 'package:seagull/models/all.dart';

extension LicensesExtension on Iterable<License> {
  bool anyValidLicense(DateTime now) {
    return any((l) => l.product == 'memoplanner3' && l.endTime.isAfter(now));
  }
}
