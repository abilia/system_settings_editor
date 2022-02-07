import 'package:http/http.dart';
import 'package:seagull/db/all.dart';

abstract class Repository {
  final BaseUrlDb baseUrlDb;
  final BaseClient client;
  const Repository(this.client, this.baseUrlDb);

  String get baseUrl => baseUrlDb.getBaseUrl();

  @override
  String toString() => 'Repository: {baseUrl : $baseUrlDb, client: $client}';
}
