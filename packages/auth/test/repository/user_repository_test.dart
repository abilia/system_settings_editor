import 'package:auth/auth.dart';
import 'package:auth/repository/user_repository.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/repository_base.dart';
import 'package:seagull_fakes/all.dart';

import 'package:test/test.dart';
import 'package:utils/utils.dart';

const token = 'Fakes.token';

void main() {
  final mockClient = MockBaseClient();
  final mockUserDb = MockUserDb();
  final mockLoginDb = MockLoginDb();
  final fakeBaseUrlDb = FakeBaseUrlDb();

  final userRepo = UserRepository(
    baseUrlDb: fakeBaseUrlDb,
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
    when(() =>
            mockClient.get('${fakeBaseUrlDb.baseUrl}/api/v1/entity/me'.toUri()))
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
    when(() => mockClient.get(
            '${fakeBaseUrlDb.baseUrl}/api/v1/entity/me'.toUri(),
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
    when(() =>
            mockClient.get('${fakeBaseUrlDb.baseUrl}/api/v1/entity/me'.toUri()))
        .thenAnswer((_) => Future.value(Response('body', 400)));

    when(() => mockUserDb.getUser()).thenReturn(userInDb);
    // Act
    final user = await userRepo.me();
    // Assert
    expect(user, userInDb);
  });

  test('if no user in database, me throws UnauthorizedException', () async {
    // Arrange
    when(() => mockClient.get(
            '${fakeBaseUrlDb.baseUrl}/api/v1/entity/me'.toUri(),
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

  test('SGC-2338, ignore range error on cary license with int max time',
      () async {
    // Arrange
    when(
      () => mockClient.get(
        '${fakeBaseUrlDb.baseUrl}/api/v1/license/portal/me'.toUri(),
      ),
    ).thenAnswer(
      (_) => Future.value(
        Response(
          '['
          '{'
          '"id":541,'
          '"licenseDataId":16,'
          '"licenseKey":"732647443797",'
          '"attachedTo":406,'
          '"demo":false,'
          '"endTime":185544263136042591,'
          '"initialDuration":2147483647,'
          '"maxUsers":1,'
          '"customer":"Internal Upgrade Customer",'
          '"hansaSerial":null,'
          '"product":"carybase"'
          '},'
          '{'
          '"id":629,'
          '"licenseDataId":2,'
          '"licenseKey":"407180680519",'
          '"attachedTo":406,'
          '"demo":true,'
          '"endTime":1684140798013,'
          '"initialDuration":60,'
          '"maxUsers":1,'
          '"customer":"Demo",'
          '"hansaSerial":null,'
          '"product":"handicalendar"'
          '},'
          '{'
          '"id":262,'
          '"licenseDataId":1,'
          '"licenseKey":"629963408391",'
          '"attachedTo":406,'
          '"demo":false,'
          '"endTime":1810551943986,'
          '"initialDuration":1825,'
          '"maxUsers":1,'
          '"customer":"ida",'
          '"hansaSerial":"",'
          '"product":"memoplanner"'
          '}'
          ']',
          200,
        ),
      ),
    );
    // Act
    final license = await userRepo.getLicensesFromApi();
    expect(license,
        predicate<List<License>>((l) => l.anyLicense(LicenseType.memoplanner)));
    expect(license,
        predicate<List<License>>((l) => l.anyLicense(LicenseType.handi)));

    // Assert
  });

  test('logout deletes token', () async {
    // Arrange
    when(() => mockLoginDb.deleteToken()).thenAnswer((_) async {});
    when(() => mockLoginDb.deleteLoginInfo()).thenAnswer((_) async {});
    when(() => mockUserDb.deleteUser()).thenAnswer((_) async {});
    when(() => mockClient.delete(
            '${fakeBaseUrlDb.baseUrl}/api/v1/auth/client'.toUri(),
            headers: authHeader(token)))
        .thenAnswer((_) => Future.value(Response('body', 200)));

    // Act
    await userRepo.logout();

    // Assert
    verify(() => mockClient
        .delete('${fakeBaseUrlDb.baseUrl}/api/v1/auth/client'.toUri()));
    verify(() => mockLoginDb.deleteToken());
    verify(() => mockLoginDb.deleteLoginInfo());
    verify(() => mockUserDb.deleteUser());
  });

  test('exception when logging out', () async {
    // Arrange
    when(() => mockClient
            .delete('${fakeBaseUrlDb.baseUrl}/api/v1/auth/client'.toUri()))
        .thenThrow(Exception());
    when(() => mockLoginDb.deleteToken()).thenAnswer((_) async {});
    when(() => mockLoginDb.deleteLoginInfo()).thenAnswer((_) async {});
    when(() => mockUserDb.deleteUser()).thenAnswer((_) async {});

    // Act
    await userRepo.logout();

    // Assert
    verify(() => mockClient
        .delete('${fakeBaseUrlDb.baseUrl}/api/v1/auth/client'.toUri()));
    verify(() => mockLoginDb.deleteToken());
    verify(() => mockLoginDb.deleteLoginInfo());
    verify(() => mockUserDb.deleteUser());
  });
}
