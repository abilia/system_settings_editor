// @dart=2.9

import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

import '../all.dart';

class SortableRepository extends DataRepository<Sortable> {
  SortableRepository({
    @required String baseUrl,
    @required BaseClient client,
    @required String authToken,
    @required int userId,
    @required SortableDb sortableDb,
  }) : super(
          client: client,
          baseUrl: baseUrl,
          path: 'sortableitems',
          authToken: authToken,
          userId: userId,
          db: sortableDb,
          fromJsonToDataModel: DbSortable.fromJson,
          log: Logger((SortableRepository).toString()),
        );
}
