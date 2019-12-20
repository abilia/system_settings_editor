import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/token_db.dart';
import 'package:seagull/db/user_db.dart';
import 'package:seagull/models/exceptions.dart';
import 'package:seagull/models/login.dart';
import 'package:seagull/models/user.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/repository/repository.dart';
import 'package:uuid/uuid.dart';

class UserRepository extends Repository {
  final TokenDb tokenDb;
  final UserDb userDb;

  UserRepository({
    String baseUrl,
    @required BaseClient httpClient,
    @required this.tokenDb,
    @required this.userDb,
  })  : assert(tokenDb != null),
        super(httpClient, baseUrl);

  UserRepository copyWith({
    String baseUrl,
    BaseClient httpClient,
  }) =>
      UserRepository(
          baseUrl: baseUrl ?? this.baseUrl,
          httpClient: httpClient ?? this.httpClient,
          tokenDb: this.tokenDb,
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
    final response = await httpClient.get('$baseUrl/api/v1/entity/me',
        headers: authHeader(token));

    if (response.statusCode == 200) {
      final responseJson = json.decode(response.body);
      return User.fromJson(responseJson['me']);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw Exception("Could not get user right now");
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
      final response = await httpClient.delete('$baseUrl/api/v1/auth/client',
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
