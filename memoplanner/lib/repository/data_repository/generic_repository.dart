import 'package:collection/collection.dart';
import 'package:http/http.dart';

import 'package:logging/logging.dart';
import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';

class GenericRepository extends DataRepository<Generic> {
  final GenericDb genericDb;

  GenericRepository({
    required BaseUrlDb baseUrlDb,
    required BaseClient client,
    required int userId,
    required this.genericDb,
  }) : super(
          client: client,
          baseUrlDb: baseUrlDb,
          path: 'generics',
          postPath: 'generics',
          userId: userId,
          db: genericDb,
          fromJsonToDataModel: DbGeneric.fromJson,
          log: Logger((GenericRepository).toString()),
        );

  @override
  Future<bool> save(Iterable<Generic> data) async {
    if (Config.isMP) return super.save(data);
    log.fine('$path - ${Config.flavor.name} - will only sync syncable');

    final shouldNotSync = groupBy<Generic, bool>(
      data,
      (d) => MemoplannerSettings.noSyncSettings.contains(d.data.identifier),
    );

    final notSync = shouldNotSync[true];
    if (notSync != null) {
      log.fine('$path - ${Config.flavor.name} - no sync store: $notSync');
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
      log.fine('$path - ${Config.flavor.name} - storing for sync: $syncables');
      return db.insertAndAddDirty(syncables);
    }
    return false;
  }

  @override
  Future<Iterable<Generic>> getAll() => genericDb.getAllNonDeletedMaxRevision();

  @override
  Future fetchIntoDatabase() async {
    log.fine('loading $path...');
    try {
      final revision = await db.getLastRevision();
      final fetchedData = await fetchData(revision);
      log.fine('${fetchedData.length} $path fetched');

      if (fetchedData.isEmpty) return;
      if (revision < 1) {
        log.fine('$path revision is $revision, will sync all $path');
        return db.insert(fetchedData);
      }

      log.fine(
        '$path revision is $revision, will only sync syncable settings',
      );
      final syncSettings = fetchedData.where(
        (generic) => !MemoplannerSettings.noSyncSettings.contains(
          generic.model.data.identifier,
        ),
      );

      if (syncSettings.isEmpty) return;
      return db.insert(syncSettings);
    } catch (e) {
      log.severe('Error when syncing $path, offline?', e);
    }
  }
}
