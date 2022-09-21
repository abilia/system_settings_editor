import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import 'all.dart';

typedef ActivityResponse = Iterable<Activity> Function();
typedef SortableResponse = Iterable<Sortable> Function();
typedef GenericResponse = Iterable<Generic> Function();
typedef TimerResponse = Iterable<AbiliaTimer> Function();
typedef VoicesResponse = Iterable<Map<String, dynamic>> Function();

class Fakes {
  Fakes._();

  static int get userId => 1234;
  static const String token = 'token',
      name = 'Testcase user',
      username = 'username',
      type = 'testcase',
      incorrectPassword = 'wrongwrongwrong',
      supportUserName = 'supportUser';

  static ListenableMockClient client({
    ActivityResponse? activityResponse,
    SortableResponse? sortableResponse,
    GenericResponse? genericResponse,
    VoicesResponse? voicesResponse,
    Response Function()? licenseResponse,
  }) =>
      ListenableMockClient(
        (r) {
          final pathSegments = r.url.pathSegments.toSet();
          Response? response;
          if (pathSegments.containsAll(['auth', 'client', 'me'])) {
            final authHeaders = r.headers[HttpHeaders.authorizationHeader];
            final incorrect =
                'Basic ${base64Encode(utf8.encode('$username:$incorrectPassword'))}';
            final supportUserHeader =
                'Basic ${base64Encode(utf8.encode('$supportUserName:$incorrectPassword'))}';
            if (authHeaders == incorrect) {
              response = Response(
                  '{"timestamp":"${DateTime.now()}","status":401,"error":"Unauthorized","message":"Unable to authorize","path":"//api/v1/auth/client/me"}',
                  401);
            } else if (authHeaders == supportUserHeader) {
              response = unsupportedUserTypeResponse;
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
          if (pathSegments.contains('calendar')) {
            response = calendarSuccessResponse;
          }
          if (pathSegments.containsAll({'entity', 'user'})) {
            final uName = json.decode(r.body)['usernameOrEmail'];
            if (uName == 'taken') {
              response = Response(
                '{"status":400,"message":"That entity already have login information. Perhaps you wanted to update the entities login information. Auth: com.abilia.models.auth.AuthUsername@5e694644[entityId=493,username=sad,passwordHash=com.abilia.models.auth.PasswordHash@4838f869]","errorId":739,"errors":[{"code":"WHALE-0130","message":"Error creating user. Username/email address already in use"}]}',
                400,
              );
            } else {
              response = Response(
                '{"id":492,"type":"user","name":"$uName","email":"qazxsw","image":null,"language":"en","shortname":null,"useShortname":false}',
                200,
              );
            }
          }
          if (pathSegments.containsAll(['token', 'renew'])) {
            if (r.body.contains('"renewToken":"renewToken"')) {
              response = Response('''{
                            "token" : "$token",
                            "endDate" : 1231244,
                            "renewToken" : "renewToken"
                          }''', 200);
            } else {
              response = Response(json.encode(List.empty()), 401);
            }
          }

          if (pathSegments.containsAll(VoiceRepository.pathSegments
              .split('/')
              .where((s) => s.isNotEmpty))) {
            response = Response(
              json.encode((voicesResponse?.call() ?? []).toList()),
              200,
            );
          }

          return Future.value(
              response ?? Response(json.encode(List.empty()), 200));
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

  static final Response calendarSuccessResponse = Response('''
    {
      "id": "an-unique-calender-id-of-type-memoplanner",
      "type": "MEMOPLANNER",
      "owner": $userId,
      "main": true
    }''', 200);

  static Response licenseResponseExpires(DateTime expires) => Response('''
    [
      {
        "id":125,
        "endTime":${expires.millisecondsSinceEpoch},
        "product":"$memoplannerLicenseName"
      }
    ]
  ''', 200);

  static Response unsupportedUserTypeResponse = Response('''
  {"status":403,"message":"Clients can only be registered with entities of type 'user'","errorId":217,"errors":[{"code":"WHALE-0156","message":"Clients can only be registered with entities of type 'user'"}]}''',
      403);
}

class ListenableMockClient extends MockClient implements ListenableClient {
  ListenableMockClient(MockClientHandler fn) : super(fn);
  final _stateController = StreamController<HttpMessage>.broadcast();

  @override
  Stream<HttpMessage> get messageStream => _stateController.stream;

  @override
  void close() {
    _stateController.close();
  }

  void fakeUnauthorized() {
    _stateController.add(HttpMessage.unauthorized);
  }
}
