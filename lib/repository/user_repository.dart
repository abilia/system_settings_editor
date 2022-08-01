import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:seagull/models/login_error.dart';

import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class UserRepository extends Repository {
  static final _log = Logger((UserRepository).toString());
  final LoginDb loginDb;
  final UserDb userDb;
  final LicenseDb licenseDb;
  final CalendarDb calendarDb;
  final DeviceDb deviceDb;
  final int postApiVersion;

  const UserRepository({
    required BaseUrlDb baseUrlDb,
    required BaseClient client,
    required this.loginDb,
    required this.userDb,
    required this.licenseDb,
    required this.deviceDb,
    required this.calendarDb,
    this.postApiVersion = 1,
  }) : super(client, baseUrlDb);

  Future<LoginInfo> authenticate({
    required String username,
    required String password,
    required String pushToken,
    required DateTime time,
  }) async {
    final clientId = await deviceDb.getClientId();
    final post = client.runtimeType == ClientWithDefaultHeaders
        ? (client as ClientWithDefaultHeaders).postUnauthorized
        : client.post;
    final response = await post(
      '$baseUrl/api/v$postApiVersion/auth/client/me'.toUri(),
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: json.encode(
        {
          'clientId': clientId,
          'type': 'flutter',
          'app': Config.flavor.id,
          'name': Config.flavor.id,
          'address': pushToken,
        },
      ),
    );
    switch (response.statusCode) {
      case 200:
        return LoginInfo.fromJson(response.json());
      case 401:
        throw UnauthorizedException();
      case 403:
        var errorMessage = LoginError.fromJson(response.json());
        if (errorMessage.errors.isNotEmpty &&
            errorMessage.errors.first.code == Error.unsupportedUserType) {
          throw WrongUserTypeException();
        }
        continue defaultException;
      defaultException:
      default:
        throw Exception(response.body);
    }
  }

  Future<User> me() async {
    try {
      final user = await getUserFromApi();
      await userDb.insertUser(user);
      return user;
    } on UnauthorizedException {
      throw UnauthorizedException();
    } catch (_) {
      return await getUserFromDb();
    }
  }

  Future<User> getUserFromDb() async {
    final user = userDb.getUser();
    if (user == null) {
      throw UnauthorizedException();
    }
    return user;
  }

  Future<User> getUserFromApi() async {
    final response = await client.get(
      '$baseUrl/api/v$postApiVersion/entity/me'.toUri(),
    );

    if (response.statusCode == 200) {
      final responseJson = response.json();
      return User.fromJson(responseJson['me']);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception('Could not get user right now');
    }
  }

  Future<List<License>> getLicenses() async {
    try {
      final fromApi = await getLicensesFromApi();
      await licenseDb.persistLicenses(fromApi);
    } catch (e) {
      _log.warning('Could not fetch licenses from backend', e);
    }
    return licenseDb.getLicenses();
  }

  Future<List<License>> getLicensesFromApi() async {
    final response = await client.get(
      '$baseUrl/api/v$postApiVersion/license/portal/me'.toUri(),
    );
    if (response.statusCode == 200) {
      return (response.json() as List).map((l) => License.fromJson(l)).toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception('Could not get license right now');
    }
  }

  Future<void> fetchAndSetCalendar(int userId) async {
    try {
      if (await calendarDb.getCalendarId() == null) {
        final response = await client.post(
          '$baseUrl/api/v1/calendar/$userId?type=${CalendarDb.memoType}'
              .toUri(),
        );
        final calendarType = Calendar.fromJson(response.json());
        await calendarDb.insert(calendarType);
      }
    } catch (e, s) {
      _log.severe('could not fetch calendarId', e, s);
    }
  }

  Future<void> logout() async {
    _log.fine('unregister Client');
    await _unregisterClient();
    _log.fine('deleting token');
    await loginDb.deleteToken();
    await loginDb.deleteLoginInfo();
    _log.fine('deleting user');
    await userDb.deleteUser();
  }

  Future<void> persistLoginInfo(LoginInfo loginInfo) =>
      loginDb.persistLoginInfo(loginInfo);

  bool isLoggedIn() => loginDb.getToken() != null;

  Future<bool> _unregisterClient() async {
    try {
      final response = await client.delete(
        '$baseUrl/api/v$postApiVersion/auth/client'.toUri(),
      );
      return response.statusCode == 200;
    } catch (e) {
      _log.warning('can not unregister client: $e');
      return false;
    }
  }

  Future<void> createAccount({
    required String language,
    required String usernameOrEmail,
    required String password,
    required bool termsOfUse,
    required bool privacyPolicy,
  }) async {
    _log.fine('try creating account $usernameOrEmail');

    final response = await client.post(
      '$baseUrl/open/v$postApiVersion/entity/user'.toUri(),
      headers: const {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(
        {
          'usernameOrEmail': usernameOrEmail,
          'password': password,
          'language': language,
          'termsOfCondition': termsOfUse,
          'privacyPolicy': privacyPolicy,
        },
      ),
    );
    _log.finer(
      'creating account response ${response.statusCode} ${response.body}',
    );

    switch (response.statusCode) {
      case 200:
        _log.fine('account $usernameOrEmail created');
        break;
      default:
        throw CreateAccountException(
          badRequest: BadRequest.fromJson(
            response.json(),
          ),
        );
    }
  }

  Future<Map<String, dynamic>?> requestToken(
      String clientId, String renewToken) async {
    final response = await client.post(
      '$baseUrl/api/v$postApiVersion/token/renew'.toUri(),
      body: jsonEncode(
        {
          'clientId': clientId,
          'renewToken': renewToken,
        },
      ),
    );

    switch (response.statusCode) {
      case 200:
        _log.fine('token renewed');
        return response.json();
      default:
        throw RequestTokenException(
          badRequest: BadRequest.fromJson(
            response.json(),
          ),
        );
    }
  }

  @override
  String toString() =>
      'UserRepository: { secureStorage: $loginDb ${super.toString()} }';
}
