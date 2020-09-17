import 'dart:convert';
import 'dart:math';

import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

import 'all.dart';

class GenericRepository extends DataRepository<Generic> {
  static final _log = Logger((GenericRepository).toString());
  final int userId;
  final GenericDb genericDb;
  final String authToken;

  GenericRepository({
    String baseUrl,
    @required BaseClient client,
    @required this.genericDb,
    @required this.userId,
    @required this.authToken,
  }) : super(client, baseUrl);

  @override
  Future<Iterable<Generic>> load() async {
    _log.fine('loadning generics...');
    return synchronized(() async {
      try {
        final fetchedGenerics =
            await _fetchGenerics(await genericDb.getLastRevision());
        _log.fine('generics ${fetchedGenerics.length} loaded');
        await genericDb.insert(fetchedGenerics);
      } catch (e) {
        _log.severe('Error when loading generics', e);
      }
      return genericDb.getAllNonDeleted();
    });
  }

  Future<Iterable<DbGeneric>> _fetchGenerics(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/generics?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => DbGeneric.fromJson(e));
  }

  @override
  Future<void> save(Iterable<Generic> generics) {
    return genericDb.insertAndAddDirty(generics);
  }

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      final dirtyGenerics = await genericDb.getAllDirty();
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
      final currentGeneric = await genericDb.getById(success.id);
      final dirtyDiff = currentGeneric.dirty - genericBeforeSync.dirty;
      return currentGeneric.copyWith(
        revision: success.revision,
        dirty: max(dirtyDiff,
            0), // The generic might have been fetched from backend during the sync and reset with dirty = 0.
      );
    });
    await genericDb.insert(await Future.wait(toUpdate));
  }

  Future _handleFailedSync(Iterable<DataRevisionUpdates> failed) async {
    final minRevision = failed.map((f) => f.revision).reduce(min);
    final latestRevision = await genericDb.getLastRevision();
    final fetchedGenerics =
        await _fetchGenerics(min(minRevision, latestRevision));
    await genericDb.insert(fetchedGenerics);
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
