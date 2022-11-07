import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:synchronized/extension.dart';

class ClientWithDefaultHeaders extends ListenableClient {
  late final Client _inner;
  final String userAgent;
  final LoginDb loginDb;
  final DeviceDb deviceDb;
  final _stateController = StreamController<HttpMessage>.broadcast();
  final _log = Logger((ClientWithDefaultHeaders).toString());

  ClientWithDefaultHeaders(
    String version, {
    required this.loginDb,
    required this.deviceDb,
    Client? client,
    String model = 'seagull',
  })  : userAgent = '${Config.flavor.name} v$version $model',
        _inner = client ?? Client();

  @override
  Stream<HttpMessage> get messageStream => _stateController.stream;

  @override
  Future<Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await super.get(url, headers: headers);
    if (response.statusCode == 401) {
      _log.info('Got 401 on $url');
      await _renewToken(url.origin);
      return super.get(url, headers: headers);
    }
    return response;
  }

  @override
  Future<Response> post(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _renewOn401(super.post, url,
          headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _renewOn401(super.put, url,
          headers: headers, body: body, encoding: encoding);

  @override
  Future<Response> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      _renewOn401(super.delete, url,
          headers: headers, body: body, encoding: encoding);

  Future<Response> _renewOn401(
    Future<Response> Function(Uri url,
            {Map<String, String>? headers, Object? body, Encoding? encoding})
        request,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response =
        await request(url, headers: headers, body: body, encoding: encoding);
    if (response.statusCode != 401) return response;
    _log.info('Got 401 on $response');
    await _renewToken(url.origin);
    return request(url, headers: headers, body: body, encoding: encoding);
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    request.headers[HttpHeaders.userAgentHeader] = userAgent;
    if (request.url.path.contains('/api/')) {
      final token = loginDb.getToken() ?? '';
      request.headers['X-Auth-Token'] = token;
    }
    return _inner.send(request);
  }

  Future<void> _renewToken(String host) async {
    _log.fine('Will try to renew token...');
    return synchronized(() async {
      if (await _hasAccess(host)) {
        _log.fine('Has access. No need to renew token.');
        return;
      }
      _log.fine('Has NO access. Will request token.');
      try {
        final loginInfo = await _requestToken(host);
        await loginDb.persistLoginInfo(loginInfo);
        _log.fine('Persisted new loginInfo');
      } catch (e) {
        _log.warning('Could not renew token $e');
      }
    });
  }

  Future<bool> _hasAccess(String host) async {
    final loginInfo = loginDb.getLoginInfo();
    final response = await _inner.get(
      '$host/api/v1/entity/me'.toUri(),
      headers: authHeader(loginInfo?.token),
    );
    return response.statusCode != 401;
  }

  Future<LoginInfo> _requestToken(String host) async {
    final loginInfo = loginDb.getLoginInfo();
    final clientId = await deviceDb.getClientId();
    _log.fine('Requesting new token with clientId: $clientId');
    final response = await _inner.post(
      '$host/open/v1/token/renew'.toUri(),
      body: jsonEncode(
        {
          'clientId': clientId,
          'renewToken': loginInfo?.renewToken ?? '',
        },
      ),
      headers: jsonHeader,
    );

    switch (response.statusCode) {
      case 200:
        return LoginInfo.fromJson(response.json());
      case 401:
        _stateController.add(HttpMessage.unauthorized);
        throw RequestTokenException(
          badRequest: BadRequest.fromJson(
            response.json(),
          ),
        );
      default:
        throw RequestTokenException(
          badRequest: BadRequest.fromJson(
            response.json(),
          ),
        );
    }
  }

  @override
  void close() {
    _stateController.close();
  }
}

enum HttpMessage { unauthorized }

abstract class ListenableClient extends BaseClient {
  Stream<HttpMessage> get messageStream;
}
