import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/user_db.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/models/login.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/repository/repository.dart';
import 'package:uuid/uuid.dart';

class UserRepository extends Repository {
  final String _tokenKey = 'tokenKey';
  final FlutterSecureStorage secureStorage;
  final UserDb userDb;

  UserRepository({
    String baseUrl,
    @required BaseClient httpClient,
    @required this.secureStorage,
    @required this.userDb,
  })  : assert(secureStorage != null),
        super(httpClient, baseUrl);

  UserRepository copyWith({
    String baseUrl,
    BaseClient httpClient,
    FlutterSecureStorage secureStorage,
  }) =>
      UserRepository(
          baseUrl: baseUrl ?? this.baseUrl,
          httpClient: httpClient ?? this.httpClient,
          secureStorage: secureStorage ?? this.secureStorage,
          userDb: this.userDb);

  Future<String> authenticate(
      {@required String username,
      @required String password,
      @required String pushToken}) async {
    final response = await httpClient.post('$baseUrl/api/v1/auth/client/me',
        headers: {
          HttpHeaders.authorizationHeader:
              'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: json.encode({
          'clientId': Uuid().v4(),
          'type': 'flutter',
          'app': 'seagull',
          'name': 'seagull',
          'address': pushToken
        }));
    if (response.statusCode == 200) {
      var login = Login.fromJson(json.decode(response.body));
      return login.token;
    } else {
      throw Exception(response.body);
    }
  }

  Future<User> me(authToken) async {
    try {
      final user = await getUserFromApi(authToken);
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

  Future<User> getUserFromApi(authToken) async {
    final response = await httpClient.get('$baseUrl/api/v1/entity/me',
        headers: authHeader(authToken));

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return User.fromJson(responseJson['me']);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception("Could not get user right now");
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: _tokenKey);
    await userDb.removeUser();
  }

  Future<void> persistToken(String token) =>
      secureStorage.write(key: _tokenKey, value: token);

  Future<String> getToken() => secureStorage.read(key: _tokenKey);

  @override
  String toString() =>
      'UserRepository: { secureStorage: $secureStorage ${super.toString()} }';
}
