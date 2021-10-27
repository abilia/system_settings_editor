import 'dart:convert';

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
    required String baseUrl,
    required BaseClient client,
    required String authToken,
    required int userId,
    required SortableDb sortableDb,
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

  Future<void> createMyPhotosFolder() => _createFixedFolder(
        myPhotosPath,
        fallback: Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(myPhotos: true),
          sortOrder: startSordOrder,
          isGroup: true,
          fixed: true,
        ),
      );

  Future<void> createUploadsFolder() => _createFixedFolder(
        mobileUploadPath,
        fallback: Sortable.createNew<ImageArchiveData>(
          data: const ImageArchiveData(upload: true),
          sortOrder: startSordOrder,
          isGroup: true,
          fixed: true,
        ),
      );

  Future<void> _createFixedFolder(
    String folder, {
    required Sortable<SortableData> fallback,
  }) async {
    if (!await _fetchFixedFolder(folder)) {
      if (await save([fallback])) {
        await synchronize();
      }
    }
  }

  Future<bool> _fetchFixedFolder(String folder) async {
    try {
      final response = await client.get(
        '$baseUrl/api/v1/data/$userId/$postPath/$folder'.toUri(),
        headers: jsonAuthHeader(authToken),
      );
      if (response.statusCode == 200) {
        db.insert([fromJsonToDataModel(json.decode(response.body))]);
        return true;
      }
      log.warning('Could not fetch $folder ${response.statusCode}');
      log.warning(response.body);
    } catch (e) {
      log.warning('Could not parse fixed folder $folder', e);
    }
    return false;
  }
}
