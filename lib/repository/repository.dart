import 'package:http/http.dart';

abstract class Repository {
  final String baseUrl;
  final BaseClient client;
  Repository(this.client, this.baseUrl);

  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $client}';
}