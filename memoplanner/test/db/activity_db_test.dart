import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:test/test.dart';

import 'package:timezone/timezone.dart' as tz;

void main() {
  late Database db;
  late ActivityDb activityDb;

  setUp(() async {
    tz.setLocalLocation(tz.UTC);
    db = await DatabaseRepository.createInMemoryFfiDb();
    activityDb = ActivityDb(db);
  });

  test('Test add activity', () async {
    final all = await activityDb.getAllNonDeleted();
    expect(all.length, 0);

    final a = Activity.createNew(title: 'Hey', startTime: DateTime(100));
    await activityDb.insert([a.wrapWithDbModel()]);

    final all2 = await activityDb.getAllNonDeleted();
    expect(all2.length, 1);
  });

  tearDown(() {
    DatabaseRepository.clearAll(db);
  });
}
