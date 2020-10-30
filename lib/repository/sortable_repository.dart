import 'dart:convert';
import 'dart:math' as math;

import 'package:http/src/base_client.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/extension.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';

import 'all.dart';

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
          fromJson: DbSortable.fromJson,
          log: Logger((SortableRepository).toString()),
        );

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      final dirtySortables = await db.getAllDirty();
      if (dirtySortables.isEmpty) return true;
      final res = await _postSortables(dirtySortables);
      try {
        if (res.succeded.isNotEmpty) {
          await _handleSuccessfullSync(res.succeded, dirtySortables);
        }
        if (res.failed.isNotEmpty) {
          await _handleFailedSync(res.failed);
        }
      } catch (e) {
        log.warning('Failed to synchronize sortables with backend', e);
        return false;
      }
      return true;
    });
  }

  Future _handleSuccessfullSync(Iterable<DataRevisionUpdates> succeeded,
      Iterable<DbModel<Sortable>> dirtySortables) async {
    final toUpdate = succeeded.map((success) async {
      final sortableBeforeSync = dirtySortables
          .firstWhere((sortable) => sortable.model.id == success.id);
      final currentSortable = await db.getById(success.id);
      final dirtyDiff = currentSortable.dirty - sortableBeforeSync.dirty;
      return currentSortable.copyWith(
        revision: success.revision,
        dirty: math.max(dirtyDiff,
            0), // The activity might have been fetched from backend during the sync and reset with dirty = 0.
      );
    });
    await db.insert(await Future.wait(toUpdate));
  }

  Future _handleFailedSync(Iterable<DataRevisionUpdates> failed) async {
    final minRevision = failed.map((f) => f.revision).reduce(math.min);
    final latestRevision = await db.getLastRevision();
    final fetchedSortables =
        await fetchData(math.min(minRevision, latestRevision));
    await db.insert(fetchedSortables);
  }

  Future<DataUpdateResponse> _postSortables(
      Iterable<DbModel<Sortable>> sortables) async {
    final response = await client.post(
      '$baseUrl/api/v1/data/$userId/sortableitems',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(sortables.toList()),
    );

    if (response.statusCode == 200) {
      return DataUpdateResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw UnavailableException([response.statusCode]);
  }

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
