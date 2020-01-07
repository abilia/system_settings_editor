import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/repository/repository.dart';

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
      final fetchedActivities = await fetchActivities(amount);
      await activitiesDb.insertActivities(fetchedActivities);
    } catch (e) {
      // Error when syncing activities. Probably offline.
      print('Error when syncing activities $e');
    }
    return await activitiesDb.getActivitiesFromDb();
  }

  Future clearActivities() async {
    await activitiesDb.clearActivites();
  }

  Future saveActivities(Iterable<Activity> activities) {
    return Future.delayed(Duration(seconds: 1));
  }

  Future<Iterable<Activity>> fetchActivities(amount) async {
    final revision = await activitiesDb.getLastRevision();
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/activities?revision=$revision&amount=$amount',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e));
  }
}
