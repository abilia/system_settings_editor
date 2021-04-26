import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/repository/all.dart';

typedef JsonToDataModel<M extends DataModel> = DbModel<M> Function(
    Map<String, dynamic> json);

abstract class DataRepository<M extends DataModel> extends Repository {
  DataRepository({
    @required BaseClient client,
    @required String baseUrl,
    @required this.path,
    @required this.authToken,
    @required this.userId,
    @required this.db,
    @required this.fromJsonToDataModel,
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
  final JsonToDataModel<M> fromJsonToDataModel;

  Future<void> save(Iterable<M> data) => db.insertAndAddDirty(data);

  Future<Iterable<M>> load() async {
    await fetchIntoDatabaseSynchronized();
    return db.getAllNonDeleted();
  }

  Future fetchIntoDatabaseSynchronized() => synchronized(fetchIntoDatabase);

  @protected
  Future fetchIntoDatabase() async {
    log.fine('loadning $path...');
    try {
      final revision = await db.getLastRevision();
      final fetchedData = await fetchData(revision);
      log.fine('${fetchedData.length} $path fetched');
      await db.insert(fetchedData);
    } catch (e) {
      log.severe('Error when syncing $path, offline?', e);
    }
  }

  @protected
  Future<Iterable<DbModel<M>>> fetchData(int revision) async {
    log.fine('fetching $path for revision $revision');
    final response = await client.get(
      '$baseUrl/api/v1/data/$userId/$path?revision=$revision'.toUri(),
      headers: authHeader(authToken),
    );
    final decoded = (json.decode(response.body)) as List;
    return decoded
        .exceptionSafeMap(
          (j) => fromJsonToDataModel(j),
          onException: log.logAndReturnNull,
        )
        .filterNull();
  }

  Future<bool> synchronize() async {
    return synchronized(() async {
      await fetchIntoDatabase();
      final dirtyData = await db.getAllDirty();
      if (dirtyData == null || dirtyData.isEmpty) return true;
      try {
        final res = await postData(dirtyData);
        if (res.succeded.isNotEmpty) {
          // Update revision and dirty for all successful saves
          await handleSuccessfullSync(res.succeded, dirtyData);
        }
        if (res.failed.isNotEmpty) {
          // If we have failed a fetch from backend needs to be performed
          await handleFailedSync(res.failed);
        }
      } catch (e) {
        log.warning('Failed to synchronize $path with backend', e);
        return false;
      }
      return true;
    });
  }

  @visibleForTesting
  Future<DataUpdateResponse> postData(
    Iterable<DbModel<M>> data,
  ) async {
    final response = await client.post(
      '$baseUrl/api/v$postApiVersion/data/$userId/$postPath'.toUri(),
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

  @protected
  Future handleFailedSync(Iterable<DataRevisionUpdate> failed) async {
    log.warning('Sync contained ${failed.length} failed items');
    final minRevision = failed.map((f) => f.revision).reduce(math.min);
    final latestRevision = await db.getLastRevision();
    final revision = math.min(minRevision, latestRevision);
    final fetchedData = await fetchData(revision);
    await db.insert(fetchedData);
  }

  @protected
  Future handleSuccessfullSync(
    Iterable<DataRevisionUpdate> succeeded,
    Iterable<DbModel<M>> dirtyData,
  ) async {
    final dirtyDataMap = Map<String, DbModel<M>>.fromIterable(
      dirtyData,
      key: (data) => data.model.id,
    );
    final toUpdate = await Future.wait(
      succeeded.map(
        (success) => _updateDataItemWithNewRevision(success, dirtyDataMap),
      ),
    );
    await db.insert(toUpdate);
  }

  Future<DbModel<M>> _updateDataItemWithNewRevision(
    DataRevisionUpdate dataRevisionUpdate,
    Map<String, DbModel<M>> dirtyDataMap,
  ) async {
    final dataBeforeSync = dirtyDataMap[dataRevisionUpdate.id];
    final currentData = await db.getById(dataRevisionUpdate.id);
    final dirtyDiff = currentData.dirty - dataBeforeSync.dirty;
    return currentData.copyWith(
      revision: dataRevisionUpdate.revision,
      // The data might have been fetched from backend during the sync and reset with dirty = 0.
      dirty: math.max(dirtyDiff, 0),
    );
  }
}
