import 'dart:io';

import 'package:http/http.dart';

import 'package:seagull/config.dart';

class ClientWithDefaultHeaders extends BaseClient {
  final _inner = Client();
  final String userAgent;

  ClientWithDefaultHeaders(
    String version, {
    String model = 'seagull',
  }) : userAgent = '${Config.flavor.name} v$version $model';

  @override
  Future<StreamedResponse> send(BaseRequest request) =>
      _inner.send(request..headers[HttpHeaders.userAgentHeader] = userAgent);
}
