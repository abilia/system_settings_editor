import 'dart:async';

import 'package:collection/collection.dart';
import 'package:generics/generics.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:repository_base/repository_base.dart';

class GenericRepository extends DataRepository<Generic> {
  final GenericDb genericDb;
  final Set<String> noSyncSettings;

  GenericRepository({
    required BaseUrlDb baseUrlDb,
    required BaseClient client,
    required int userId,
    required this.genericDb,
    required this.noSyncSettings,
  }) : super(
          client: client,
          baseUrlDb: baseUrlDb,
          path: 'generics',
          postPath: 'generics',
          userId: userId,
          db: genericDb,
          fromJsonToDataModel: DbGeneric.fromJson,
          log: Logger((GenericRepository).toString()),
          filter: (g) => g.model.type == GenericType.memoPlannerSettings,
        );

  @override
  Future<bool> save(Iterable<Generic> data) async {
    if (noSyncSettings.isEmpty) return super.save(data);
    log.fine('$path - will only sync syncable');

    final shouldNotSync = groupBy<Generic, bool>(
      data,
      (d) => noSyncSettings.contains(d.data.identifier),
    );

    final notSync = shouldNotSync[true];
    if (notSync != null) {
      log.fine('$path - no sync store: $notSync');
      final localStore = await Future.wait(
        notSync.map(
          (e) async => e.wrapWithDbModel(
              revision: (await db.getById(e.id))?.revision ?? 0),
        ),
      );
      await db.insert(localStore.whereType<DbModel<Generic>>());
    }

    final syncables = shouldNotSync[false];
    if (syncables != null) {
      log.fine('$path - storing for sync: $syncables');
      return db.insertAndAddDirty(syncables);
    }
    return false;
  }

  Future<Iterable<Generic>> getAll() => genericDb.getAllNonDeletedMaxRevision();

  @override
  Future<bool> fetchIntoDatabase() async {
    log.fine('loading $path...');
    try {
      final revision = await db.getLastRevision();
      final fetchedData = await fetchData(revision);
      log.fine('${fetchedData.length} $path fetched');

      if (fetchedData.isEmpty) return false;
      if (revision < 1) {
        log.fine('$path revision is $revision, will sync all $path');
        await db.insert(fetchedData);
        return fetchedData.isNotEmpty;
      }

      log.fine(
        '$path revision is $revision, will only sync syncable settings',
      );
      final syncSettings = fetchedData.where(
        (generic) => !noSyncSettings.contains(
          generic.model.data.identifier,
        ),
      );

      if (syncSettings.isEmpty) return false;
      await db.insert(syncSettings);
      return syncSettings.isNotEmpty;
    } catch (e) {
      log.severe('Error when syncing $path, offline?', e);
    }
    return false;
  }
}
