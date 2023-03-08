import 'dart:async';
import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

@visibleForTesting
class FakeDeviceDb extends Fake implements DeviceDb {
  @override
  Future<String> getClientId() async {
    return 'clientId';
  }

  @override
  String get serialId => 'serialId';

  @override
  bool get startGuideCompleted => true;

  @override
  Future<void> setDeviceLicense(DeviceLicense license) async {}

  @override
  DeviceLicense? getDeviceLicense() {
    return null;
  }
}

@visibleForTesting
class FakeSharedPreferences {
  static Future<SharedPreferences> getInstance({bool loggedIn = true}) {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      if (loggedIn) LoginDb.tokenKey: 'Fakes.token',
    });
    return SharedPreferences.getInstance();
  }
}

@visibleForTesting
class FakeUserRepository extends Fake implements UserRepository {
  @override
  String get baseUrl => 'fake.url';

  @override
  Future<void> persistLoginInfo(LoginInfo token) => Future.value();
}

@visibleForTesting
class FakeLoginDb extends Fake implements LoginDb {
  static const String token = 'token';

  @override
  String? getToken() => token;
}

@visibleForTesting
class FakePushCubit extends Fake implements PushCubit {
  @override
  Stream<RemoteMessage> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

@visibleForTesting
class FakeLicenseDb extends Fake implements LicenseDb {
  @override
  Future persistLicenses(List<License> licenses) => Future.value();

  @override
  List<License> getLicenses() => [
        License(
          id: 123,
          key: 'licenseKey',
          product: memoplannerLicenseName,
          endTime: DateTime(3333),
        ),
      ];
}

@visibleForTesting
class FakeBaseUrlDb extends Fake implements BaseUrlDb {
  @override
  Future setBaseUrl(String baseUrl) async {}

  @override
  String get baseUrl => 'http://fake.url';

  @override
  String get environment => 'FAKE';

  @override
  String get environmentOrTest => 'FAKE';
}

@visibleForTesting
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
                }),
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

@visibleForTesting
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
