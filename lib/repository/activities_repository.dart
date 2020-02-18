import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:pedantic/pedantic.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class ActivityRepository extends Repository {
  final String authToken;
  final int userId;
  final ActivityDb activitiesDb;

  ActivityRepository({
    String baseUrl,
    @required BaseClient client,
    @required this.activitiesDb,
    @required this.userId,
    @required this.authToken,
  }) : super(client, baseUrl);

  Future<Iterable<Activity>> loadActivities({int amount = 10000}) async {
    try {
      final fetchedActivities = await _fetchActivities(amount);
      await activitiesDb.insertActivities(fetchedActivities);
    } catch (e) {
      // Error when syncing activities. Probably offline.
      print('Error when syncing activities $e');
    }
    return activitiesDb.getActivitiesFromDb();
  }

  Future<Iterable<Activity>> _fetchActivities(int amount) async {
    final revision = await activitiesDb.getLastRevision();
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/activities?revision=$revision&amount=$amount',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e));
  }

  Future<Iterable<Activity>> saveActivities(
      Iterable<Activity> activities) async {
    final response = await httpClient.post(
      '$baseUrl/api/v1/data/$userId/activities',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(activities),
    );

    if (response.statusCode == 200) {
      final activityUpdateResponse =
          ActivityUpdateResponse.fromJson(json.decode(response.body));

      if (activityUpdateResponse.failed.isNotEmpty) {
        print('%%%%%%%%%%%%%%%%% FAILED TO UPDATE ACTIVITY %%%%%%%%%%%%%%%%%');
        activityUpdateResponse.failed.forEach(print);
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
      }

      final successess = activityUpdateResponse.succeded.map<Activity>(
        (s) => activities
            .firstWhere((a) => a.id == s.id)
            .copyWith(revision: s.revision),
      );
      unawaited(activitiesDb.insertActivities(successess));
      return successess;
    }
    return [];
  }
}
