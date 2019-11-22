import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/repository/repository.dart';

class ActivityRepository extends Repository {
  final String authToken;
  final int userId;

  ActivityRepository({
    String baseUrl,
    @required BaseClient client,
    @required this.userId,
    @required this.authToken,
  }) : super(client, baseUrl);

  Future<Iterable<Activity>> loadActivities() async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/activities?revision=0',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e));
  }

  Future saveActivities(Iterable<Activity> activities) {
    return Future.delayed(Duration(seconds: 1));
  }
}
