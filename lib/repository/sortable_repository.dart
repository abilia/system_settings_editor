import 'dart:convert';
import 'dart:math';

import 'package:http/src/base_client.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

import 'all.dart';

class SortableRepository extends DataRepository<Sortable> {
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

  Future<Iterable<Sortable>> load() async {
    try {
      final fetchedSortables =
          await _fetchSortables(await sortableDb.getLastRevision());
      await sortableDb.insert(fetchedSortables);
    } catch (e) {
      print('Error when loading sortables $e');
    }
    return sortableDb.getAllNonDeleted();
  }

  Future<Iterable<DbSortable>> _fetchSortables(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/sortableitems?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => DbSortable.fromJson(e));
  }

  @override
  Future<void> save(Iterable<Sortable> sortables) =>
      sortableDb.insertAndAddDirty(sortables);

  @override
  Future<bool> synchronize() async {
    final dirtySortables = await sortableDb.getAllDirty();
    print('Found dirty sortables: ${dirtySortables}');
    if (dirtySortables.isEmpty) return true;
    final res = await postSortables(dirtySortables);
    try {
      if (res.succeded.isNotEmpty) {
        await _handleSuccessfullSync(res.succeded, dirtySortables);
      }
      if (res.failed.isNotEmpty) {
        await _handleFailedSync(res.failed);
      }
    } catch (e) {
      print('Failed to synchronize sortables with backend $e');
      return false;
    }
    return true;
  }

  Future _handleSuccessfullSync(Iterable<DataRevisionUpdates> succeeded,
      Iterable<DbModel<Sortable>> dirtySortables) async {
    final toUpdate = succeeded.map((success) async {
      final sortableBeforeSync = dirtySortables
          .firstWhere((sortable) => sortable.model.id == success.id);
      final currentSortable = await sortableDb.getById(success.id);
      return currentSortable.copyWith(
        revision: success.revision,
        dirty: currentSortable.dirty - sortableBeforeSync.dirty,
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

  Future<DataUpdateResponse> postSortables(
      Iterable<DbModel<Sortable>> sortables) async {
    print('Posting sortables: ${sortables}');
    final response = await httpClient.post(
      '$baseUrl/api/v1/data/$userId/sortableitems',
      headers: jsonAuthHeader(authToken),
      body: jsonEncode(sortables.toList()),
    );

    if (response.statusCode == 200) {
      print('Got successful post of sortables');
      return DataUpdateResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw UnavailableException();
  }

  Future<Sortable> generateUploadFolder() async {
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
      sortOrder: 'A',
    );
    await sortableDb.insertAndAddDirty([upload]);
    return upload;
  }
}
