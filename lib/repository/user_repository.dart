import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/db/license_db.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/repository/repository.dart';
import 'package:uuid/uuid.dart';

class UserRepository extends Repository {
  static final _log = Logger((UserRepository).toString());
  final TokenDb tokenDb;
  final UserDb userDb;
  final LicenseDb licenseDb;

  UserRepository({
    String baseUrl,
    @required BaseClient client,
    @required this.tokenDb,
    @required this.userDb,
    @required this.licenseDb,
  })  : assert(tokenDb != null),
        super(client, baseUrl);

  UserRepository copyWith({
    String baseUrl,
    BaseClient client,
  }) =>
      UserRepository(
        baseUrl: baseUrl ?? this.baseUrl,
        client: client ?? this.client,
        tokenDb: tokenDb,
        userDb: userDb,
        licenseDb: licenseDb,
      );

  Future<String> authenticate({
    @required String username,
    @required String password,
    @required String pushToken,
    @required DateTime time,
  }) async {
    final response = await client.post(
      '$baseUrl/api/v1/auth/client/me',
      headers: {
        HttpHeaders.authorizationHeader:
            'Basic ${base64Encode(utf8.encode('$username:$password'))}',
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: json.encode(
        {
          'clientId': Uuid().v4(),
          'type': 'flutter',
          'app': 'seagull',
          'name': 'seagull',
          'address': pushToken
        },
      ),
    );
    if (response.statusCode == 200) {
      var login = Login.fromJson(json.decode(response.body));
      return login.token;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
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
    final user = await userDb.getUser();
    if (user == null) {
      throw UnauthorizedException();
    }
    return user;
  }

  Future<User> getUserFromApi(String token) async {
    final response = await client.get('$baseUrl/api/v1/entity/me',
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
      final token = await tokenDb.getToken();
      final fromApi = await getLicensesFromApi(token);
      await licenseDb.persistLicenses(fromApi);
    } catch (e) {
      _log.warning('Could not fetch licenses from backend', e);
    }
    return licenseDb.getLicenses();
  }

  Future<List<License>> getLicensesFromApi(String token) async {
    final response = await client.get('$baseUrl/api/v1/license/portal/me',
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

  Future<void> logout([String token]) async {
    await _unregisterClient(token);
    await tokenDb.delete();
    await userDb.deleteUser();
  }

  Future<void> persistToken(String token) => tokenDb.persistToken(token);

  Future<String> getToken() => tokenDb.getToken();

  Future<bool> _unregisterClient([String token]) async {
    token ??= await getToken();
    try {
      final response = await client.delete('$baseUrl/api/v1/auth/client',
          headers: authHeader(token));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  String toString() =>
      'UserRepository: { secureStorage: $tokenDb ${super.toString()} }';
}
