import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class ClientWithDefaultHeaders extends BaseClient {
  final _inner = Client();
  final String userAgent;
  final LoginDb loginDb;
  final DeviceDb deviceDb;
  final _log = Logger((ClientWithDefaultHeaders).toString());

  ClientWithDefaultHeaders(
    String version, {
    required this.loginDb,
    required this.deviceDb,
    String model = 'seagull',
  }) : userAgent = '${Config.flavor.name} v$version $model';

  @override
  Future<Response> head(Uri url, {Map<String, String>? headers}) =>
      super.head(url, headers: headers);

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await super.get(url, headers: headers);
    final host = url.origin;
    _log.info('Host: $host');
    if (response.statusCode == 401) {
      _renewToken(url.origin);
      return await super.get(url, headers: headers);
    }
    return response;
  }

  @override
  Future<Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    final response =
        await super.post(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode == 401) {
      _renewToken(url.origin);
      return await super
          .post(url, headers: headers, body: body, encoding: encoding);
    }
    return response;
  }

  @override
  Future<Response> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      super.put(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> patch(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      super.patch(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      super.delete(url, headers: headers, body: body, encoding: encoding);

  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      _inner.send((request..headers[HttpHeaders.userAgentHeader] = userAgent)
        ..headers['X-Auth-Token'] = loginDb.getToken() ?? '');

  void _renewToken(String host) async {
    try {
      final loginInfo = await _requestToken(host);
      loginDb.persistLoginInfo(loginInfo);
    } catch (e) {
      _log.warning('Could not renew token $e');
    }
  }

  Future<LoginInfo> _requestToken(String host) async {
    final loginInfo = loginDb.getLoginInfo();
    final clientId = await deviceDb.getClientId();
    final response = await _inner.post(
      '$host/open/v1/token/renew'.toUri(),
      body: jsonEncode(
        {
          'clientId': clientId,
          'renewToken': loginInfo?.renewToken,
        },
      ),
      headers: jsonHeader(),
    );

    switch (response.statusCode) {
      case 200:
        _log.fine('token renewed');
        return LoginInfo.fromJson(response.json());
      default:
        throw RequestTokenException(
          badRequest: BadRequest.fromJson(
            response.json(),
          ),
        );
    }
  }
}
