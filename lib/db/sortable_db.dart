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
    return result.map(DbSortable.fromDbMap).map((s) => s.sortable);
  }

  Future<List<int>> insertSortables(Iterable<DbSortable> sortables) async {
    final db = await DatabaseRepository().database;
    final batch = db.batch();
    sortables.forEach((sortable) =>
      batch.insert('sortable', sortable.toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace)
    );
    return await batch.commit();
  }

  Future<int> getLastRevision() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(MAX_REVISION_SQL);
    return result.first['max_revision'] ?? 0;
  }
}
