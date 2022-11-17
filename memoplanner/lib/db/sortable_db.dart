import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/db/all.dart';

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
