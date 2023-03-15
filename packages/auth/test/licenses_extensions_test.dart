import 'package:auth/licenses_extensions.dart';
import 'package:auth/models/license.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:utils/utils.dart';

void main() {
  final now = DateTime(2010, 1, 1, 12, 00);

  test('Valid license', () {
    expect(
        [
          License(
              id: 1,
              key: 'licenseKey',
              endTime: now.add(24.hours()),
              product: memoplannerLicenseName)
        ].anyValidLicense(now, LicenseType.memoplanner),
        true);
  });

  test('Expired license', () {
    expect(
        [
          License(
              id: 1,
              key: 'licenseKey',
              endTime: now.subtract(24.hours()),
              product: memoplannerLicenseName)
        ].anyValidLicense(now, LicenseType.memoplanner),
        false);
  });

  test('Other valid licenses but not memoplanner', () {
    expect(
        [
          License(
            id: 1,
            key: 'licenseKey',
            endTime: now.subtract(24.hours()),
            product: memoplannerLicenseName,
          ),
          License(
            id: 4,
            key: 'licenseKey',
            endTime: now.add(24.hours()),
            product: 'other-product',
          ),
        ].anyValidLicense(now, LicenseType.memoplanner),
        false);
  });

  test('Other invalid licenses but valid memoplanner license', () {
    expect(
        [
          License(
            id: 1,
            key: 'licenseKey',
            endTime: now.add(24.hours()),
            product: memoplannerLicenseName,
          ),
          License(
            id: 4,
            key: 'licenseKey',
            endTime: now.subtract(24.hours()),
            product: 'other-product',
          ),
        ].anyValidLicense(now, LicenseType.memoplanner),
        true);
  });
}