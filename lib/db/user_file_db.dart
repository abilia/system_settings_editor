import 'package:seagull/models/all.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'all.dart';

class UserFileDb extends DataDb<UserFile> {
  UserFileDb(Database database) : super(database);

  @override
  String get tableName => 'user_file';

  String get GET_ALL_WITH_MISSING_FILES =>
      'SELECT * FROM $tableName WHERE file_loaded = 0';

  String get SET_FILE_LOADED =>
      'UPDATE $tableName SET file_loaded = 1 WHERE id = ?';

  @override
  DbMapTo<UserFile> get convertToDataModel => DbUserFile.fromDbMap;

  Future<Iterable<UserFile>> getAllWithMissingFiles() async {
    final result = await db.rawQuery(GET_ALL_WITH_MISSING_FILES);
    return result.map(convertToDataModel).map((data) => data.model);
  }

  void setFileLoadedForId(String id) async {
    await db.rawQuery(SET_FILE_LOADED, [id]);
  }
}
