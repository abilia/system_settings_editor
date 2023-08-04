import 'dart:async';

import 'package:collection/collection.dart';
import 'package:generics/generics.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';
import 'package:sqflite/sqflite.dart';

class GenericDb extends DataDb<Generic> {
  GenericDb(Database database) : super(database);

  Future<Iterable<Generic>> getAllNonDeletedMaxRevision() async {
    final result = await db.rawQuery(getAllNonDeletedSql);
    final genericDataModels = result.map(convertToDataModel);
    final groupByIdentifier = groupBy<DbModel<Generic>, String>(
        genericDataModels, (m) => m.model.data.identifier);
    final maxRevisionPerIdentifier = groupByIdentifier.values.map(
        (idList) => maxBy<DbModel<Generic>, int>(idList, (v) => v.revision));
    return maxRevisionPerIdentifier.whereNotNull().map((data) => data.model);
  }

  @override
  String get tableName => DatabaseRepository.genericTableName;
  @override
  DbMapTo<Generic> get convertToDataModel => DbGeneric.fromDbMap;

  final _log = Logger((GenericDb).toString());
  @override
  Logger get log => _log;
}