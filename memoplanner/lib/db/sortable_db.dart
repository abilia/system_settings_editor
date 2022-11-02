import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/db/all.dart';

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
