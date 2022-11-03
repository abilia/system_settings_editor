import 'package:memoplanner/db/database_repository.dart';
import 'package:memoplanner/models/all.dart';

import 'package:sqflite/sqflite.dart';

class CalendarDb {
  static const memoType = 'MEMOPLANNER';
  final Database db;
  const CalendarDb(this.db);

  Future<int> insert(Calendar calendar) => db.insert(
        DatabaseRepository.calendarTableName,
        calendar.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<String?> getCalendarId() async {
    final queryResult = await db.query(
      DatabaseRepository.calendarTableName,
      where: 'type = ?',
      orderBy: 'main',
      limit: 1,
      whereArgs: [memoType],
    );
    if (queryResult.isEmpty) return null;
    return Calendar.fromDbMap(queryResult.first).id;
  }
}
