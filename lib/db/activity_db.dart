import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

class ActivityDb extends DataDb<Activity> {
  ActivityDb(Database database) : super(database);

  @override
  String get tableName => DatabaseRepository.CALENDAR_TABLE_NAME;
  @override
  DbMapTo<Activity> get convertToDataModel => DbActivity.fromDbMap;
}
