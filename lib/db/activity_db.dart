import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

class ActivityDb extends DataDb<Activity> {
  ActivityDb(Database database) : super(database);

  @override
  String get tableName => 'calendar_activity';
  @override
  DbMapTo<Activity> get convertToDataModel => DbActivity.fromDbMap;
}
