
import 'package:mocktail/mocktail.dart';
import 'package:repo_base/repo_base.dart';
import 'package:test/test.dart';
import 'package:http/http.dart';

import 'package:auth/models/all.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:utils/utils.dart';

import '../fakes_and_mocks.dart';

const token = 'Fakes.token';

void main() {
  final mockClient = MockBaseClient();
  final mockUserDb = MockUserDb();
  final mockLoginDb = MockLoginDb();

  final userRepo = UserRepository(
    baseUrlDb: FakeBaseUrlDb(),
    client: mockClient,
    loginDb: mockLoginDb,
    userDb: mockUserDb,
    licenseDb: FakeLicenseDb(),
    deviceDb: FakeDeviceDb(),
    app: 'app',
    name: 'name',
  );

  test('if response 401, getUserFromApi throws UnauthorizedException',
      () async {
    // Arrange
    when(() => mockClient.get('${FakeBaseUrlDb.url}/api/v1/entity/me'.toUri()))
        .thenAnswer((_) => Future.value(Response('body', 401)));
    // Assert
    try {
      await userRepo.getUserFromApi();
    } catch (e) {
      expect(e, isA<UnauthorizedException>());
      return;
    }
    fail('did not throw');
  });

  test('if response 401, me throws UnauthorizedException', () async {
    // Arrange
    when(() => mockClient.get('${FakeBaseUrlDb.url}/api/v1/entity/me'.toUri(),
            headers: authHeader(token)))
        .thenAnswer((_) => Future.value(Response('body', 401)));
    // Assert
    try {
      await userRepo.me();
    } catch (e) {
      expect(e, isA<UnauthorizedException>());
      return;
    }
    fail('did not throw');
  });

  test('if response not 401, get user from database (offline case)', () async {
    // Arrange
    const userInDb = User(name: 'name', type: 'type', id: 123);
    when(() => mockClient.get('${FakeBaseUrlDb.url}/api/v1/entity/me'.toUri()))
        .thenAnswer((_) => Future.value(Response('body', 400)));

    when(() => mockUserDb.getUser()).thenReturn(userInDb);
    // Act
    final user = await userRepo.me();
    // Assert
    expect(user, userInDb);
  });

  test('if no user in database, me throws UnauthorizedException', () async {
    // Arrange
    when(() => mockClient.get('${FakeBaseUrlDb.url}/api/v1/entity/me'.toUri(),
            headers: authHeader(token)))
        .thenAnswer((_) => Future.value(Response('body', 400)));

    when(() => mockUserDb.getUser()).thenReturn(null);
    // Assert
    try {
      await userRepo.me();
    } catch (e) {
      expect(e, isA<UnauthorizedException>());
      return;
    }
    fail('did not throw');
  });

  test('logout deletes token', () async {
    // Arrange
    when(() => mockLoginDb.deleteToken()).thenAnswer((_) async {});
    when(() => mockLoginDb.deleteLoginInfo()).thenAnswer((_) async {});
    when(() => mockUserDb.deleteUser()).thenAnswer((_) async {});
    when(() => mockClient.delete(
            '${FakeBaseUrlDb.url}/api/v1/auth/client'.toUri(),
            headers: authHeader(token)))
        .thenAnswer((_) => Future.value(Response('body', 200)));

    // Act
    await userRepo.logout();

    // Assert
    verify(() =>
        mockClient.delete('${FakeBaseUrlDb.url}/api/v1/auth/client'.toUri()));
    verify(() => mockLoginDb.deleteToken());
    verify(() => mockLoginDb.deleteLoginInfo());
    verify(() => mockUserDb.deleteUser());
  });

  test('exception when logging out', () async {
    // Arrange
    when(() => mockClient
            .delete('${FakeBaseUrlDb.url}/api/v1/auth/client'.toUri()))
        .thenThrow(Exception());
    when(() => mockLoginDb.deleteToken()).thenAnswer((_) async {});
    when(() => mockLoginDb.deleteLoginInfo()).thenAnswer((_) async {});
    when(() => mockUserDb.deleteUser()).thenAnswer((_) async {});

    // Act
    await userRepo.logout();

    // Assert
    verify(() =>
        mockClient.delete('${FakeBaseUrlDb.url}/api/v1/auth/client'.toUri()));
    verify(() => mockLoginDb.deleteToken());
    verify(() => mockLoginDb.deleteLoginInfo());
    verify(() => mockUserDb.deleteUser());
  });
}
