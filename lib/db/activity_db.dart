import 'package:logging/logging.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

class ActivityDb extends DataDb<Activity> {
  ActivityDb(Database database) : super(database);

  static const String allAfter =
      'SELECT * FROM ${DatabaseRepository.activityTableName} WHERE end_time >= ? AND deleted == 0';

  Future<Iterable<Activity>> getAllAfter(DateTime time) async {
    final result = await db.rawQuery(allAfter, [time.millisecondsSinceEpoch]);
    return rowsToModels(result);
  }

  @override
  String get tableName => DatabaseRepository.activityTableName;
  @override
  DbMapTo<Activity> get convertToDataModel => DbActivity.fromDbMap;

  final _log = Logger((ActivityDb).toString());
  @override
  Logger get log => _log;
}
