import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:synchronized/extension.dart';

class ActivityRepository extends Repository {
  final int userId;
  final ActivityDb activityDb;
  final String authToken;

  ActivityRepository({
    String baseUrl,
    @required BaseClient client,
    @required this.activityDb,
    @required this.userId,
    @required this.authToken,
  }) : super(client, baseUrl);

  Future<void> save(Iterable<Activity> activities) =>
      activityDb.insertDirtyActivities(activities);

  Future<Iterable<Activity>> load() async {
    try {
      final fetchedActivities =
          await _fetchActivities(await activityDb.getLastRevision());
      await activityDb.insertActivities(fetchedActivities);
    } catch (e) {
      // Error when syncing activities. Probably offline.
      print('Error when syncing activities $e');
    }
    return activityDb.getActivitiesFromDb();
  }

  Future<bool> synchronize() async {
    return synchronized(() async {
      final dirtyActivities = await activityDb.getDirtyActivities();
      if (dirtyActivities.isNotEmpty) {
        try {
          final res = await postActivities(dirtyActivities);
          if (res.succeded.isNotEmpty) {
            // Update revision and dirty for all successful saves
            await _handleSuccessfullSync(res.succeded, dirtyActivities);
          }
          if (res.failed.isNotEmpty) {
            // If we have failed a fetch from backend needs to be performed
            await _handleFailedSync(res.failed);
          }
        } catch (e) {
          print('Failed to synchronize with backend $e');
          return false;
        }
      }
      return true;
    });
  }

  Future _handleSuccessfullSync(Iterable<DataRevisionUpdates> succeded,
      Iterable<Activity> dirtyActivities) async {
    final toUpdate = succeded.map((success) async {
      final activityBeforeSync =
          dirtyActivities.firstWhere((activity) => activity.id == success.id);
      final currentActivity = await activityDb.getActivityById(success.id);
      return currentActivity.copyWith(
          revision: success.revision,
          dirty: currentActivity.dirty - activityBeforeSync.dirty);
    });
    await activityDb.insertActivities(await Future.wait(toUpdate));
  }

  Future _handleFailedSync(Iterable<DataRevisionUpdates> failed) async {
    final minRevision = failed.map((f) => f.revision).reduce(min);
    final fetchedActivities = await _fetchActivities(minRevision);
    await activityDb.insertActivities(fetchedActivities);
  }

  Future<Iterable<Activity>> _fetchActivities(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/activities?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e));
  }

  @visibleForTesting
  Future<ActivityUpdateResponse> postActivities(
    Iterable<Activity> activities,
  ) async {
    final response = await httpClient.post(
      '$baseUrl/api/v1/data/$userId/activities',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(activities.toList()),
    );

    if (response.statusCode == 200) {
      final activityUpdateResponse =
          ActivityUpdateResponse.fromJson(json.decode(response.body));
      return activityUpdateResponse;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw UnavailableException();
  }
}
