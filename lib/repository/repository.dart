import 'package:http/http.dart';
import 'package:http/testing.dart';

abstract class Repository {
  final String baseUrl;
  final BaseClient httpClient;
  Repository(this.httpClient, this.baseUrl)
      : assert(httpClient is MockClient || baseUrl != null);

  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $httpClient}';
}
