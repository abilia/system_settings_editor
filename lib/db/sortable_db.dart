import 'package:seagull/models/all.dart';
import 'package:seagull/db/all.dart';
import 'package:sqflite/sqflite.dart';

class SortableDb {
  static const SORTABLE_TABLE = 'sortable';
  static const GET_ALL_SORTABLES = "SELECT * FROM $SORTABLE_TABLE";
  static const String MAX_REVISION_SQL =
      'SELECT max(revision) as max_revision FROM $SORTABLE_TABLE';

  Future<Iterable<Sortable>> getSortables() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_ALL_SORTABLES);
    final sortables = result.map((row) {
      final dbS = DbSortable.fromDbMap(row);
      return dbS.sortable;
    });
    return sortables;
  }

  Future<List<int>> insertSortables(Iterable<DbSortable> sortables) async {
    final db = await DatabaseRepository().database;
    final insertResults = await sortables.map((sortable) async {
      return await db.insert('sortable', sortable.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return Future.wait(insertResults);
  }

  Future<int> getLastRevision() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(MAX_REVISION_SQL);
    final revision = result.first['max_revision'];
    if (revision == null) {
      return 0;
    }
    return revision;
  }
}
