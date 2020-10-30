import 'dart:convert';

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';

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
    this.postApiVersion = 1,
    String postPath,
  })  : postPath = postPath ?? path,
        super(client, baseUrl);

  final DataDb<M> db;
  final String authToken;
  final int userId;
  final Logger log;
  final String path, postPath;
  final int postApiVersion;
  final FromJson<M> fromJson;

  Future<void> save(Iterable<M> data) => db.insertAndAddDirty(data);
  Future<bool> synchronize();

  Future<Iterable<M>> load() async {
    await fetchIntoDatabase();
    return db.getAllNonDeleted();
  }

  Future fetchIntoDatabase() {
    log.fine('loadning $path...');
    return synchronized(
      () async {
        try {
          final revision = await db.getLastRevision();
          final fetchedData = await fetchData(revision);
          log.fine('${fetchedData.length} $path fetched');
          await db.insert(fetchedData);
        } catch (e) {
          log.severe('Error when syncing $path, offline?', e);
        }
      },
    );
  }

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

  Future<DataUpdateResponse> postData(
    Iterable<DbModel<M>> data,
  ) async {
    final response = await client.post(
      '$baseUrl/api/v$postApiVersion/data/$userId/$postPath',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(data.toList()),
    );

    if (response.statusCode == 200) {
      final dataUpdateResponse =
          DataUpdateResponse.fromJson(json.decode(response.body));
      return dataUpdateResponse;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw UnavailableException([response.statusCode]);
  }

  @override
  String toString() => 'Repository: {baseUrl : $baseUrl, client: $client}';
}
