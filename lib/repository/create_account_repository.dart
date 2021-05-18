import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'package:seagull/repository/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

class CreateAccountRepository extends Repository {
  static final _log = Logger((CreateAccountRepository).toString());

  CreateAccountRepository({
    String baseUrl,
    @required BaseClient client,
  }) : super(client, baseUrl);

  Future<void> createAccount({
    @required String language,
    @required String usernameOrEmail,
    @required String password,
    @required bool termsOfUse,
    @required bool privacyPolicy,
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
}
