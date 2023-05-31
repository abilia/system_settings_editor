import 'package:flutter_test/flutter_test.dart';
import 'package:generics/generics.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_fakes/all.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  late Database db;
  late GenericDb genericDb;

  setUp(() async {
    db = await DatabaseRepository.createInMemoryFfiDb();
    genericDb = GenericDb(db);
  });

  test('Several with same identifier should get last revision', () async {
    final all = await genericDb.getAllNonDeleted();
    const key = 'KeY';
    expect(all.length, 0);

    final g1 = genericSetting(true, key);
    final g2 = genericSetting(false, key);
    await genericDb.insert([g1.wrapWithDbModel(revision: 1)]
        .whereType<DbModel<Generic<GenericData>>>());
    await genericDb.insert([g2.wrapWithDbModel(revision: 2)]
        .whereType<DbModel<Generic<GenericData>>>());

    final allSettings = await genericDb.getAllNonDeleted();
    expect(allSettings.length, 2);

    final unique = await genericDb.getAllNonDeletedMaxRevision();
    expect(unique.length, 1);
    expect(unique.first.data.identifier, key);
    expect((unique.first.data as GenericSettingData).data, isFalse);
  });

  tearDown(() async {
    await DatabaseRepository.clearAll(db);
  });
}
