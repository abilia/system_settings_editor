import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/repository/end_point.dart';

class ActivityRepository {
  final BaseClient client;
  final String authToken;
  final int userId;

  ActivityRepository({@required this.client, @required this.userId, @required this.authToken});
  Future<Iterable<Activity>> loadActivities() async {
    final response = await client
        .get('$BASE_URL/api/v1/data/$userId/activities?revision=0', headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e));
  }

  Future saveActivities(Iterable<Activity> activities) {return Future.delayed(Duration(seconds: 1));}
}
