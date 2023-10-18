import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/models/data_models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:utils/utils.dart';

typedef DbMapTo<M extends DataModel> = DbModel<M> Function(
    Map<String, dynamic> map);

abstract class DataDb<M extends DataModel> {
  final Database db;
  String get tableName;
  DbMapTo<M> get convertToDataModel;
  Logger get log;

  DataDb(this.db);

  String get getAllDirtySql => 'SELECT * FROM $tableName WHERE dirty > 0';
  String get countAllDirtySql =>
      'SELECT COUNT(*) FROM $tableName WHERE dirty > 0';
  String get getByIdSql => 'SELECT * FROM $tableName WHERE id == ?';
  String get getAllNonDeletedSql =>
      'SELECT * FROM $tableName WHERE deleted == 0';
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
    return rowsToDbModels(result);
  }

  Future<int> countAllDirty() async =>
      Sqflite.firstIntValue(await db.rawQuery(countAllDirtySql)) ?? 0;

  Future<DbModel<M>?> getById(String id) async {
    final result = await db.rawQuery(getByIdSql, [id]);
    final userFiles = rowsToDbModels(result);
    if (userFiles.length == 1) {
      return userFiles.first;
    } else {
      return null;
    }
  }

  Future<Iterable<M>> getAllNonDeleted() async {
    final result = await db.rawQuery(getAllNonDeletedSql);
    return rowsToModels(result);
  }

  Future<int> getLastRevision() async {
    final result = await db.rawQuery(maxRevisionSql);
    return (result.firstOrNull?['max_revision'] ?? 0) as int;
  }

  /// Returns true if any dirty data added to the database and needs sync
  Future<bool> insertAndAddDirty(Iterable<M> data) async {
    final insertResult = data.map(
      (model) async {
        final List<Map> existingDirtyAndRevision = await db.query(tableName,
            columns: ['dirty', 'revision'],
            where: 'id = ?',
            whereArgs: [model.id]);
        final dirty = existingDirtyAndRevision.isEmpty
            ? 0
            : existingDirtyAndRevision.first['dirty'];
        final revision = existingDirtyAndRevision.isEmpty
            ? 0
            : existingDirtyAndRevision.first['revision'];

        // No need to store deleted unsynced data
        if (model.deleted && revision == 0 && dirty > 0) {
          return db.delete(
            tableName,
            where: 'id = ?',
            whereArgs: [model.id],
          );
        }
        return await db.insert(
          tableName,
          model
              .wrapWithDbModel(dirty: dirty + 1, revision: revision)
              .toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      },
    );
    final res = await Future.wait(insertResult);
    return res.isNotEmpty;
  }

  Iterable<DbModel<M>> rowsToDbModels(List<Map<String, Object?>> rows) => rows
      .exceptionSafeMap(convertToDataModel, onException: log.logAndReturnNull)
      .whereNotNull();

  Iterable<M> rowsToModels(List<Map<String, Object?>> rows) =>
      rowsToDbModels(rows).map((data) => data.model);
}