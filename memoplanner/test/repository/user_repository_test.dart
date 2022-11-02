import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import '../fakes/fake_client.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../fakes/fake_db_and_repository.dart';
import '../mocks/mocks.dart';

void main() {
  const url = 'oneUrl';
  final mockBaseUrlDb = MockBaseUrlDb();
  final mockClient = MockBaseClient();
  final mockUserDb = MockUserDb();
  final mockLoginDb = MockLoginDb();
  final mockCalendarDb = MockCalendarDb();
  final userRepo = UserRepository(
    baseUrlDb: mockBaseUrlDb,
    client: mockClient,
    loginDb: mockLoginDb,
    userDb: mockUserDb,
    licenseDb: FakeLicenseDb(),
    deviceDb: MockDeviceDb(),
    calendarDb: mockCalendarDb,
  );

  setUp(() {
    when(() => mockBaseUrlDb.baseUrl).thenReturn(url);
  });

  test('if response 401, getUserFromApi throws UnauthorizedException',
      () async {
    // Arrange
    when(() => mockClient.get('$url/api/v1/entity/me'.toUri()))
        .thenAnswer((_) => Future.value(Response('body', 401)));
    // Assert
    try {
      await userRepo.getUserFromApi();
    } catch (e) {
      expect(e, isInstanceOf<UnauthorizedException>());
      return;
    }
    fail('did not throw');
  });

  test('if response 401, me throws UnauthorizedException', () async {
    // Arrange
    when(() => mockClient.get('$url/api/v1/entity/me'.toUri(),
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(Response('body', 401)));
    // Assert
    try {
      await userRepo.me();
    } catch (e) {
      expect(e, isInstanceOf<UnauthorizedException>());
      return;
    }
    fail('did not throw');
  });

  test('if response not 401, get user from database (offline case)', () async {
    // Arrange
    const userInDb = User(name: 'name', type: 'type', id: 123);
    when(() => mockClient.get('$url/api/v1/entity/me'.toUri()))
        .thenAnswer((_) => Future.value(Response('body', 400)));

    when(() => mockUserDb.getUser()).thenReturn(userInDb);
    // Act
    final user = await userRepo.me();
    // Assert
    expect(user, userInDb);
  });

  test('if no user in database, me throws UnauthorizedException', () async {
    // Arrange
    when(() => mockClient.get('$url/api/v1/entity/me'.toUri(),
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(Response('body', 400)));

    when(() => mockUserDb.getUser()).thenReturn(null);
    // Assert
    try {
      await userRepo.me();
    } catch (e) {
      expect(e, isInstanceOf<UnauthorizedException>());
      return;
    }
    fail('did not throw');
  });

  test('logout deletes token', () async {
    // Arrange
    const token = Fakes.token;
    when(() => mockLoginDb.deleteToken()).thenAnswer((_) async {});
    when(() => mockLoginDb.deleteLoginInfo()).thenAnswer((_) async {});
    when(() => mockUserDb.deleteUser()).thenAnswer((_) async {});
    when(() => mockClient.delete('$url/api/v1/auth/client'.toUri(),
            headers: authHeader(token)))
        .thenAnswer((_) => Future.value(Response('body', 200)));

    // Act
    await userRepo.logout();

    // Assert
    verify(() => mockClient.delete('$url/api/v1/auth/client'.toUri()));
    verify(() => mockLoginDb.deleteToken());
    verify(() => mockLoginDb.deleteLoginInfo());
    verify(() => mockUserDb.deleteUser());
  });

  test('exception when logging out', () async {
    // Arrange
    when(() => mockClient.delete('$url/api/v1/auth/client'.toUri()))
        .thenThrow(Exception());
    when(() => mockLoginDb.deleteToken()).thenAnswer((_) async {});
    when(() => mockLoginDb.deleteLoginInfo()).thenAnswer((_) async {});
    when(() => mockUserDb.deleteUser()).thenAnswer((_) async {});

    // Act
    await userRepo.logout();

    // Assert
    verify(() => mockClient.delete('$url/api/v1/auth/client'.toUri()));
    verify(() => mockLoginDb.deleteToken());
    verify(() => mockLoginDb.deleteLoginInfo());
    verify(() => mockUserDb.deleteUser());
  });
}
