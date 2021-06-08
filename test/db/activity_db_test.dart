// @dart=2.9

import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:test/test.dart';

void main() {
  Database db;
  ActivityDb activityDb;

  setUp(() async {
    db = await DatabaseRepository.createInMemoryFfiDb();
    activityDb = ActivityDb(db);
  });

  test('Test add activity', () async {
    final all = await activityDb.getAll();
    expect(all.length, 0);

    final a = Activity.createNew(title: 'Hey', startTime: DateTime.now());
    await activityDb.insert([a.wrapWithDbModel()]);

    final all2 = await activityDb.getAll();
    expect(all2.length, 1);
  });

  tearDown(() {
    DatabaseRepository.clearAll(db);
  });
}
