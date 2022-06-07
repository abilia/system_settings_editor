import 'package:collection/collection.dart';
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
    required int userId,
    required SortableDb sortableDb,
  }) : super(
          client: client,
          baseUrlDb: baseUrlDb,
          path: 'sortableitems',
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
        headers: jsonHeader,
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

  // TODO exception safet this function
  Future<bool> applyTemplate(
    String language, {
    String name = 'memoplanner',
  }) async {
    final temlateResponse = await client.get(
      '$baseUrl/api/v1/base-data'.toUri(),
      headers: jsonHeader,
    );
    if (temlateResponse.statusCode != 200) {
      return false;
    }

    final template = (temlateResponse.json() as List<dynamic>)
        .exceptionSafeMap(
          BaseDataTemplate.fromJson,
          onException: log.logAndReturnNull,
        )
        .whereNotNull()
        .firstWhereOrNull(
          (t) => t.language == language && t.name.contains(name),
        );

    if (template == null) return false;

    final applyResponse = await client.post(
      '$baseUrl/api/v1/entity/$userId/apply-base-data/${template.id}'.toUri(),
      headers: jsonHeader,
    );

    return applyResponse.statusCode == 200;
  }
}
