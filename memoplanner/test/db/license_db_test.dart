import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/db/license_db.dart';
import 'package:memoplanner/models/all.dart';

import '../fakes/fake_shared_preferences.dart';

void main() {
  test('Persist and get licenses from store', () async {
    final db = LicenseDb(await FakeSharedPreferences.getInstance());
    final endTime = DateTime(2020, 12, 24, 15, 00);
    final license = License(
      id: 123,
      key: 'licenseKey',
      endTime: endTime,
      product: 'thaproduct',
    );
    await db.persistLicenses([license]);
    final fromDb = db.getLicenses();
    expect(fromDb, [license]);

    await db.delete();
    final deleted = db.getLicenses();
    expect(deleted, []);
  });
}
