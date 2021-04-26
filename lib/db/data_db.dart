import 'package:seagull/logging.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

typedef DbMapTo<M extends DataModel> = DbModel<M> Function(
    Map<String, dynamic> map);

abstract class DataDb<M extends DataModel> {
  final Database db;
  String get tableName;
  DbMapTo<M> get convertToDataModel;
  Logger get log;

  DataDb(this.db);

  String get GET_ALL_DIRTY => 'SELECT * FROM $tableName WHERE dirty > 0';
  String get GET_BY_ID_SQL => 'SELECT * FROM $tableName WHERE id == ?';
  String get GET_ALL_SQL_NON_DELETED =>
      'SELECT * FROM $tableName WHERE deleted == 0';
  String get GET_ALL_SQL => 'SELECT * FROM $tableName';
  String get MAX_REVISION_SQL =>
      'SELECT max(revision) as max_revision FROM $tableName';

  Future insert(Iterable<DbModel<M>> dataModels) async {
    final batch = db.batch();

    dataModels
        .exceptionSafeMap(
          (dataModel) => dataModel.toMapForDb(),
          onException: log.logAndReturnNull,
        )
        .filterNull()
        .forEach(
          (value) => batch.insert(
            tableName,
            value,
            conflictAlgorithm: ConflictAlgorithm.replace,
          ),
        );

    return batch.commit();
  }

  Future<Iterable<DbModel<M>>> getAllDirty() async {
    final result = await db.rawQuery(GET_ALL_DIRTY);
    return result
        .exceptionSafeMap(
          convertToDataModel,
          onException: log.logAndReturnNull,
        )
        .filterNull();
  }

  Future<DbModel<M>> getById(String id) async {
    final result = await db.rawQuery(GET_BY_ID_SQL, [id]);
    final userFiles = result
        .exceptionSafeMap(
          convertToDataModel,
          onException: log.logAndReturnNull,
        )
        .filterNull();
    if (userFiles.length == 1) {
      return userFiles.first;
    } else {
      return null;
    }
  }

  Future<Iterable<M>> getAll() async {
    final result = await db.rawQuery(GET_ALL_SQL);
    return result
        .exceptionSafeMap(
          convertToDataModel,
          onException: log.logAndReturnNull,
        )
        .filterNull()
        .map((data) => data.model);
  }

  Future<Iterable<M>> getAllNonDeleted() async {
    final result = await db.rawQuery(GET_ALL_SQL_NON_DELETED);
    return result
        .exceptionSafeMap(
          convertToDataModel,
          onException: log.logAndReturnNull,
        )
        .filterNull()
        .map((data) => data.model);
  }

  Future<int> getLastRevision() async {
    final result = await db.rawQuery(MAX_REVISION_SQL);
    final revision = result == null
        ? null
        : result.isNotEmpty
            ? result.first['max_revision']
            : null;
    if (revision == null) {
      return 0;
    }
    return revision;
  }

  Future insertAndAddDirty(Iterable<M> data) async {
    final insertResult = data.map((model) async {
      List<Map> existingDirtyAndRevision = await db.query(tableName,
          columns: ['dirty', 'revision'],
          where: 'id = ?',
          whereArgs: [model.id]);
      final dirty = existingDirtyAndRevision.isEmpty
          ? 0
          : existingDirtyAndRevision.first['dirty'];
      final revision = existingDirtyAndRevision.isEmpty
          ? 0
          : existingDirtyAndRevision.first['revision'];
      return await db.insert(
          tableName,
          model
              .wrapWithDbModel(dirty: dirty + 1, revision: revision)
              .toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return await Future.wait(insertResult);
  }
}
