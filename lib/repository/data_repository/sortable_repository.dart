import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

class SortableRepository extends DataRepository<Sortable> {
  static const mobileUploadPath = 'mobile-uploads-folder',
      myPhotosPath = 'my-photos-folder';
  SortableRepository({
    required BaseUrlDb baseUrlDb,
    required BaseClient client,
    required String authToken,
    required int userId,
    required SortableDb sortableDb,
  }) : super(
          client: client,
          baseUrlDb: baseUrlDb,
          path: 'sortableitems',
          authToken: authToken,
          userId: userId,
          db: sortableDb,
          fromJsonToDataModel: DbSortable.fromJson,
          log: Logger((SortableRepository).toString()),
        );

  Future<DbModel<Sortable<SortableData>>?> createMyPhotosFolder() =>
      _fetchFixedFolder(
        myPhotosPath,
      );

  Future<DbModel<Sortable<SortableData>>?> createUploadsFolder() =>
      _fetchFixedFolder(
        mobileUploadPath,
      );

  Future<DbModel<Sortable<SortableData>>?> _fetchFixedFolder(
      String folder) async {
    try {
      final response = await client.get(
        '$baseUrl/api/v1/data/$userId/$postPath/$folder'.toUri(),
        headers: jsonAuthHeader(authToken),
      );
      if (response.statusCode == 200) {
        return fromJsonToDataModel(response.json());
      }
      log.warning('Could not fetch $folder ${response.statusCode}');
      log.warning(response.body);
    } catch (e) {
      log.warning('Could not parse fixed folder $folder', e);
    }
    return null;
  }
}
