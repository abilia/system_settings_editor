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

  Future<void> insert(Iterable<AbiliaTimer> timers) async {
    final batch = db.batch();

    timers
        .exceptionSafeMap(
          (timer) => timer.toMapForDb(),
          onException: _log.logAndReturnNull,
        )
        .whereNotNull()
        .forEach(
          (value) => batch.insert(
            DatabaseRepository.timerTableName,
            value,
            conflictAlgorithm: ConflictAlgorithm.replace,
          ),
        );

    batch.commit();
  }

  Future<int> delete(AbiliaTimer timer) async {
    return db.delete(DatabaseRepository.timerTableName,
        where: 'id = "${timer.id}"');
  }

  Future<List<AbiliaTimer>> getAllTimers() async {
    final result = await db.rawQuery(_getAll);
    return result
        .exceptionSafeMap(
          AbiliaTimer.fromDbMap,
          onException: _log.logAndReturnNull,
        )
        .whereNotNull()
        .toList();
  }
}
