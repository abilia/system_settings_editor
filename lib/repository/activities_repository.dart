import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:seagull/models/activity.dart';
import 'package:seagull/repository/end_point.dart';

class ActivityRepository {
  final client = Client();
  final String authToken;
  final int userId;

  ActivityRepository({@required this.userId, @required this.authToken});
  Future<List<Activity>> loadActivities() async {
    final response = await client
        .get('$BASE_URL/api/v1/data/$userId/activities?revision=0', headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e))
        .toList();
  }

  Future saveActivities(List<Activity> activities) {return Future.delayed(Duration(seconds: 1));}
}
