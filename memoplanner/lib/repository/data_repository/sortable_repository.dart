import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';

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
            filter: (sortable) =>
                SortableType.supportedTypes.contains(sortable.model.type));

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

  Future<bool> applyTemplate(
    String language, {
    String name = 'memoplanner',
  }) async {
    final templateResponse = await client.get(
      '$baseUrl/api/v1/base-data'.toUri(),
      headers: jsonHeader,
    );
    if (templateResponse.statusCode != 200) {
      log.severe('could not get base-data set '
          '${templateResponse.statusCode} '
          '${templateResponse.body}');
      return false;
    }

    final templateResponseJson = templateResponse.json() as List<dynamic>;
    final template = templateResponseJson
        .exceptionSafeMap(
          BaseDataTemplate.fromJson,
          onException: log.logAndReturnNull,
        )
        .whereNotNull()
        .firstWhereOrNull(
          (t) => t.language == language && t.name.contains(name),
        );

    if (template == null) {
      log.severe(
        'no templates applicable to $language in $templateResponseJson',
      );

      return false;
    }

    final applyResponse = await client.post(
      '$baseUrl/api/v1/entity/$userId/apply-base-data/${template.id}'.toUri(),
      headers: jsonHeader,
    );
    switch (applyResponse.statusCode) {
      case 200:
        log.info('succesfully applied $template to user $userId');
        return true;
      case 409:
        log.warning(
          'conflict when trying to apply starter set '
          '${applyResponse.body}',
        );
    }
    return false;
  }

  @override
  Future<Iterable<Sortable<SortableData>>> getAll() => db.getAllNonDeleted();
}