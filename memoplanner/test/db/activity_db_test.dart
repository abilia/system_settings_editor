import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
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

  test('Test delete unsynced activity deleted', () async {
    final a = Activity.createNew(title: 'Hello', startTime: DateTime(1000));
    await activityDb.insertAndAddDirty([a]);
    final allDirtyAfter = await activityDb.getAllDirty();
    expect(allDirtyAfter, hasLength(1));
    await activityDb.insertAndAddDirty([a.copyWith(deleted: true)]);
    final allDirtyAfterDelete = await activityDb.getAllDirty();
    expect(allDirtyAfterDelete, isEmpty);
  });

  test('Test delete synced activity not deleted', () async {
    final a = Activity.createNew(title: 'Hi', startTime: DateTime(10000));
    await activityDb.insert([a.wrapWithDbModel()]);
    final dbActivity = await activityDb.getById(a.id);
    expect(dbActivity, isNotNull);
    final deletedActivity = dbActivity!.model.copyWith(deleted: true);
    await activityDb.insertAndAddDirty([deletedActivity]);
    final allDirtyAfterDelete = await activityDb.getAllDirty();
    expect(allDirtyAfterDelete, hasLength(1));
  });

  tearDown(() {
    DatabaseRepository.clearAll(db);
  });
}
