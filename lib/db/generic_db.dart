import 'package:collection/collection.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/db/all.dart';

class GenericDb extends DataDb<Generic> {
  GenericDb(Database database) : super(database);

  Future<Iterable<Generic>> getAllNonDeletedMaxRevision() async {
    final result = await db.rawQuery(GET_ALL_SQL_NON_DELETED);
    final genericDataModels = result.map(convertToDataModel);
    final groupByIdentifier = groupBy<DbModel<Generic>, String>(
        genericDataModels, (m) => m.model.data.identifier);
    final maxRevisionPerIdentifier = groupByIdentifier.values.map<DbModel<Generic>>(
        (idList) => maxBy<DbModel<Generic>, int>(idList, (v) => v.revision));
    return maxRevisionPerIdentifier.map((data) => data.model);
  }

  @override
  String get tableName => DatabaseRepository.GENERIC_TABLE_NAME;
  @override
  DbMapTo<Generic> get convertToDataModel => DbGeneric.fromDbMap;
}
