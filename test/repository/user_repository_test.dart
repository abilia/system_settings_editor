import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'dart:async';

import '../mocks.dart';

void main() {
  final url = 'oneUrl';
  final mockClient = MockedClient();
  final mockUserDb = MockUserDb();
  final mockTokenDb = MockTokenDb();
  final userRepo = UserRepository(
    baseUrl: url,
    httpClient: mockClient,
    tokenDb: mockTokenDb,
    userDb: mockUserDb,
    licenseDb: MockLicenseDb(),
  );
  test('copyWith with new', () {
    // Arrange
    final newClient = Fakes.client();
    final newUrl = 'newrl';
    // Act
    final newUserRepo =
        userRepo.copyWith(baseUrl: newUrl, httpClient: newClient);
    // Assert
    expect(newUserRepo.baseUrl, isNot(userRepo.baseUrl));
    expect(newUserRepo.baseUrl, newUrl);
    expect(newUserRepo.httpClient, isNot(userRepo.httpClient));
    expect(newUserRepo.httpClient, newClient);
    expect(newUserRepo.tokenDb, userRepo.tokenDb);
    expect(newUserRepo.userDb, userRepo.userDb);
  });
  test('copyWith with old', () {
    // Act
    final newUserRepo = userRepo.copyWith();
    // Assert
    expect(newUserRepo.baseUrl, userRepo.baseUrl);
    expect(newUserRepo.httpClient, userRepo.httpClient);
    expect(newUserRepo.tokenDb, userRepo.tokenDb);
    expect(newUserRepo.userDb, userRepo.userDb);
  });

  test('if response 401, getUserFromApi throws UnauthorizedException',
      () async {
    // Arrange
    when(mockClient.get('$url/api/v1/entity/me',
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
    when(mockClient.get('$url/api/v1/entity/me',
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
    final userInDb = User(name: 'name', type: 'type', id: 123);
    when(mockClient.get('$url/api/v1/entity/me',
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(Response('body', 400)));

    when(mockUserDb.getUser()).thenAnswer((_) => Future.value(userInDb));
    // Act
    final user = await userRepo.me(Fakes.token);
    // Assert
    expect(user, userInDb);
  });

  test('if no user in database, me throws UnauthorizedException', () async {
    // Arrange
    when(mockClient.get('$url/api/v1/entity/me',
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => Future.value(Response('body', 400)));

    when(mockUserDb.getUser()).thenAnswer((_) => Future.value(null));
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
    final token = Fakes.token;
    when(mockClient.delete('$url/api/v1/auth/client',
            headers: authHeader(token)))
        .thenAnswer((_) => Future.value(Response('body', 200)));

    // Act
    await userRepo.logout(token);

    // Assert
    verify(mockClient.delete('$url/api/v1/auth/client',
        headers: authHeader(token)));
    verify(mockTokenDb.delete());
    verify(mockUserDb.deleteUser());
  });

  test('exception when logging out', () async {
    // Arrange
    final token = Fakes.token;
    when(mockClient.delete('$url/api/v1/auth/client',
            headers: authHeader(token)))
        .thenThrow(Exception());

    // Act
    await userRepo.logout(token);

    // Assert
    verify(mockClient.delete('$url/api/v1/auth/client',
        headers: authHeader(token)));
    verify(mockTokenDb.delete());
    verify(mockUserDb.deleteUser());
  });
}
