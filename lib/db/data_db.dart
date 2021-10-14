import 'package:seagull/logging.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:collection/collection.dart';

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

  String get getAllDirtySql => 'SELECT * FROM $tableName WHERE dirty > 0';
  String get getByIdSql => 'SELECT * FROM $tableName WHERE id == ?';
  String get getAllNonDeletedSql =>
      'SELECT * FROM $tableName WHERE deleted == 0';
  String get getAllSql => 'SELECT * FROM $tableName';
  String get maxRevisionSql =>
      'SELECT max(revision) as max_revision FROM $tableName';

  Future insert(Iterable<DbModel<M>> dataModels) async {
    final batch = db.batch();

    dataModels
        .exceptionSafeMap(
          (dataModel) => dataModel.toMapForDb(),
          onException: log.logAndReturnNull,
        )
        .whereNotNull()
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
    final result = await db.rawQuery(getAllDirtySql);
    return result
        .exceptionSafeMap(
          convertToDataModel,
          onException: log.logAndReturnNull,
        )
        .whereNotNull();
  }

  Future<DbModel<M>?> getById(String id) async {
    final result = await db.rawQuery(getByIdSql, [id]);
    final userFiles = result
        .exceptionSafeMap(
          convertToDataModel,
          onException: log.logAndReturnNull,
        )
        .whereNotNull();
    if (userFiles.length == 1) {
      return userFiles.first;
    } else {
      return null;
    }
  }

  Future<Iterable<M>> getAll() async {
    final result = await db.rawQuery(getAllSql);
    return result
        .exceptionSafeMap(
          convertToDataModel,
          onException: log.logAndReturnNull,
        )
        .whereNotNull()
        .map((data) => data.model);
  }

  Future<Iterable<M>> getAllNonDeleted() async {
    final result = await db.rawQuery(getAllNonDeletedSql);
    return result
        .exceptionSafeMap(
          convertToDataModel,
          onException: log.logAndReturnNull,
        )
        .whereNotNull()
        .map((data) => data.model);
  }

  Future<int> getLastRevision() async {
    final result = await db.rawQuery(maxRevisionSql);
    return (result.firstOrNull?['max_revision'] ?? 0) as int;
  }

  /// Returns true if any dirty data added to the database and needs sync
  Future<bool> insertAndAddDirty(Iterable<M> data) async {
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
    final res = await Future.wait(insertResult);
    return res.isNotEmpty;
  }
}
