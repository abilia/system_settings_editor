import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/login.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  final String _tokenKey = 'tokenKey';
  final Client httpClient;
  final FlutterSecureStorage secureStorage;

  UserRepository({@required this.httpClient, @required this.secureStorage})
      : assert(httpClient != null),
        assert(secureStorage != null);

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    final response = await httpClient.post('$BASE_URL/api/v1/auth/client/me',
        headers: {
          HttpHeaders.authorizationHeader:
              'Basic ${base64Encode(utf8.encode('$username:$password'))}',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: json.encode({
          'clientId': Uuid().v4(),
          'type': 'flutter',
          'app': 'seagull',
          'name': 'seagull'
        }));
    if (response.statusCode == 200) {
      var login = Login.fromJson(json.decode(response.body));
      return login.token;
    } else {
      throw Exception(response.body);
    }
  }

  Future<void> deleteToken() => secureStorage.delete(key: _tokenKey);

  Future<void> persistToken(String token) =>
      secureStorage.write(key: _tokenKey, value: token);

  Future<bool> hasToken() async =>
      await secureStorage.read(key: _tokenKey) != null;
}
