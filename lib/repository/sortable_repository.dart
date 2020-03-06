import 'dart:convert';

import 'package:http/src/base_client.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/dynamic_repository.dart';

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
      await sortableDb.insertSortables(fetchedSortables);
    } catch (e) {
      print('Error when syncing sortables $e');
    }
    return sortableDb.getSortables();
  }

  Future<Iterable<DbSortable>> _fetchSortables(int revision) async {
    final response = await httpClient.get(
        '$baseUrl/api/v1/data/$userId/sortableitems?revision=$revision',
        headers: authHeader(authToken));
    return (json.decode(response.body) as List)
        .map((e) => DbSortable.fromJson(e));
  }

  @override
  Future<void> save(Iterable<Sortable> data) {
    // TODO: implement save
    return null;
  }

  @override
  Future<bool> synchronize() {
    // TODO: implement synchronize
    return null;
  }
}
