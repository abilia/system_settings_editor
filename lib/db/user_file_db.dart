import 'package:seagull/models/all.dart';
import 'package:sqflite/sqflite.dart';

import 'all.dart';

class UserFileDb extends DataDb<UserFile> {
  static const USER_FILE_TABLE_NAME = 'user_file';
  static const String GET_ALL_DIRTY =
      'SELECT * FROM $USER_FILE_TABLE_NAME WHERE dirty > 0';
  static const String MAX_REVISION_SQL =
      'SELECT max(revision) as max_revision FROM $USER_FILE_TABLE_NAME';
  static const String GET_USER_FILES_SQL =
      'SELECT * FROM $USER_FILE_TABLE_NAME WHERE deleted == 0';
  static const String GET_USER_FILES_BY_ID_SQL =
      'SELECT * FROM $USER_FILE_TABLE_NAME WHERE id == ?';

  @override
  Future<Iterable<DbUserFile>> getAllDirty() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_ALL_DIRTY);
    return result.map((row) => DbUserFile.fromDbMap(row));
  }

  @override
  Future<Iterable<UserFile>> getAllNonDeleted() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_USER_FILES_SQL);
    return result.map((row) => DbUserFile.fromDbMap(row).userFile);
  }

  @override
  Future<DbModel<UserFile>> getById(String id) async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(GET_USER_FILES_BY_ID_SQL, [id]);
    final userFiles = result.map((row) => DbUserFile.fromDbMap(row));
    if (userFiles.length == 1) {
      return userFiles.first;
    } else {
      return null;
    }
  }

  @override
  Future<int> getLastRevision() async {
    final db = await DatabaseRepository().database;
    final result = await db.rawQuery(MAX_REVISION_SQL);
    final revision = result.first['max_revision'];
    if (revision == null) {
      return 0;
    }
    return revision;
  }

  @override
  Future insert(Iterable<DbModel<UserFile>> userFiles) async {
    final db = await DatabaseRepository().database;
    final batch = db.batch();

    await userFiles
        .map(
          (userFile) => userFile.toMapForDb(),
        )
        .forEach(
          (value) => batch.insert(USER_FILE_TABLE_NAME, value,
              conflictAlgorithm: ConflictAlgorithm.replace),
        );

    return batch.commit();
  }

  @override
  insertAndAddDirty(Iterable<UserFile> userFiles) async {
    return insertWithDirtyAndRevision(userFiles, USER_FILE_TABLE_NAME);
  }
}
