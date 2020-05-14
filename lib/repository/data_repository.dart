import 'package:http/http.dart';

import 'all.dart';

abstract class DataRepository<M> extends Repository {
  DataRepository(BaseClient httpClient, String baseUrl)
      : super(httpClient, baseUrl);

  Future<void> save(Iterable<M> data);
  Future<Iterable<M>> load();
  Future<bool> synchronize();

  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $httpClient}';
}
