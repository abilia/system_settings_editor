import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/backend/all.dart';

class ActivityRepository extends Repository {
  final int userId;
  final ActivityDb activityDb;
  final ActivityApi activityApi;

  ActivityRepository({
    String baseUrl,
    @required BaseClient client,
    @required this.activityDb,
    @required this.activityApi,
    @required this.userId,
  }) : super(client, baseUrl);

  Future<Iterable<Activity>> loadActivities() async {
    try {
      final fetchedActivities = await _fetchActivities();
      await activityDb.insertActivities(fetchedActivities);
    } catch (e) {
      // Error when syncing activities. Probably offline.
      print('Error when syncing activities $e');
    }
    return activityDb.getActivitiesFromDb();
  }

  Future<Iterable<Activity>> _fetchActivities() async {
    final revision = await activityDb.getLastRevision();
    return activityApi.fetchActivities(revision, userId);
  }

  Future<Iterable<Activity>> saveActivities(
      Iterable<Activity> activities) async {
    await activityDb.insertDirtyActivities(activities);
    return activities;
  }
}
