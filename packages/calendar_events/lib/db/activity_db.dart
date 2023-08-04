import 'package:calendar_events/calendar_events.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';
import 'package:sqflite/sqflite.dart';

class ActivityDb extends DataDb<Activity> {
  ActivityDb(Database database) : super(database);

  static const String allAfter =
      'SELECT * FROM ${DatabaseRepository.activityTableName} WHERE end_time >= ? AND deleted == 0';

  static const String allBetween =
      'SELECT * FROM ${DatabaseRepository.activityTableName} WHERE end_time >= ? AND start_time <= ? AND deleted == 0';

  static const String getBySeriesId =
      'SELECT * FROM ${DatabaseRepository.activityTableName} WHERE series_id = ?';

  Future<Iterable<Activity>> getAllAfter(DateTime time) async {
    final result = await db.rawQuery(allAfter, [time.millisecondsSinceEpoch]);
    return rowsToModels(result);
  }

  Future<Iterable<Activity>> getAllBetween(DateTime start, DateTime end) async {
    final result = await db.rawQuery(
        allBetween, [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);
    return rowsToModels(result);
  }

  @override
  String get tableName => DatabaseRepository.activityTableName;
  @override
  DbMapTo<Activity> get convertToDataModel => DbActivity.fromDbMap;

  final _log = Logger((ActivityDb).toString());
  @override
  Logger get log => _log;

  Future<Iterable<Activity>> getBySeries(String seriesId) async {
    final result = await db.rawQuery(getBySeriesId, [seriesId]);
    return rowsToModels(result);
  }
}