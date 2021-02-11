import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import 'fake_activities.dart';

typedef ActivityResponse = Iterable<Activity> Function();
typedef SortableResponse = Iterable<Sortable> Function();
typedef GenericResponse = Iterable<Generic> Function();

class Fakes {
  Fakes._();
  static int get userId => 1234;
  static const String token = 'token',
      name = 'Testcase user',
      username = 'username',
      type = 'testcase',
      incorrectPassword = 'wrongwrong';

  static MockClient client({
    ActivityResponse activityResponse,
    SortableResponse sortableResponse,
    GenericResponse genericResponse,
    Response Function() licenseResponse,
  }) =>
      MockClient(
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
            response = Response(
                json.encode((activityResponse?.call() ?? allActivities)
                    .map((a) => a.wrapWithDbModel())
                    .toList()),
                200);
          }
          if (pathSegments.containsAll(['data', 'sortableitems'])) {
            response = Response(
                json.encode((sortableResponse?.call() ?? allSortables)
                    .map((a) => a.wrapWithDbModel())
                    .toList()),
                200);
          }
          if (pathSegments.containsAll(['data', 'generics'])) {
            response = Response(
                json.encode((genericResponse?.call() ?? allGenerics)
                    .map((a) => a.wrapWithDbModel())
                    .toList()),
                200);
          }
          if (pathSegments.containsAll(['license', 'portal', 'me'])) {
            response = licenseResponse?.call() ??
                licenseResponseExpires(DateTime.now().add(10.days()));
          }

          return Future.value(response ?? Response('not found', 404));
        },
      );

  static final allActivities = [
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
  ];

  static final allSortables = <Sortable>[];
  static final allGenerics = <Generic>[];

  static final Response clientMeSuccessResponse = Response('''
    {
      "token" : "$token",
      "endDate" : 1231244,
      "renewToken" : ""
    }''', 200);

  static final Response entityMeSuccessResponse = Response('''
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

  static Response licenseResponseExpires(DateTime expires) => Response('''
    [
      {
        "id":125,
        "endTime":${expires.millisecondsSinceEpoch},
        "product":"$MEMOPLANNER_LICENSE_NAME"
      }
    ]
  ''', 200);
}
