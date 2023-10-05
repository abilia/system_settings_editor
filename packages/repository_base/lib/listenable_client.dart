import 'package:http/http.dart';

enum HttpMessage { unauthorized }

abstract class ListenableClient extends BaseClient {
  Stream<HttpMessage> get messageStream;
}
