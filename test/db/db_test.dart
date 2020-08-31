import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:test/test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  ft.TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test('Test add activity', () async {
    var o = OpenDatabaseOptions(
      version: DatabaseRepository.migrations.length + 1,
      onCreate: DatabaseRepository.executeInitialization,
      onUpgrade: DatabaseRepository.executeMigration,
    );

    var db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: o,
    );

    final activityDb = ActivityDb(db);
    final all = await activityDb.getAll();
    expect(all.length, 0);

    final a = Activity.createNew(title: 'Hey', startTime: DateTime.now());
    await activityDb.insert([a.wrapWithDbModel()]);

    final all2 = await activityDb.getAll();
    expect(all2.length, 1);
  });
}
