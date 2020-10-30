import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

import 'all.dart';

class GenericRepository extends DataRepository<Generic> {
  final GenericDb genericDb;

  GenericRepository({
    @required String baseUrl,
    @required BaseClient client,
    @required String authToken,
    @required int userId,
    @required this.genericDb,
  }) : super(
          client: client,
          baseUrl: baseUrl,
          path: 'generics',
          postPath: 'genericitems',
          authToken: authToken,
          userId: userId,
          db: genericDb,
          fromJson: DbGeneric.fromJson,
          log: Logger((GenericRepository).toString()),
        );

  @override
  Future<Iterable<Generic>> load() async {
    await fetchIntoDatabase();
    return genericDb.getAllNonDeletedMaxRevision();
  }

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      final dirtyGenerics = await db.getAllDirty();
      if (dirtyGenerics.isEmpty) return true;
      final res = await postData(dirtyGenerics);
      try {
        if (res.succeded.isNotEmpty) {
          await handleSuccessfullSync(res.succeded, dirtyGenerics);
        }
        if (res.failed.isNotEmpty) {
          await handleFailedSync(res.failed);
        }
      } catch (e) {
        log.warning('Failed to synchronize generics with backend', e);
        return false;
      }
      return true;
    });
  }
}
