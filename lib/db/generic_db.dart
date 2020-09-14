import 'package:seagull/models/all.dart';
import 'package:seagull/db/all.dart';

class GenericDb extends DataDb<Generic> {
  GenericDb(Database database) : super(database);

  @override
  String get tableName => DatabaseRepository.GENERIC_TABLE_NAME;
  @override
  DbMapTo<Generic> get convertToDataModel => DbGeneric.fromDbMap;
}
