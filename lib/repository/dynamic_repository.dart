import 'package:http/http.dart';

import 'all.dart';

abstract class DataRepository<M> extends Repository {
  final String baseUrl;
  final BaseClient httpClient;
  DataRepository(this.httpClient, this.baseUrl) : super(httpClient, baseUrl);

  Future<void> save(Iterable<M> data);
  Future<Iterable<M>> load();
  Future<bool> synchronize();

  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $httpClient}';
}
