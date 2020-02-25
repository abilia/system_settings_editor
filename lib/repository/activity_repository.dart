import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

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

  // Local database access

  Future<Iterable<Activity>> saveActivities(
      Iterable<Activity> activities) async {
    await activityDb.insertDirtyActivities(activities);
    return activities;
  }

  Future<Iterable<Activity>> getDirtyActivities() async {
    return activityDb.getDirtyActivities();
  }

  Future insertActivities(Iterable<Activity> activities) async {
    return activityDb.insertActivities(activities);
  }

  // Backend access

  Future<ActivityUpdateResponse> postActivities(
    List<Activity> activities,
  ) async {
    final response = await httpClient.post(
      '$baseUrl/api/v1/data/$userId/activities',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(activities),
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

  Future<Iterable<Activity>> fetchActivities(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/activities?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e));
  }

  // Synchronize

  Future<Iterable<Activity>> loadNewActivitiesFromBackend() async {
    try {
      final fetchedActivities = await _fetchActivitiesFromLatestRevision();
      await activityDb.insertActivities(fetchedActivities);
    } catch (e) {
      // Error when syncing activities. Probably offline.
      print('Error when syncing activities $e');
    }
    return activityDb.getActivitiesFromDb();
  }

  Future<void> loadActivitiesFromRevision(int revision) async {
    try {
      final fetchedActivities = await fetchActivities(revision);
      await activityDb.insertActivities(fetchedActivities);
    } catch (e) {
      // Error when syncing activities. Probably offline.
      print('Error when syncing activities $e');
    }
  }

  Future<Iterable<Activity>> _fetchActivitiesFromLatestRevision() async {
    final revision = await activityDb.getLastRevision();
    return fetchActivities(revision);
  }

  Future<bool> synchronizeLocalWithBackend() async {
    print('Sync is running....');
    final dirtyActivities = await getDirtyActivities();
    if (dirtyActivities.isNotEmpty) {
      try {
        final res = await postActivities(
          dirtyActivities.toList(),
        );
        if (res.succeded.isNotEmpty) {
          // Update revision and dirty for all successful saves
          final toUpdate = res.succeded.map((s) {
            final a = dirtyActivities.firstWhere((a) => a.id == s.id);
            return a.copyWith(
              dirty: 0,
              revision: s.revision,
            ); // TODO get current dirty and subtract
          });
          await insertActivities(toUpdate);
        }
        if (res.failed.isNotEmpty) {
          // If we have failed a fetch from backend needs to be performed
          final minRevision = res.failed.map((f) => f.revision).reduce(min);
          await loadActivitiesFromRevision(minRevision);
        }
      } catch (e) {
        print('Failed to synchronize with backend $e');
        return false;
      }
    }
    return true;
  }
}
