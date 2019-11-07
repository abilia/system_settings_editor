import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:seagull/models.dart';
import 'package:seagull/utils/datetime_utils.dart';

class Fakes {
  Fakes._();
  static int get userId => 1234;
  static const String token = 'token',
      name = 'Testcase user',
      username = 'username',
      type = 'testcase',
      incorrectPassword = 'wrong';

  static MockClient client() => MockClient(
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
            response = Response(
                json.encode(_oneFullDayEveryDay(now)
                  ..addAll(_oneEveryMinute(now))
                  ..addAll(_activities(now))),
                200);
          }
          return Future.value(response ?? Response('not found', 404));
        },
      );

  static DateTime get now => removeToMinutes(DateTime.now());

  static List<Activity> _activities(DateTime now) => [
        Activity.createNew(
            title: 'fullday',
            startTime: now.subtract(Duration(hours: 2)).millisecondsSinceEpoch,
            duration: Duration(hours: 1).inMilliseconds,
            category: 0,
            fullDay: true,
            reminderBefore: [60 * 60 * 1000],
            alarmType: ALARM_SILENT),
        Activity.createNew(
            title:
                'long10 long9 long8 long7 long6 long5 long4 long3 long2 long1 long0 long long long long long long long long long long long long long past',
            startTime: now.subtract(Duration(hours: 2)).millisecondsSinceEpoch,
            duration: Duration(hours: 1).inMilliseconds,
            category: 0,
            reminderBefore: [60 * 60 * 1000],
            alarmType: ALARM_SILENT),
        Activity.createNew(
            title: 'long past',
            startTime: now.subtract(Duration(hours: 2)).millisecondsSinceEpoch,
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
            reminderBefore: [0, 1, 2],
            alarmType: ALARM_SILENT),
        Activity.createNew(
            title: 'yesterday fullday',
            startTime: now.subtract(Duration(days: 1)).millisecondsSinceEpoch,
            duration: Duration(hours: 1).inMilliseconds,
            category: 0,
            fullDay: true,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
        Activity.createNew(
            title: 'yesterday',
            startTime: now.subtract(Duration(days: 1)).millisecondsSinceEpoch,
            duration: Duration(hours: 1).inMilliseconds,
            category: 0,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
        Activity.createNew(
            title: 'tomorrow fullday',
            startTime: now.add(Duration(days: 1)).millisecondsSinceEpoch,
            duration: Duration(hours: 1).inMilliseconds,
            fullDay: true,
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
        Activity.createNew(
            title: 'two days from now',
            startTime: now.add(Duration(days: 2)).millisecondsSinceEpoch,
            duration: Duration(hours: 1).inMilliseconds,
            category: 0,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
      ];

  static List<Activity> _oneEveryMinute(DateTime now, {int minutes = 120}) {
    now = now.subtract(Duration(minutes: minutes ~/ 2));
    return [
      for (int i = 0; i < minutes; i++)
        Activity.createNew(
            title: 'Minute $i',
            startTime: now.add(Duration(minutes: i)).millisecondsSinceEpoch,
            duration: Duration(minutes: 5).inMilliseconds,
            category: 0,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
    ];
  }

  static List<Activity> _oneFullDayEveryDay(DateTime now, {int days = 6}) {
    now = now.subtract(Duration(minutes: days ~/ 2));
    return [
      for (int i = 0; i < days; i++)
        Activity.createNew(
            title: 'fullDay $i',
            fullDay: true,
            startTime: now.add(Duration(days: i)).millisecondsSinceEpoch,
            duration: Duration(minutes: 5).inMilliseconds,
            category: 0,
            reminderBefore: [],
            alarmType: ALARM_SILENT),
    ];
  }
}
