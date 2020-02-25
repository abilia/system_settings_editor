import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:sqflite/sqflite.dart';

class ActivityDb {
  static const ACTIVITY_TABLE = 'calendar_activity';
  static const String MAX_REVISION_SQL =
      'SELECT max(revision) as max_revision FROM $ACTIVITY_TABLE';
  static const String GET_ACTIVITIES_SQL =
      'SELECT * FROM $ACTIVITY_TABLE WHERE deleted == 0';
  static const String GET_ALL_DIRTY =
      'SELECT * FROM $ACTIVITY_TABLE WHERE dirty > 0';

  Future<int> getLastRevision() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(MAX_REVISION_SQL);
    final revision = result.first['max_revision'];
    if (revision == null) {
      return 0;
    }
    return revision;
  }

  Future<Iterable<Activity>> getActivitiesFromDb() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_ACTIVITIES_SQL);
    return result.map((row) => Activity.fromDbMap(row));
  }

  Future<Iterable<Activity>> getDirtyActivitiesFromDb() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_ALL_DIRTY);
    return result.map((row) => Activity.fromDbMap(row));
  }

  Future<List<int>> insertDirtyActivities(Iterable<Activity> activities) async {
    final db = await DatabaseRepository().database;
    final insertResult = await activities.map((activity) async {
      List<Map> existingDirtyAndRevision = await db.query(ACTIVITY_TABLE,
          columns: ['dirty', 'revision'],
          where: 'id = ?',
          whereArgs: [activity.id]);
      final dirty = existingDirtyAndRevision.isEmpty ? 0 : existingDirtyAndRevision.first['dirty'];
      final revision = existingDirtyAndRevision.isEmpty ? 0 : existingDirtyAndRevision.first['revision'];
      return await db.insert('calendar_activity',
          activity.copyWith(dirty: dirty + 1, revision: revision).toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return await Future.wait(insertResult);
  }

  Future insertActivities(Iterable<Activity> activities) async {
    final db = await DatabaseRepository().database;
    await activities.forEach((activity) async {
      await db.insert('calendar_activity', activity.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}
