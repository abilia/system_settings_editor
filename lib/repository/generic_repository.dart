import 'dart:convert';
import 'dart:math';

import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import 'all.dart';

class GenericRepository extends DataRepository<Generic> {
  static final _log = Logger((GenericRepository).toString());
  final int userId;
  GenericDb get genericDb => db as GenericDb;
  final String authToken;

  GenericRepository({
    String baseUrl,
    @required BaseClient client,
    @required GenericDb genericDb,
    @required this.userId,
    @required this.authToken,
  }) : super(client, baseUrl, genericDb);

  @override
  Future<Iterable<Generic>> load() async {
    _log.fine('loadning generics...');
    return synchronized(() async {
      try {
        final fetchedGenerics =
            await _fetchGenerics(await db.getLastRevision());
        _log.fine('generics ${fetchedGenerics.length} loaded');
        await db.insert(fetchedGenerics);
      } catch (e) {
        _log.severe('Error when loading generics', e);
      }
      return genericDb.getAllNonDeletedMaxRevision();
    });
  }

  Future<Iterable<DbGeneric>> _fetchGenerics(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/generics?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .exceptionSafeMap(
          (e) => DbGeneric.fromJson(e),
          onException: _log.logAndReturnNull,
        )
        .filterNull();
  }

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      final dirtyGenerics = await db.getAllDirty();
      if (dirtyGenerics.isEmpty) return true;
      final res = await _postGenerics(dirtyGenerics);
      try {
        if (res.succeded.isNotEmpty) {
          await _handleSuccessfullSync(res.succeded, dirtyGenerics);
        }
        if (res.failed.isNotEmpty) {
          await _handleFailedSync(res.failed);
        }
      } catch (e) {
        _log.warning('Failed to synchronize generics with backend', e);
        return false;
      }
      return true;
    });
  }

  Future _handleSuccessfullSync(Iterable<DataRevisionUpdates> succeeded,
      Iterable<DbModel<Generic>> dirtyGenerics) async {
    final toUpdate = succeeded.map((success) async {
      final genericBeforeSync =
          dirtyGenerics.firstWhere((generic) => generic.model.id == success.id);
      final currentGeneric = await db.getById(success.id);
      final dirtyDiff = currentGeneric.dirty - genericBeforeSync.dirty;
      return currentGeneric.copyWith(
        revision: success.revision,
        dirty: max(dirtyDiff,
            0), // The generic might have been fetched from backend during the sync and reset with dirty = 0.
      );
    });
    await db.insert(await Future.wait(toUpdate));
  }

  Future _handleFailedSync(Iterable<DataRevisionUpdates> failed) async {
    final minRevision = failed.map((f) => f.revision).reduce(min);
    final latestRevision = await db.getLastRevision();
    final fetchedGenerics =
        await _fetchGenerics(min(minRevision, latestRevision));
    await db.insert(fetchedGenerics);
  }

  Future<DataUpdateResponse> _postGenerics(
      Iterable<DbModel<Generic>> generics) async {
    final response = await httpClient.post(
      '$baseUrl/api/v1/data/$userId/genericitems',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(generics.toList()),
    );

    if (response.statusCode == 200) {
      return DataUpdateResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw UnavailableException([response.statusCode]);
  }
}
