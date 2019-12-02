import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:seagull/db/activities_db.dart';
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

  Future<Iterable<Activity>> loadActivities() async {
    // Try to fetch from backend
    final fetchedActivities = await fetchActivities();
    // Insert new to db
    await activitiesDb.insertActivities(fetchedActivities);
    // Get from db
    return await activitiesDb.getActivitiesFromDb();
  }

  Future saveActivities(Iterable<Activity> activities) {
    return Future.delayed(Duration(seconds: 1));
  }

  Future<List<Activity>> fetchActivities() async {
    final revision = await activitiesDb.getLastRevision();
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/activities?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e))
        .toList();
  }
}
