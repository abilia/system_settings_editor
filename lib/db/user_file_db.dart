import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/db/all.dart';

import 'all.dart';

class UserFileDb extends DataDb<UserFile> {
  UserFileDb(Database database) : super(database);

  @override
  String get tableName => DatabaseRepository.USER_FILE_TABLE_NAME;

  String get _WHERE_file_loaded =>
      'SELECT * FROM $tableName WHERE file_loaded =';

  String get GET_ALL_WITH_MISSING_FILES => '$_WHERE_file_loaded 0';

  String missingFilesWithLimit(int limit) =>
      '$GET_ALL_WITH_MISSING_FILES LIMIT $limit';

  String get GET_ALL_WITH_LOADED_FILES => '$_WHERE_file_loaded 1';

  String get SET_FILE_LOADED =>
      'UPDATE $tableName SET file_loaded = 1 WHERE id = ?';

  @override
  DbMapTo<UserFile> get convertToDataModel => DbUserFile.fromDbMap;

  Future<Iterable<UserFile>> getMissingFiles({int limit}) async {
    final result = await db.rawQuery(limit != null
        ? missingFilesWithLimit(limit)
        : GET_ALL_WITH_MISSING_FILES);
    return result.map(convertToDataModel).map((data) => data.model);
  }

  Future<Iterable<UserFile>> getAllLoadedFiles() async {
    final result = await db.rawQuery(GET_ALL_WITH_LOADED_FILES);
    return result.map(convertToDataModel).map((data) => data.model);
  }

  void setFileLoadedForId(String id) async {
    await db.rawQuery(SET_FILE_LOADED, [id]);
  }

  final _log = Logger((UserFileDb).toString());
  @override
  Logger get log => _log;
}
