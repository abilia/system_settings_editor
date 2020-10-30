import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

import 'all.dart';

abstract class DataRepository<M extends DataModel> extends Repository {
  DataRepository(
    BaseClient client,
    String baseUrl,
    this.authToken,
    this.userId,
    this.db,
    this.log,
  ) : super(client, baseUrl);

  final DataDb<M> db;
  final String authToken;
  final int userId;
  final Logger log;

  Future<void> save(Iterable<M> data) => db.insertAndAddDirty(data);
  Future<Iterable<M>> load();
  Future<bool> synchronize();

  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $httpClient}';
}
