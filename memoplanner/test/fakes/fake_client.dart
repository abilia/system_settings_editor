import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

import 'all.dart';

typedef ActivityResponse = Iterable<Activity> Function();
typedef SortableResponse = Iterable<Sortable> Function();
typedef GenericResponse = Iterable<Generic> Function();
typedef TimerResponse = Iterable<AbiliaTimer> Function();
typedef VoicesResponse = Iterable<Map<String, dynamic>> Function();
typedef SessionsResponse = Iterable<Session> Function();
typedef TermsOfUseResponse = TermsOfUse Function();

int loginAttempts = 0;
const int userId = 1234;
const User user = User(id: userId, type: type, name: name);
const String name = 'Test case user',
    username = 'username',
    type = 'test case',
    incorrectPassword = 'wrong wrong wrong',
    supportUserName = 'supportUser';

ListenableMockClient fakeClient({
  ActivityResponse? activityResponse,
  SortableResponse? sortableResponse,
  GenericResponse? genericResponse,
  VoicesResponse? voicesResponse,
  Response Function()? licenseResponse,
  SessionsResponse? sessionsResponse,
  TermsOfUseResponse? termsOfUseResponse,
  Response Function()? connectLicenseResponse,
  bool allowMultipleLogins = true,
  bool Function()? factoryResetResponse,
}) =>
    ListenableMockClient(
      (request) async {
        final pathSegments = request.url.pathSegments.toSet();

        if (pathSegments.containsAll(<String>{'auth', 'client', 'me'})) {
          final authHeaders = request.headers[HttpHeaders.authorizationHeader];
          final incorrect =
              'Basic ${base64Encode(utf8.encode('$username:$incorrectPassword'))}';
          final supportUserHeader =
              'Basic ${base64Encode(utf8.encode('$supportUserName:$incorrectPassword'))}';
          if (!allowMultipleLogins && loginAttempts > 0) {
            return tooManyAttemptsTypeResponse;
          }
          if (authHeaders == incorrect) {
            loginAttempts++;
            return Response(
                '{"timestamp":"${DateTime.now()}","status":401,"error":"Unauthorized","message":"Unable to authorize","path":"//api/v1/auth/client/me"}',
                401);
          } else if (authHeaders == supportUserHeader) {
            return unsupportedUserTypeResponse;
          }
          loginAttempts = 0;
          return clientMeSuccessResponse;
        }
        if (pathSegments.containsAll(<String>{'entity', 'me'})) {
          return entityMeSuccessResponse;
        }
        if (pathSegments.containsAll(<String>{'data', 'activities'})) {
          return Response(
              json.encode((activityResponse?.call() ?? allActivities)
                  .map((a) => a.wrapWithDbModel())
                  .toList()),
              200);
        }
        if (pathSegments.containsAll(<String>{'data', 'generics'})) {
          return Response(
              json.encode((genericResponse?.call() ?? allGenerics)
                  .map((a) => a.wrapWithDbModel())
                  .toList()),
              200);
        }
        if (pathSegments.containsAll(<String>{'license', 'portal', 'me'})) {
          return licenseResponse?.call() ??
              licenseResponseExpires(DateTime.now().add(10.days()));
        }
        if (pathSegments.contains('calendar')) {
          return calendarSuccessResponse;
        }
        if (pathSegments.containsAll(<String>{'entity', 'user'})) {
          final uName = json.decode(request.body)['usernameOrEmail'];
          if (uName == 'taken') {
            return Response(
              '{"status":400,"message":"That entity already have login information. Perhaps you wanted to update the entities login information. Auth: com.abilia.models.auth.AuthUsername@5e694644[entityId=493,username=sad,passwordHash=com.abilia.models.auth.PasswordHash@4838f869]","errorId":739,"errors":[{"code":"WHALE-0130","message":"Error creating user. Username/email address already in use"}]}',
              400,
            );
          }
          return Response(
            '{"id":492,"type":"user","name":"$uName","email":"me@mail.se","image":null,"language":"en","shortname":null,"useShortname":false}',
            200,
          );
        }
        if (pathSegments.containsAll(<String>{'token', 'renew'})) {
          if (request.body.contains('"renewToken":"renewToken"')) {
            return Response('''{
                            "token" : "${FakeLoginDb.token}",
                            "endDate" : 1231244,
                            "renewToken" : "renewToken"
                          }''', 200);
          }
          return Response(json.encode(List.empty()), 401);
        }

        if (pathSegments.containsAll(VoiceRepository.pathSegments
            .split('/')
            .where((s) => s.isNotEmpty))) {
          return Response(
            json.encode((voicesResponse?.call() ?? []).toList()),
            200,
          );
        }

        if (pathSegments.containsAll(<String>{'auth', 'client'}) &&
            !pathSegments.contains('me')) {
          return Response(
              json.encode((sessionsResponse?.call() ?? fakeSessions).toList()),
              200);
        }

        if (pathSegments.containsAll(<String>{'entity', 'acknowledgments'})) {
          return Response(
              json.encode((termsOfUseResponse?.call().toMap() ??
                  TermsOfUse.accepted().toMap())),
              200);
        }

        if (pathSegments
            .containsAll(<String>{'open', 'v1', 'device', 'license'})) {
          return connectLicenseResponse?.call() ?? deviceLicenseSuccessResponse;
        }

        if (pathSegments
            .containsAll(<String>{'open', 'v1', 'device', 'reset'})) {
          return factoryResetResponse?.call() == true
              ? factoryResetSuccess
              : factoryResetFail;
        }

        if (pathSegments.containsAll(<String>{'entity', 'features'})) {
          return Response(
            json.encode({'features': []}),
            200,
          );
        }

        return Response(json.encode(List.empty()), 200);
      },
    );

final allActivities = [
  FakeActivity.reoccursMondays(),
  FakeActivity.reoccursTuesdays(),
  FakeActivity.reoccursWednesdays(),
  FakeActivity.reoccursThursdays(),
  FakeActivity.reoccursOnDay(1),
  FakeActivity.reoccursOnDay(15),
  FakeActivity.reoccursOnDay(22),
  FakeActivity.reoccursOnDay(30),
  FakeActivity.reoccursOnDay(31),
  FakeActivity.reoccursOnDate(DateTime(2000, 12, 24)),
  FakeActivity.reoccursOnDate(DateTime(2000, 01, 01)),
  FakeActivity.reoccursOnDate(DateTime(2000, 06, 21)),
  FakeActivity.reoccursOnDate(DateTime(2000, 10, 06)),
];

final fakeSessions = [Session.mp4Session()];

final allSortables = <Sortable>[];
final allGenerics = <Generic>[];

final Response factoryResetSuccess = Response('''
    {
    }''', 200);

final Response factoryResetFail = Response('''
    {
    }''', 404);

final Response deviceLicenseSuccessResponse = Response('''
    {
      "serialNumber" : "serialNumber",
      "product" : "$memoplannerLicenseName",
      "endTime" : 0,
      "licenseKey" : "1111-1111-1111"
    }''', 200);

final Response clientMeSuccessResponse = Response('''
    {
      "token" : "${FakeLoginDb.token}",
      "endDate" : 1231244,
      "renewToken" : ""
    }''', 200);

final Response entityMeSuccessResponse = Response('''
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

final Response calendarSuccessResponse = Response('''
    {
      "id": "an-unique-calendar-id-of-type-memoplanner",
      "type": "MEMOPLANNER",
      "owner": $userId,
      "main": true
    }''', 200);

Response licenseResponseExpires(DateTime expires) => Response('''
    [
      {
        "id":125,
        "endTime":${expires.millisecondsSinceEpoch},
        "product":"$memoplannerLicenseName"
      }
    ]
  ''', 200);

Response unsupportedUserTypeResponse = Response('''
  {"status":403,"message":"Clients can only be registered with entities of type 'user'","errorId":217,"errors":[{"code":"WHALE-0156","message":"Clients can only be registered with entities of type 'user'"}]}''',
    403);

Response tooManyAttemptsTypeResponse = Response('', 429);
