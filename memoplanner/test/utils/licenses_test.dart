import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

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
        ].anyValidLicense(now),
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
        ].anyValidLicense(now),
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
        ].anyValidLicense(now),
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
        ].anyValidLicense(now),
        true);
  });
}
