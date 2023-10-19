import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';
import 'package:sortables/sortables.dart';

class SortableDb extends DataDb<Sortable> {
  SortableDb(super.database);

  @override
  String get tableName => DatabaseRepository.sortableTableName;
  @override
  DbMapTo<Sortable> get convertToDataModel => DbSortable.fromDbMap;

  final _log = Logger((SortableDb).toString());
  @override
  Logger get log => _log;
}
