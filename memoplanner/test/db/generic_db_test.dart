import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:test/test.dart';

import '../test_helpers/verify_generic.dart';

void main() {
  late Database db;
  late GenericDb genericDb;

  setUp(() async {
    db = await DatabaseRepository.createInMemoryFfiDb();
    genericDb = GenericDb(db);
  });

  test('Several with same identifier should get last revision', () async {
    final all = await genericDb.getAllNonDeleted();
    expect(all.length, 0);

    final g1 =
        memoplannerSetting(true, ActivityViewSettings.displayDeleteButtonKey);
    final g2 =
        memoplannerSetting(false, ActivityViewSettings.displayDeleteButtonKey);
    await genericDb.insert([g1.wrapWithDbModel(revision: 1)]
        .whereType<DbModel<Generic<GenericData>>>());
    await genericDb.insert([g2.wrapWithDbModel(revision: 2)]
        .whereType<DbModel<Generic<GenericData>>>());

    final allSettings = await genericDb.getAllNonDeleted();
    expect(allSettings.length, 2);

    final unique = await genericDb.getAllNonDeletedMaxRevision();
    expect(unique.length, 1);
    expect(unique.first.data.identifier,
        ActivityViewSettings.displayDeleteButtonKey);
    final settings = MemoplannerSettings.fromSettingsMap(
      {for (var e in unique) e.data.key: e.data as MemoplannerSettingData},
    );
    expect(settings.activityView.displayDeleteButton, false);
  });

  tearDown(() {
    DatabaseRepository.clearAll(db);
  });
}
