import 'package:http/http.dart';
import 'package:memoplanner/db/all.dart';

abstract class Repository {
  final BaseUrlDb baseUrlDb;
  final BaseClient client;
  const Repository(this.client, this.baseUrlDb);

  String get baseUrl => baseUrlDb.baseUrl;

  @override
  String toString() =>
      'Repository: {baseUrl : ${baseUrlDb.baseUrl}, client: $client}';
}
