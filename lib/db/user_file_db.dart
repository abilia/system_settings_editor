import 'package:seagull/models/all.dart';

import 'all.dart';

class UserFileDb extends DataDb<UserFile> {
  static const USER_FILE_TABLE_NAME = 'user_file';

  @override
  Future<Iterable<DbModel<UserFile>>> getAllDirty() {
    // TODO: implement getAllDirty
    return null;
  }

  @override
  Future<Iterable<UserFile>> getAllNonDeleted() {
    // TODO: implement getAllNonDeleted
    return null;
  }

  @override
  Future<DbModel<UserFile>> getById(String id) {
    // TODO: implement getById
    return null;
  }

  @override
  Future<int> getLastRevision() {
    // TODO: implement getLastRevision
    return null;
  }

  @override
  Future<Iterable<int>> insert(Iterable<DbModel<UserFile>> data) {
    // TODO: implement insert
    return null;
  }

  @override
  insertAndAddDirty(Iterable<UserFile> userFiles) async {
    return insertWithDirtyAndRevision(userFiles, USER_FILE_TABLE_NAME);
  }
}
