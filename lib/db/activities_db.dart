import 'package:seagull/db/sqflite.dart';
import 'package:seagull/models/activity.dart';
import 'package:sqflite/sqflite.dart';

class ActivityDb {

  static const String MAX_REVISION_SQL =
      'SELECT max(revision) as max_revision FROM calendar_activity';
  static const String GET_ACTIVITIES_SQL = 'SELECT * FROM calendar_activity';

  Future<int> getLastRevision() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(MAX_REVISION_SQL);
    final revision = result.first['max_revision'];
    if (revision == null) {
      return 0;
    }
    return revision;
  }

  Future<List<Activity>> getActivitiesFromDb() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_ACTIVITIES_SQL);
    return result.map((row) => Activity.fromDbMap(row)).toList();
  }

  insertActivities(List<Activity> activities) async {
    final db = await DatabaseRepository().database;
    activities.forEach((activity) async {
      await db.insert('calendar_activity', activity.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

}
