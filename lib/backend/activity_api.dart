import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class ActivityApi {
  final httpClient;
  final String baseUrl;
  final String authToken;

  ActivityApi({
    @required this.httpClient,
    @required this.baseUrl,
    @required this.authToken,
  });

  Future<Iterable<Activity>> fetchActivities(int revision, int userId) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/activities?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => Activity.fromJson(e));
  }

  Future<ActivityUpdateResponse> postActivities(
      List<Activity> activities, int userId) async {
    final response = await httpClient.post(
      '$baseUrl/api/v1/data/$userId/activities',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(activities),
    );

    if (response.statusCode == 200) {
      final activityUpdateResponse =
          ActivityUpdateResponse.fromJson(json.decode(response.body));
      return activityUpdateResponse;
    }
    throw Exception();
  }
}
