import 'package:seagull/models/all.dart';
import 'package:seagull/db/all.dart';

class SortableDb extends DataDb<Sortable> {
  SortableDb(Database database) : super(database);

  @override
  String get tableName => DatabaseRepository.SORTABLE_TABLE_NAME;
  @override
  DbMapTo<Sortable> get convertToDataModel => DbSortable.fromDbMap;
}
