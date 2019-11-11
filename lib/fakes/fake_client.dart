import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:seagull/models.dart';

import 'fake_activities.dart';

class Fakes {
  Fakes._();
  static int get userId => 1234;
  static const String token = 'token',
      name = 'Testcase user',
      username = 'username',
      type = 'testcase',
      incorrectPassword = 'wrong';

  static MockClient client([List<Activity> activitiesResponse]) => MockClient(
        (r) {
          final pathSegments = r.url.pathSegments.toSet();
          Response response;
          if (pathSegments.containsAll(['auth', 'client', 'me'])) {
            final authHeaders = r.headers[HttpHeaders.authorizationHeader];
            final incorrect =
                'Basic ${base64Encode(utf8.encode('$username:$incorrectPassword'))}';
            if (authHeaders == incorrect) {
              response = Response(
                  '{"timestamp":"${DateTime.now()}","status":401,"error":"Unauthorized","message":"Unable to authorize","path":"//api/v1/auth/client/me"}',
                  401);
            } else {
              response = Response('''
              {
                "token" : "$token",
                "endDate" : 1231244,
                "renewToken" : ""
              }''', 200);
            }
          }
          if (pathSegments.containsAll(['entity', 'me'])) {
            response = Response('''
              {
                "me" : {
                  "id" : $userId,
                  "type" : "$type",
                  "name" : "$name",
                  "username" : "$username",
                  "language" : "sv",
                  "image" : null
                }
              }''', 200);
          }
          if (pathSegments.containsAll(['data', 'activities'])) {
            response = Response(json.encode(activitiesResponse ?? []), 200);
          }
          return Future.value(response ?? Response('not found', 404));
        },
      );

  static Iterable<Activity> allActivities = []
    ..addAll(FakeActivities.allPast)
    ..addAll(FakeActivities.oneFullDayEveryDay)
    ..addAll(FakeActivities.oneEveryMinute)
    ..addAll(FakeActivities.activities)
    ..addAll([]);
}
