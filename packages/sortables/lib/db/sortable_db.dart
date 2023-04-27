import 'package:logging/logging.dart';
import 'package:repository_base/db/database_repository.dart';
import 'package:sortables/db/data_db.dart';
import 'package:sortables/models/sortable/sortable.dart';
import 'package:sqflite/sqflite.dart';

class SortableDb extends DataDb<Sortable> {
  SortableDb(Database database) : super(database);

  @override
  String get tableName => DatabaseRepository.sortableTableName;
  @override
  DbMapTo<Sortable> get convertToDataModel => DbSortable.fromDbMap;

  final _log = Logger((SortableDb).toString());
  @override
  Logger get log => _log;
}
