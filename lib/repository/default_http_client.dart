import 'dart:io';

import 'package:http/http.dart' as http;

class ClientWithDefaultHeaders extends http.BaseClient {
  static const String SEAGULL_USER_AGENT_NAME = 'SEAGULL';
  final http.Client _httpClient = http.Client();
  final Map<String, String> defaultHeaders = {
    HttpHeaders.userAgentHeader: SEAGULL_USER_AGENT_NAME,
  };

  ClientWithDefaultHeaders();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(defaultHeaders);
    return _httpClient.send(request);
  }
}
