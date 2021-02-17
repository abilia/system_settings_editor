import 'dart:io';

import 'package:http/http.dart';
import 'package:seagull/config.dart';

class ClientWithDefaultHeaders extends BaseClient {
  final _inner = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) => _inner
      .send(request..headers[HttpHeaders.userAgentHeader] = Config.flavor.id);
}
