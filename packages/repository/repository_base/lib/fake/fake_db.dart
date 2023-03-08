import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqlite_api.dart';

@visibleForTesting
class FakeDatabase extends Fake implements Database {
  @override
  Future<List<Map<String, Object?>>> rawQuery(String sql,
          [List<Object?>? arguments]) =>
      Future.value([]);
  @override
  Batch batch() => FakeBatch();

  @override
  Future<List<Map<String, Object?>>> query(String table,
          {bool? distinct,
          List<String>? columns,
          String? where,
          List<Object?>? whereArgs,
          String? groupBy,
          String? having,
          String? orderBy,
          int? limit,
          int? offset}) =>
      Future.value([]);

  @override
  Future<int> insert(String table, Map<String, Object?> values,
          {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) =>
      Future.value(values.length);
}

@visibleForTesting
class FakeBatch extends Fake implements Batch {
  @override
  Future<List<Object?>> commit(
          {bool? exclusive, bool? noResult, bool? continueOnError}) =>
      Future.value([]);
  @override
  void delete(String table, {String? where, List<Object?>? whereArgs}) {}
}
