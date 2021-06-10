import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

import '../all.dart';

class GenericRepository extends DataRepository<Generic> {
  final GenericDb genericDb;

  GenericRepository({
    required String baseUrl,
    required BaseClient client,
    required String authToken,
    required int userId,
    required this.genericDb,
  }) : super(
          client: client,
          baseUrl: baseUrl,
          path: 'generics',
          postPath: 'generics',
          authToken: authToken,
          userId: userId,
          db: genericDb,
          fromJsonToDataModel: DbGeneric.fromJson,
          log: Logger((GenericRepository).toString()),
        );

  @override
  Future<Iterable<Generic>> load() async {
    await fetchIntoDatabaseSynchronized();
    return genericDb.getAllNonDeletedMaxRevision();
  }
}
