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

class SortableRepository extends DataRepository<Sortable> {
  static final _log = Logger((SortableRepository).toString());
  final int userId;
  final SortableDb sortableDb;
  final String authToken;

  SortableRepository({
    String baseUrl,
    @required BaseClient client,
    @required this.sortableDb,
    @required this.userId,
    @required this.authToken,
  }) : super(client, baseUrl);

  @override
  Future<Iterable<Sortable>> load() async {
    _log.fine('loadning sortables...');
    return synchronized(() async {
      try {
        final fetchedSortables =
            await _fetchSortables(await sortableDb.getLastRevision());
        _log.fine('sortables ${fetchedSortables.length} loaded');
        await sortableDb.insert(fetchedSortables);
      } catch (e) {
        _log.severe('Error when loading sortables', e);
      }
      return sortableDb.getAllNonDeleted();
    });
  }

  Future<Iterable<DbSortable>> _fetchSortables(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/sortableitems?revision=$revision',
        headers: authHeader(authToken));
    _log.finest(response.body);
    return (json.decode(response.body) as List)
        .map((e) => DbSortable.fromJson(e));
  }

  @override
  Future<void> save(Iterable<Sortable> sortables) {
    return sortableDb.insertAndAddDirty(sortables);
  }

  @override
  Future<bool> synchronize() async {
    return synchronized(() async {
      final dirtySortables = await sortableDb.getAllDirty();
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
        _log.warning('Failed to synchronize sortables with backend', e);
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
      final currentSortable = await sortableDb.getById(success.id);
      final dirtyDiff = currentSortable.dirty - sortableBeforeSync.dirty;
      return currentSortable.copyWith(
        revision: success.revision,
        dirty: max(dirtyDiff,
            0), // The activity might have been fetched from backend during the sync and reset with dirty = 0.
      );
    });
    await sortableDb.insert(await Future.wait(toUpdate));
  }

  Future _handleFailedSync(Iterable<DataRevisionUpdates> failed) async {
    final minRevision = failed.map((f) => f.revision).reduce(min);
    final latestRevision = await sortableDb.getLastRevision();
    final fetchedSortables =
        await _fetchSortables(min(minRevision, latestRevision));
    await sortableDb.insert(fetchedSortables);
  }

  Future<DataUpdateResponse> _postSortables(
      Iterable<DbModel<Sortable>> sortables) async {
    final response = await httpClient.post(
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
      final all = await sortableDb.getAllNonDeleted();
      final root = all.where((s) => s.groupId == null).toList();
      root.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final sortOrder = root.isEmpty
          ? getStartSortOrder()
          : calculateNextSortOrder(root.first.sortOrder, -1);

      final sortableData = SortableData(
        name: 'myAbilia',
        icon: '',
        upload: true,
      ).toJson();

      final upload = Sortable.createNew(
        type: SortableType.imageArchive,
        data: json.encode(sortableData),
        groupId: null,
        isGroup: true,
        sortOrder: sortOrder,
      );
      await sortableDb.insertAndAddDirty([upload]);
      return upload;
    });
  }
}
