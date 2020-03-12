import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:sqflite/sqflite.dart';

class ActivityDb extends DataDb<Activity> {
  static const ACTIVITY_TABLE = 'calendar_activity';
  static const String MAX_REVISION_SQL =
      'SELECT max(revision) as max_revision FROM $ACTIVITY_TABLE';
  static const String GET_ACTIVITIES_SQL =
      'SELECT * FROM $ACTIVITY_TABLE WHERE deleted == 0';
  static const String GET_ACTIVITIES_BY_ID_SQL =
      'SELECT * FROM $ACTIVITY_TABLE WHERE id == ?';
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

  Future<Iterable<Activity>> getAllNonDeleted() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_ACTIVITIES_SQL);
    return result.map((row) => DbActivity.fromDbMap(row).activity);
  }

  Future<DbModel<Activity>> getById(String id) async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_ACTIVITIES_BY_ID_SQL, [id]);
    final activities = result.map((row) => DbActivity.fromDbMap(row));
    if (activities.length == 1) {
      return activities.first;
    } else {
      return null;
    }
  }

  Future<Iterable<DbModel<Activity>>> getAllDirty() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_ALL_DIRTY);
    return result.map((row) => DbActivity.fromDbMap(row));
  }

  Future<List<int>> insertAndAddDirty(Iterable<Activity> activities) async {
    return insertWithDirtyAndRevision(activities, ACTIVITY_TABLE);
  }

  Future<Iterable<int>> insert(Iterable<DbModel<Activity>> activities) async {
    final db = await DatabaseRepository().database;
    final insertResults = await activities.map((activity) async {
      return await db.insert('calendar_activity', activity.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return Future.wait(insertResults);
  }
}
