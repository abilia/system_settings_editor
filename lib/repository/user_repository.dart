import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:meta/meta.dart';
import 'package:seagull/models/login.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  final Client client;
  UserRepository({@required this.client});

  Future<String> authenticate({
    @required String username,
    @required String password,
  }) async {
    final response = await client.post('$BASE_URL/api/v1/auth/client/me',
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

  Future<void> deleteToken() async {
    /// delete from keystore/keychain
  }

  Future<void> persistToken(String token) async {
    /// write to keystore/keychain
  }

  Future<bool> hasToken() async {
    /// read from keystore/keychain
    return false;
  }
}