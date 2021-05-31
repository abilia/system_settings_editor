// @dart=2.9

import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

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

  Future<Sortable> generateUploadFolder() async {
    return synchronized(() async {
      final all = await db.getAllNonDeleted();
      final root = all.where((s) => s.groupId == null).toList();
      root.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final sortOrder = root.isEmpty
          ? getStartSortOrder()
          : calculateNextSortOrder(root.first.sortOrder, -1);

      final sortableData = ImageArchiveData(
        name: 'myAbilia',
        icon: '',
        upload: true,
      );

      final upload = Sortable.createNew<ImageArchiveData>(
        data: sortableData,
        groupId: null,
        isGroup: true,
        sortOrder: sortOrder,
      );
      await db.insertAndAddDirty([upload]);
      return upload;
    });
  }
}
