import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:seagull/models/login_error.dart';
import 'package:uuid/uuid.dart';

import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class UserRepository extends Repository {
  static final _log = Logger((UserRepository).toString());
  final TokenDb tokenDb;
  final UserDb userDb;
  final LicenseDb licenseDb;

  UserRepository({
    required String baseUrl,
    required BaseClient client,
    required this.tokenDb,
    required this.userDb,
    required this.licenseDb,
  }) : super(client, baseUrl);

  UserRepository copyWith({
    String? baseUrl,
    BaseClient? client,
  }) =>
      UserRepository(
        baseUrl: baseUrl ?? this.baseUrl,
        client: client ?? this.client,
        tokenDb: tokenDb,
        userDb: userDb,
        licenseDb: licenseDb,
      );

  Future<String> authenticate({
    required String username,
    required String password,
    required String pushToken,
    required DateTime time,
  }) async {
    final response = await client.post(
      '$baseUrl/api/v1/auth/client/me'.toUri(),
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: json.encode(
        {
          'clientId': Uuid().v4(),
          'type': 'flutter',
          'app': Config.flavor.id,
          'name': Config.flavor.id,
          'address': pushToken
        },
      ),
    );
    switch (response.statusCode) {
      case 200:
        var login = Login.fromJson(json.decode(response.body));
        return login.token;
      case 401:
        throw UnauthorizedException();
      case 403:
        var errorMessage = LoginError.fromJson(json.decode(response.body));
        if (errorMessage.errors.isNotEmpty &&
            errorMessage.errors.first.code == Error.UNSUPPORTED_USER_TYPE) {
          throw WrongUserTypeException();
        }
        continue defaultException;
      defaultException:
      default:
        throw Exception(response.body);
    }
  }

  Future<User> me(String token) async {
    try {
      final user = await getUserFromApi(token);
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

  Future<User> getUserFromApi(String token) async {
    final response = await client.get('$baseUrl/api/v1/entity/me'.toUri(),
        headers: authHeader(token));

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return User.fromJson(responseJson['me']);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception('Could not get user right now');
    }
  }

  Future<List<License>> getLicenses() async {
    try {
      final token = getToken();
      if (token == null) throw 'token is null';
      final fromApi = await getLicensesFromApi(token);
      await licenseDb.persistLicenses(fromApi);
    } catch (e) {
      _log.warning('Could not fetch licenses from backend', e);
    }
    return licenseDb.getLicenses();
  }

  Future<List<License>> getLicensesFromApi(String token) async {
    final response = await client.get(
        '$baseUrl/api/v1/license/portal/me'.toUri(),
        headers: authHeader(token));
    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((l) => License.fromJson(l))
          .toList();
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception('Could not get license right now');
    }
  }

  Future logout([String? token]) async {
    _log.fine('unregister Client');
    await _unregisterClient(token);
    _log.fine('deleting token');
    await tokenDb.delete();
    _log.fine('deleting user');
    await userDb.deleteUser();
  }

  Future<void> persistToken(String token) => tokenDb.persistToken(token);

  String? getToken() => tokenDb.getToken();

  Future<bool> _unregisterClient([String? token]) async {
    try {
      token ??= getToken();
      if (token == null) throw 'token is null';
      final response = await client.delete(
          '$baseUrl/api/v1/auth/client'.toUri(),
          headers: authHeader(token));
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
      '$baseUrl/open/v1/entity/user'.toUri(),
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
        throw CreateAccountException.fromJson(json.decode(response.body));
    }
  }

  @override
  String toString() =>
      'UserRepository: { secureStorage: $tokenDb ${super.toString()} }';
}
