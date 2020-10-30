import 'dart:convert';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import 'all.dart';

typedef FromJson<M extends DataModel> = DbModel<M> Function(
    Map<String, dynamic> json);

abstract class DataRepository<M extends DataModel> extends Repository {
  DataRepository({
    @required BaseClient client,
    @required String baseUrl,
    @required this.path,
    @required this.authToken,
    @required this.userId,
    @required this.db,
    @required this.fromJson,
    @required this.log,
  }) : super(client, baseUrl);

  final DataDb<M> db;
  final String authToken;
  final int userId;
  final Logger log;
  final String path;
  final FromJson<M> fromJson;

  Future<void> save(Iterable<M> data) => db.insertAndAddDirty(data);
  Future<Iterable<M>> load();
  Future<bool> synchronize();

  Future<Iterable<DbModel>> fetchData(int revision) async {
    final response = await client.get(
        '$baseUrl/api/v1/data/$userId/$path?revision=$revision',
        headers: authHeader(authToken));
    final decoded = (json.decode(response.body)) as List;
    return decoded
        .exceptionSafeMap(
          (e) => fromJson(e),
          onException: log.logAndReturnNull,
        )
        .filterNull();
  }

  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $client}';
}
