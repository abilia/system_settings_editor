import 'package:collection/collection.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/support_person.dart';
import 'package:seagull/utils/iterable.dart';
import 'package:seagull/utils/logger.dart';

class SupportPersonsDb {
  SupportPersonsDb(this.db);

  final Database db;

  String get tableName => DatabaseRepository.supportPersonTableName;

  static const _getAll = 'SELECT * FROM ${DatabaseRepository.timerTableName}';

  Future<Iterable<SupportPerson>> getAll() async {
    final result = await db.rawQuery(_getAll);
    return result
        .exceptionSafeMap(
          SupportPerson.fromDbMap,
          onException: _log.logAndReturnNull,
        )
        .whereNotNull();
  }

  Future<int> insert(SupportPerson supportPerson) => db.insert(
        DatabaseRepository.supportPersonTableName,
        supportPerson.toMapForDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

  Future<int> delete(SupportPerson supportPerson) => db.delete(
        DatabaseRepository.supportPersonTableName,
        where: 'id = "${supportPerson.id}"',
      );

  Future<int> deleteAll() => db.delete(
        DatabaseRepository.supportPersonTableName,
      );

  Logger get _log => Logger((SupportPersonsDb).toString());
}
