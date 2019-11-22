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
              response = clientMeSuccessResponse;
            }
          }
          if (pathSegments.containsAll(['entity', 'me'])) {
            response = entityMeSuccessResponse;
          }
          if (pathSegments.containsAll(['data', 'activities'])) {
            response =
                Response(json.encode(activitiesResponse ?? allActivities), 200);
          }
          return Future.value(response ?? Response('not found', 404));
        },
      );

  static Iterable<Activity> allActivities = [
    FakeActivity.reocurrsMondays(),
    FakeActivity.reocurrsTuedays(),
    FakeActivity.reocurrsWednesdays(),
    FakeActivity.reocurrsThursdays(),
    FakeActivity.reocurrsOnDay(1),
    FakeActivity.reocurrsOnDay(15),
    FakeActivity.reocurrsOnDay(22),
    FakeActivity.reocurrsOnDay(30),
    FakeActivity.reocurrsOnDay(31),
    FakeActivity.reocurrsOnDate(DateTime(2000, 12, 24)),
    FakeActivity.reocurrsOnDate(DateTime(2000, 01, 01)),
    FakeActivity.reocurrsOnDate(DateTime(2000, 06, 21)),
    FakeActivity.reocurrsOnDate(DateTime(2000, 10, 06)),
  ]
    ..addAll(FakeActivities.allPast)
    ..addAll(FakeActivities.oneFullDayEveryDay)
    ..addAll(FakeActivities.oneEveryMinute)
    ..addAll(FakeActivities.activities)
    ..addAll([]);

  static Response clientMeSuccessResponse = Response('''
    {
      "token" : "$token",
      "endDate" : 1231244,
      "renewToken" : ""
    }''', 200);

  static Response entityMeSuccessResponse = Response('''
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
