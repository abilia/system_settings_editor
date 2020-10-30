import 'dart:convert';
import 'dart:math' as math;

import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

import 'all.dart';

class GenericRepository extends DataRepository<Generic> {
  GenericDb get genericDb => db as GenericDb;

  GenericRepository({
    @required String baseUrl,
    @required BaseClient client,
    @required String authToken,
    @required int userId,
    @required GenericDb genericDb,
  }) : super(
          client: client,
          baseUrl: baseUrl,
          path: 'generics',
          authToken: authToken,
          userId: userId,
          db: genericDb,
          fromJson: DbGeneric.fromJson,
          log: Logger((GenericRepository).toString()),
        );

  @override
  Future<Iterable<Generic>> load() async {
    log.fine('loadning generics...');
    return synchronized(() async {
      try {
        final revision = await db.getLastRevision();
        final fetchedGenerics = await fetchData(revision);
        log.fine('generics ${fetchedGenerics.length} loaded');
        await db.insert(fetchedGenerics);
      } catch (e) {
        log.severe('Error when loading generics', e);
      }
      return genericDb.getAllNonDeletedMaxRevision();
    });
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
        log.warning('Failed to synchronize generics with backend', e);
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
        dirty: math.max(dirtyDiff,
            0), // The generic might have been fetched from backend during the sync and reset with dirty = 0.
      );
    });
    await db.insert(await Future.wait(toUpdate));
  }

  Future _handleFailedSync(Iterable<DataRevisionUpdates> failed) async {
    final minRevision = failed.map((f) => f.revision).reduce(math.min);
    final latestRevision = await db.getLastRevision();
    final revision = math.min(minRevision, latestRevision);
    final fetchedGenerics = await fetchData(revision);
    await db.insert(fetchedGenerics);
  }

  Future<DataUpdateResponse> _postGenerics(
      Iterable<DbModel<Generic>> generics) async {
    final response = await client.post(
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
