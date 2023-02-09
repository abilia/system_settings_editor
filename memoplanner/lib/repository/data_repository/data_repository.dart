import 'dart:convert';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:synchronized/extension.dart';

typedef JsonToDataModel<M extends DataModel> = DbModel<M> Function(
    Map<String, dynamic> json);

bool _noFilter(_) => true;

abstract class DataRepository<M extends DataModel> extends Repository {
  const DataRepository({
    required super.client,
    required super.baseUrlDb,
    required this.path,
    required this.userId,
    required this.db,
    required this.fromJsonToDataModel,
    required this.log,
    this.filter = _noFilter,
    this.postApiVersion = 1,
    String? postPath,
  }) : postPath = postPath ?? path;

  final DataDb<M> db;
  final int userId;
  final Logger log;
  final String path, postPath;
  final int postApiVersion;
  final JsonToDataModel<M> fromJsonToDataModel;
  final bool Function(DbModel<M>) filter;

  /// returns true if any data need to be synced after saved
  Future<bool> save(Iterable<M> data) => db.insertAndAddDirty(data);

  Future<Iterable<M>> getAll();

  Future<void> fetchIntoDatabaseSynchronized() =>
      synchronized(fetchIntoDatabase);

  Future<bool> fetchIntoDatabase() async {
    log.fine('loading $path...');
    try {
      final revision = await db.getLastRevision();
      final fetchedData = await fetchData(revision);
      log.fine('${fetchedData.length} $path fetched');
      await db.insert(fetchedData);
      return fetchedData.isNotEmpty;
    } catch (e) {
      log.severe('Error when syncing $path, offline?', e);
    }
    return false;
  }

  @protected
  Future<Iterable<DbModel<M>>> fetchData(int revision) async {
    log.fine('fetching $path for revision $revision');
    final response = await client.get(
      '$baseUrl/api/v1/data/$userId/$path?revision=$revision'.toUri(),
    );
    final decoded = response.json() as List;
    return decoded
        .exceptionSafeMap(
          (j) => fromJsonToDataModel(j),
          onException: log.logAndReturnNull,
        )
        .whereNotNull()
        .where(filter);
  }

  Future<bool> synchronize() async {
    return synchronized(() async {
      final didFetchData = await fetchIntoDatabase();
      final dirtyData = await db.getAllDirty();
      if (dirtyData.isEmpty) return didFetchData;
      try {
        final res = await postData(dirtyData);
        if (res.succeeded.isNotEmpty) {
          // Update revision and dirty for all successful saves
          await handleSuccessfulSync(res.succeeded, dirtyData);
        }
        if (res.failed.isNotEmpty) {
          // If we have failed a fetch from backend needs to be performed
          await handleFailedSync(res.failed);
        }
      } on BadRequestException catch (e, stacktrace) {
        log.severe(
          'Failed to synchronize with a BadRequestException',
          e.badRequest,
          stacktrace,
        );
      } catch (e) {
        log.warning('Failed to synchronize $path with backend', e);
        rethrow;
      }
      return didFetchData;
    });
  }

  @visibleForTesting
  Future<DataUpdateResponse> postData(
    Iterable<DbModel<M>> data,
  ) async {
    final response = await client.post(
      '$baseUrl/api/v$postApiVersion/data/$userId/$postPath'.toUri(),
      headers: jsonHeader,
      body: jsonEncode(data.toList()),
    );

    if (response.statusCode == 200) {
      final dataUpdateResponse = DataUpdateResponse.fromJson(response.json());
      return dataUpdateResponse;
    } else if (response.statusCode == 400) {
      throw BadRequestException(
        badRequest: BadRequest.fromJson(
          response.json(),
        ),
      );
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
  Future handleSuccessfulSync(
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
    await db.insert(toUpdate.whereNotNull());
  }

  Future<DbModel<M>?> _updateDataItemWithNewRevision(
    DataRevisionUpdate dataRevisionUpdate,
    Map<String, DbModel<M>> dirtyDataMap,
  ) async {
    final dataBeforeSync = dirtyDataMap[dataRevisionUpdate.id];
    final currentData = await db.getById(dataRevisionUpdate.id);
    if (dataBeforeSync == null || currentData == null) {
      log.severe(
        '${dataRevisionUpdate.id} not found in database or $dirtyDataMap',
      );
      return null;
    }
    final dirtyDiff = currentData.dirty - dataBeforeSync.dirty;
    return currentData.copyWith(
      revision: dataRevisionUpdate.revision,
      // The data might have been fetched from backend during the sync and reset with dirty = 0.
      dirty: math.max(dirtyDiff, 0),
    );
  }
}
