import 'package:collection/collection.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/iterable.dart';
import 'package:seagull/utils/logger.dart';

class TimerDb {
  final Database db;

  TimerDb(this.db);

  static const _getAll = 'SELECT * FROM ${DatabaseRepository.timerTableName}';
  final _log = Logger((TimerDb).toString());

  Future<void> insert(AbiliaTimer timer) => db.insert(
        DatabaseRepository.timerTableName,
        timer.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<int> delete(AbiliaTimer timer) => db.delete(
        DatabaseRepository.timerTableName,
        where: 'id = "${timer.id}"',
      );

  Future<int> update(AbiliaTimer timer) =>
      db.update(DatabaseRepository.timerTableName, timer.toMapForDb(),
          where: 'id = "${timer.id}"');

  Future<Iterable<AbiliaTimer>> getAllTimers() async {
    final result = await db.rawQuery(_getAll);
    return result
        .exceptionSafeMap(
          AbiliaTimer.fromDbMap,
          onException: _log.logAndReturnNull,
        )
        .whereNotNull();
  }
}
