import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/testing.dart';
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

class Fakes {
  Fakes._();

  static const int userId = 1234;
  static const user = User(id: userId, type: type, name: name);
  static const String token = 'token',
      name = 'Test case user',
      username = 'username',
      type = 'test case',
      incorrectPassword = 'wrong wrong wrong',
      supportUserName = 'supportUser';

  static ListenableMockClient client({
    ActivityResponse? activityResponse,
    SortableResponse? sortableResponse,
    GenericResponse? genericResponse,
    VoicesResponse? voicesResponse,
    Response Function()? licenseResponse,
    SessionsResponse? sessionsResponse,
    TermsOfUseResponse? termsOfUseResponse,
    Response Function()? connectLicenseResponse,
    bool Function()? factoryResetResponse,
  }) =>
      ListenableMockClient(
        (r) async {
          final pathSegments = r.url.pathSegments.toSet();

          if (pathSegments.containsAll(['auth', 'client', 'me'])) {
            final authHeaders = r.headers[HttpHeaders.authorizationHeader];
            final incorrect =
                'Basic ${base64Encode(utf8.encode('$username:$incorrectPassword'))}';
            final supportUserHeader =
                'Basic ${base64Encode(utf8.encode('$supportUserName:$incorrectPassword'))}';
            if (authHeaders == incorrect) {
              return Response(
                  '{"timestamp":"${DateTime.now()}","status":401,"error":"Unauthorized","message":"Unable to authorize","path":"//api/v1/auth/client/me"}',
                  401);
            } else if (authHeaders == supportUserHeader) {
              return unsupportedUserTypeResponse;
            }
            return clientMeSuccessResponse;
          }
          if (pathSegments.containsAll(['entity', 'me'])) {
            return entityMeSuccessResponse;
          }
          if (pathSegments.containsAll(['data', 'activities'])) {
            return Response(
                json.encode((activityResponse?.call() ?? allActivities)
                    .map((a) => a.wrapWithDbModel())
                    .toList()),
                200);
          }
          if (pathSegments.containsAll(['data', 'generics'])) {
            return Response(
                json.encode((genericResponse?.call() ?? allGenerics)
                    .map((a) => a.wrapWithDbModel())
                    .toList()),
                200);
          }
          if (pathSegments.containsAll(['license', 'portal', 'me'])) {
            return licenseResponse?.call() ??
                licenseResponseExpires(DateTime.now().add(10.days()));
          }
          if (pathSegments.contains('calendar')) {
            return calendarSuccessResponse;
          }
          if (pathSegments.containsAll({'entity', 'user'})) {
            final uName = json.decode(r.body)['usernameOrEmail'];
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
          if (pathSegments.containsAll(['token', 'renew'])) {
            if (r.body.contains('"renewToken":"renewToken"')) {
              return Response('''{
                            "token" : "$token",
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

          if (pathSegments.containsAll(['auth', 'client']) &&
              !pathSegments.contains('me')) {
            return Response(
                json.encode(
                    (sessionsResponse?.call() ?? fakeSessions).toList()),
                200);
          }

          if (pathSegments.containsAll(['entity', 'acknowledgments'])) {
            return Response(
                json.encode((termsOfUseResponse?.call().toMap() ??
                    TermsOfUse.accepted().toMap())),
                200);
          }

          if (pathSegments.containsAll({'open', 'v1', 'device', 'license'})) {
            return connectLicenseResponse?.call() ??
                connectLicenseSuccessResponses;
          }

          if (pathSegments.containsAll({'open', 'v1', 'device', 'reset'})) {
            return factoryResetResponse?.call() == true
                ? factoryResetSuccess
                : factoryResetFail;
          }

          return Response(json.encode(List.empty()), 200);
        },
      );

  static final allActivities = [
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

  static final fakeSessions = [Session.mp4Session()];

  static final allSortables = <Sortable>[];
  static final allGenerics = <Generic>[];

  static final Response factoryResetSuccess = Response('''
    {
    }''', 200);

  static final Response factoryResetFail = Response('''
    {
    }''', 404);

  static final Response connectLicenseSuccessResponses = Response('''
    {
      "serialNumber" : "serialNumber",
      "product" : "$memoplannerLicenseName",
      "endTime" : 0
    }''', 200);

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
      "id": "an-unique-calendar-id-of-type-memoplanner",
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
  ListenableMockClient(MockClientHandler handler) : super(handler);
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
