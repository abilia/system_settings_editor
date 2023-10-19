import 'package:calendar_events/calendar_events.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';

class ActivityRepository extends DataRepository<Activity> {
  ActivityRepository({
    required super.baseUrlDb,
    required super.client,
    required super.userId,
    required this.activityDb,
  }) : super(
          path: 'activities',
          postApiVersion: 3,
          db: activityDb,
          fromJsonToDataModel: DbActivity.fromJson,
          log: Logger((ActivityRepository).toString()),
        );

  final ActivityDb activityDb;

  Future<Iterable<Activity>> allAfter(DateTime time) {
    return activityDb.getAllAfter(time);
  }

  Future<Iterable<Activity>> allBetween(DateTime start, DateTime end) {
    return activityDb.getAllBetween(start, end);
  }

  Future<Activity?> getById(String id) async {
    return (await activityDb.getById(id))?.model;
  }

  Future<Iterable<Activity>> getBySeries(String seriesId) =>
      activityDb.getBySeries(seriesId);
}
