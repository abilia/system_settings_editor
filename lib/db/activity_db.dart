import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

class ActivityDb extends DataDb<Activity> {
  @override
  String get tableName => 'calendar_activity';
  @override
  DbMapTo<Activity> get convertToDataModel => DbActivity.fromDbMap;
}
