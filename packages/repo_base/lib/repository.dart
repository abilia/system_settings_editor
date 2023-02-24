import 'package:http/http.dart';
import 'package:repo_base/baseurl_db.dart';

abstract class Repository {
  final BaseUrlDb baseUrlDb;
  final BaseClient client;
  const Repository({
    required this.client,
    required this.baseUrlDb,
  });

  String get baseUrl => baseUrlDb.baseUrl;

  @override
  String toString() =>
      'Repository: {baseUrl : ${baseUrlDb.baseUrl}, client: $client}';
}
