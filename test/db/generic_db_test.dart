import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:test/test.dart';

void main() {
  Database db;
  GenericDb genericDb;

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
    await genericDb.insert([g1.wrapWithDbModel(revision: 1)]);
    await genericDb.insert([g2.wrapWithDbModel(revision: 2)]);

    final allSettings = await genericDb.getAllNonDeleted();
    expect(allSettings.length, 2);

    final unique = await genericDb.getAllNonDeletedMaxRevision();
    expect(unique.length, 1);
    expect(unique.first.data.identifier,
        MemoplannerSettings.displayDeleteButtonKey);
    final settings = MemoplannerSettings.fromSettingsList(
        unique.map((e) => e.data as MemoplannerSettingData).toList());
    expect(settings.displayDeleteButton, false);
  });

  tearDown(() {
    DatabaseRepository.clearAll(db);
  });
}

Generic<MemoplannerSettingData> memoplannerSetting(
    bool value, String identifier) {
  return Generic.createNew<MemoplannerSettingData>(
    data: MemoplannerSettingData(
      data: value.toString(),
      type: 'Boolean',
      identifier: identifier,
    ),
    type: GenericType.memoPlannerSettings,
  );
}
