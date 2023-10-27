import 'dart:async';
import 'dart:convert';

import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthenticationBloc extends Fake implements AuthenticationBloc {
  @override
  Stream<AuthenticationState> get stream => const Stream.empty();

  @override
  AuthenticationState get state => const Authenticated(
        user: User(id: 1234, type: 'type', name: 'name'),
      );

  @override
  Future<void> close() async {}
}

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

  @override
  Future<String> getSupportId() async => '2c4f3842-c17c-11ed-afa1-0242ac120002';
}

class FakeSharedPreferences {
  static Future<SharedPreferences> getInstance({
    bool loggedIn = true,
    Map<String, Object> extras = const {},
  }) {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      if (loggedIn) LoginDb.tokenKey: 'Fakes.token',
      // ToDo: use VoiceDb.textToSpeechRecord when tts is a separate package
      'TEXT_TO_SPEECH': true,
      ...extras,
    });
    return SharedPreferences.getInstance();
  }
}

class FakeUserRepository extends Fake implements UserRepository {
  @override
  String get baseUrl => 'fake.url';

  @override
  Future<void> persistLoginInfo(LoginInfo token) => Future.value();
}

class FakeLoginDb extends Fake implements LoginDb {
  static const String token = 'token';

  @override
  String? getToken() => token;
}

class FakePushCubit extends Fake implements PushCubit {
  @override
  Stream<RemoteMessage> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}

class FakeLicenseDb extends Fake implements LicenseDb {
  @override
  Future persistLicenses(List<License> licenses) => Future.value();

  @override
  List<License> getLicenses() => [
        License(
          id: 123,
          key: 'licenseKey',
          product: Product.memoplanner,
          endTime: DateTime(3333),
        ),
      ];
}

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

class FakeListenableClient {
  static const int userId = 1234;
  static const user = User(id: userId, type: type, name: name, language: 'sv');
  static const String token = 'token',
      name = 'Test case user',
      username = 'username',
      incorrectPassword = 'wrong wrong wrong',
      type = 'test case';

  static ListenableMockClient client({
    Response Function()? licenseResponse,
    Response Function()? connectLicenseResponse,
    bool Function()? factoryResetResponse,
  }) =>
      ListenableMockClient(
        (request) async {
          final pathSegments = request.url.pathSegments.toSet();

          if (pathSegments.containsAll(<String>{'auth', 'client'})) {
            return Response(json.encode(List.empty()), 200);
          }
          if (pathSegments.containsAll(<String>{'entity', 'me'})) {
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

class ListenableMockClient extends MockClient implements ListenableClient {
  ListenableMockClient(super.handler);

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

class FakeLicenseCubit extends Fake implements LicenseCubit {
  @override
  bool get validLicense => true;

  @override
  ValidLicense get state => ValidLicense();

  @override
  Stream<LicenseState> get stream => const Stream.empty();

  @override
  Future<void> close() async {}
}
