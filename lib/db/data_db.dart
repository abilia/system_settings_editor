import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

import 'all.dart';

abstract class DataDb<M extends DataModel> {
  Future insert(Iterable<DbModel<M>> dataModels);
  Future insertAndAddDirty(Iterable<M> data);
  Future<Iterable<DbModel<M>>> getAllDirty();
  Future<DbModel<M>> getById(String id);
  Future<Iterable<M>> getAllNonDeleted();
  Future<int> getLastRevision();

  Future<List<int>> insertWithDirtyAndRevision(
      Iterable<M> data, String table) async {
    final db = await DatabaseRepository().database;
    final insertResult = await data.map((model) async {
      List<Map> existingDirtyAndRevision = await db.query(table,
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
          table,
          model
              .wrapWithDbModel(dirty: dirty + 1, revision: revision)
              .toMapForDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
    return await Future.wait(insertResult);
  }
}

abstract class DataModel extends Equatable {
  final String id;

  const DataModel(this.id) : assert(id != null);
  DbModel wrapWithDbModel({int revision = 0, int dirty = 0});
}

abstract class DbModel<M extends DataModel> extends Equatable {
  final int dirty, revision;
  final M model;

  const DbModel({
    @required this.dirty,
    @required this.revision,
    @required this.model,
  })  : assert(dirty >= 0),
        assert(revision >= 0),
        assert(model != null);
  Map<String, dynamic> toMapForDb();
  Map<String, dynamic> toJson();
  DbModel<M> copyWith({
    int revision,
    int dirty,
  });
}

class DirtyAndRevision {
  final int dirty, revision;

  DirtyAndRevision({
    this.dirty,
    this.revision,
  });
}
