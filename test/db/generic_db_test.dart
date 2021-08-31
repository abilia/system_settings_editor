import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:test/test.dart';

void main() {
  late Database db;
  late GenericDb genericDb;

  setUp(() async {
    db = await DatabaseRepository.createInMemoryFfiDb();
    genericDb = GenericDb(db);
  });

  test('Several with same identifier should get last revision', () async {
    final all = await genericDb.getAll();
    expect(all.length, 0);

    final g1 =
        memoplannerSetting(true, MemoplannerSettings.displayDeleteButtonKey);
    final g2 =
        memoplannerSetting(false, MemoplannerSettings.displayDeleteButtonKey);
    await genericDb.insert([g1.wrapWithDbModel(revision: 1)]
        .whereType<DbModel<Generic<GenericData>>>());
    await genericDb.insert([g2.wrapWithDbModel(revision: 2)]
        .whereType<DbModel<Generic<GenericData>>>());

    final allSettings = await genericDb.getAllNonDeleted();
    expect(allSettings.length, 2);

    final unique = await genericDb.getAllNonDeletedMaxRevision();
    expect(unique.length, 1);
    expect(unique.first.data.identifier,
        MemoplannerSettings.displayDeleteButtonKey);
    final settings = MemoplannerSettings.fromSettingsMap(
      {for (var e in unique) e.data.key: e.data as MemoplannerSettingData},
    );
    expect(settings.displayDeleteButton, false);
  });

  tearDown(() {
    DatabaseRepository.clearAll(db);
  });
}

Generic<MemoplannerSettingData> memoplannerSetting(
    bool value, String identifier) {
  return Generic.createNew<MemoplannerSettingData>(
    data: MemoplannerSettingData.fromData(
      data: value,
      identifier: identifier,
    ),
  );
}
