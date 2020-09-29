import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/db/license_db.dart';
import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Persist and get licenses from store', () async {
    SharedPreferences.setMockInitialValues({});
    final db = LicenseDb();
    final endTime = DateTime(2020, 12, 24, 15, 00);
    final license = License(endTime: endTime, id: 123, product: 'thaproduct');
    await db.persistLicenses([license]);
    final fromDb = await db.getLicenses();
    expect(fromDb, [license]);

    await db.delete();
    final deleted = await db.getLicenses();
    expect(deleted, []);
  });
}
