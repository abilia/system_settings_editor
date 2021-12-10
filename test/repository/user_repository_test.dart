import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../fakes/fake_db_and_repository.dart';
import '../mocks/mocks.dart';

void main() {
  const url = 'oneUrl';
  final mockClient = MockBaseClient();
  final mockUserDb = MockUserDb();
  final mockTokenDb = MockTokenDb();
  final userRepo = UserRepository(
    baseUrl: url,
    client: mockClient,
    tokenDb: mockTokenDb,
    userDb: mockUserDb,
    licenseDb: FakeLicenseDb(),
  );

  test('copyWith with new', () {
    // Arrange
    final newClient = Fakes.client();
    const newUrl = 'newrl';
    // Act
    final newUserRepo = userRepo.copyWith(baseUrl: newUrl, client: newClient);
    // Assert
    expect(newUserRepo.baseUrl, isNot(userRepo.baseUrl));
    expect(newUserRepo.baseUrl, newUrl);
    expect(newUserRepo.client, isNot(userRepo.client));
    expect(newUserRepo.client, newClient);
    expect(newUserRepo.tokenDb, userRepo.tokenDb);
    expect(newUserRepo.userDb, userRepo.userDb);
  });

  test('copyWith with old', () {
    // Act
    final newUserRepo = userRepo.copyWith();
    // Assert
    expect(newUserRepo.baseUrl, userRepo.baseUrl);
    expect(newUserRepo.client, userRepo.client);
    expect(newUserRepo.tokenDb, userRepo.tokenDb);
    expect(newUserRepo.userDb, userRepo.userDb);
  });

  test('if response 401, getUserFromApi throws UnauthorizedException',
      () async {
    // Arrange
    when(() => mockClient.get('$url/api/v1/entity/me'.toUri(),
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(Response('body', 401)));
    // Assert
    try {
      await userRepo.getUserFromApi(Fakes.token);
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
      await userRepo.me(Fakes.token);
    } catch (e) {
      expect(e, isInstanceOf<UnauthorizedException>());
      return;
    }
    fail('did not throw');
  });

  test('if response not 401, get user from database (offline case)', () async {
    // Arrange
    const userInDb = User(name: 'name', type: 'type', id: 123);
    when(() => mockClient.get('$url/api/v1/entity/me'.toUri(),
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(Response('body', 400)));

    when(() => mockUserDb.getUser()).thenReturn(userInDb);
    // Act
    final user = await userRepo.me(Fakes.token);
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
      await userRepo.me(Fakes.token);
    } catch (e) {
      expect(e, isInstanceOf<UnauthorizedException>());
      return;
    }
    fail('did not throw');
  });

  test('logout deletes token', () async {
    // Arrange
    const token = Fakes.token;
    when(() => mockTokenDb.delete()).thenAnswer((_) async {});
    when(() => mockUserDb.deleteUser()).thenAnswer((_) async {});
    when(() => mockClient.delete('$url/api/v1/auth/client'.toUri(),
            headers: authHeader(token)))
        .thenAnswer((_) => Future.value(Response('body', 200)));

    // Act
    await userRepo.logout(token);

    // Assert
    verify(() => mockClient.delete('$url/api/v1/auth/client'.toUri(),
        headers: authHeader(token)));
    verify(() => mockTokenDb.delete());
    verify(() => mockUserDb.deleteUser());
  });

  test('exception when logging out', () async {
    // Arrange
    const token = Fakes.token;
    when(() => mockClient.delete('$url/api/v1/auth/client'.toUri(),
        headers: authHeader(token))).thenThrow(Exception());
    when(() => mockTokenDb.delete()).thenAnswer((_) async {});
    when(() => mockUserDb.deleteUser()).thenAnswer((_) async {});

    // Act
    await userRepo.logout(token);

    // Assert
    verify(() => mockClient.delete('$url/api/v1/auth/client'.toUri(),
        headers: authHeader(token)));
    verify(() => mockTokenDb.delete());
    verify(() => mockUserDb.deleteUser());
  });
}
