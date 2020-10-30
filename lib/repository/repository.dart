import 'package:http/http.dart';
import 'package:http/testing.dart';

abstract class Repository {
  final String baseUrl;
  final BaseClient client;
  Repository(this.client, this.baseUrl)
      : assert(client is MockClient || baseUrl != null);

  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $client}';
}
