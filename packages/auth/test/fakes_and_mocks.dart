import 'dart:async';
import 'dart:convert';

import 'package:auth/db/all.dart';
import 'package:auth/models/all.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:calendar_repository/calendar_repository.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSharedPreferences {
  static Future<SharedPreferences> getInstance({bool loggedIn = true}) {
    SharedPreferences.setMockInitialValues({
      if (loggedIn) LoginDb.tokenKey: 'Fakes.token',
    });
    return SharedPreferences.getInstance();
  }
}

class MockBaseUrlDb extends Mock implements BaseUrlDb {}

class MockBaseClient extends Mock implements BaseClient {}

class MockUserDb extends Mock implements UserDb {}

class MockLoginDb extends Mock implements LoginDb {}

class MockUserRepository extends Mock implements UserRepository {}

class MockCalendarRepository extends Mock implements CalendarRepository {}

class MockNotification extends Mock implements Notification {}

class Notification {
  void mockCancelAll() {}
}

class FakeLicenseDb extends Fake implements LicenseDb {}

class FakeDeviceDb extends Fake implements DeviceDb {}

class FakeBaseUrlDb extends Fake implements BaseUrlDb {
  static const url = 'oneUrl';
  @override
  String get baseUrl => url;
}

class FakeListenableClient {
  static const int userId = 1234;
  static const user = User(id: userId, type: type, name: name, language: 'sv');
  static const String token = 'token',
      name = 'Test case user',
      username = 'username',
      type = 'test case';

  static ListenableMockClient client({
    Response Function()? licenseResponse,
    Response Function()? connectLicenseResponse,
    bool Function()? factoryResetResponse,
  }) =>
      ListenableMockClient(
        (request) async {
          final pathSegments = request.url.pathSegments.toSet();

          if (pathSegments.containsAll(['auth', 'client'])) {
            return Response(json.encode(List.empty()), 200);
          }
          if (pathSegments.containsAll(['entity', 'me'])) {
            return Response(
                json.encode({
                  'me': user.toJson(),
                }
                ),
                200);
          }
          if (pathSegments.contains('calendar')) {
            return Response(
                '{'
                '"id": "an-unique-calendar-id-of-type-memoplanner",'
                '"type": "MEMOPLANNER",'
                '"owner": $userId,'
                '"main": true'
                '}',
                200);
          }
          return Response('{}', 404);
        },
      );
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
