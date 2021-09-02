import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

void main() {
  final now = DateTime(2010, 1, 1, 12, 00);

  test('Valid license', () {
    expect(
        [
          License(
              id: 1,
              endTime: now.add(24.hours()),
              product: MEMOPLANNER_LICENSE_NAME)
        ].anyValidLicense(now),
        true);
  });

  test('Expired license', () {
    expect(
        [
          License(
              id: 1,
              endTime: now.subtract(24.hours()),
              product: MEMOPLANNER_LICENSE_NAME)
        ].anyValidLicense(now),
        false);
  });

  test('Other valid licenses but not memoplanner', () {
    expect(
        [
          License(
            id: 1,
            endTime: now.subtract(24.hours()),
            product: MEMOPLANNER_LICENSE_NAME,
          ),
          License(
            id: 4,
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
            endTime: now.add(24.hours()),
            product: MEMOPLANNER_LICENSE_NAME,
          ),
          License(
            id: 4,
            endTime: now.subtract(24.hours()),
            product: 'other-product',
          ),
        ].anyValidLicense(now),
        true);
  });
}
