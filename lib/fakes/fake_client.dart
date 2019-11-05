import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:seagull/models.dart';

class Fakes {
  Fakes._();
  static int get userId => 1234;
  static const String token = 'token',
      name = 'Testcase user',
      username = 'username',
      type = 'testcase',
      incorrectPassword = 'wrong';

  static MockClient get client => MockClient(
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
            response = Response(json.encode(activities), 200);
          }
          return Future.value(response ?? Response('not found', 404));
        },
      );

  static List<Activity> get activities {
    final nowExact = DateTime.now();
    final now = DateTime(nowExact.year, nowExact.month, nowExact.day,
        nowExact.hour, nowExact.minute);
    return [
      Activity.createNew(
          title: 'long past',
          startTime: now
              .subtract(Duration(hours: 2))
              .millisecondsSinceEpoch,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          reminderBefore: [60 * 60 * 1000],
          alarmType: ALARM_SILENT),
      Activity.createNew(
          title: 'past',
          startTime: now
              .subtract(Duration(hours: 1, minutes: 1))
              .millisecondsSinceEpoch,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          reminderBefore: [60 * 60 * 1000],
          alarmType: ALARM_SILENT),
      Activity.createNew(
          title: 'soon end',
          startTime: now.subtract(Duration(hours: 1)).millisecondsSinceEpoch,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          reminderBefore: [],
          alarmType: NO_ALARM),
      Activity.createNew(
          title: 'now',
          startTime: now.millisecondsSinceEpoch,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          reminderBefore: [],
          alarmType: ALARM_SILENT),
      Activity.createNew(
          title: 'soon start',
          startTime: now.add(Duration(minutes: 1)).millisecondsSinceEpoch,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          reminderBefore: [],
          alarmType: ALARM_SILENT),
      Activity.createNew(
          title: 'later',
          startTime: now.add(Duration(hours: 1)).millisecondsSinceEpoch,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          reminderBefore: [],
          alarmType: ALARM_SILENT),
      Activity.createNew(
          title: 'most of day',
          startTime: now.subtract(Duration(hours: 8)).millisecondsSinceEpoch,
          duration: Duration(hours: 16).inMilliseconds,
          category: 0,
          reminderBefore: [0,1,2],
          alarmType: ALARM_SILENT),
      Activity.createNew(
          title: 'yesterday',
          startTime: now.subtract(Duration(days: 1)).millisecondsSinceEpoch,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          reminderBefore: [],
          alarmType: ALARM_SILENT),
      Activity.createNew(
          title: 'tomorrow',
          startTime: now.add(Duration(days: 1)).millisecondsSinceEpoch,
          duration: Duration(hours: 1).inMilliseconds,
          category: 0,
          reminderBefore: [],
          alarmType: ALARM_SILENT),
    ];
  }
}
