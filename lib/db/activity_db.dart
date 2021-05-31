// @dart=2.9

import 'package:logging/src/logger.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

class ActivityDb extends DataDb<Activity> {
  ActivityDb(Database database) : super(database);

  @override
  String get tableName => DatabaseRepository.CALENDAR_TABLE_NAME;
  @override
  DbMapTo<Activity> get convertToDataModel => DbActivity.fromDbMap;

  final _log = Logger((ActivityDb).toString());
  @override
  Logger get log => _log;
}
