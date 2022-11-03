import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/db/all.dart';

class UserFileDb extends DataDb<UserFile> {
  UserFileDb(Database database) : super(database);

  @override
  String get tableName => DatabaseRepository.userFileTableName;

  String get _whereFileLoaded => 'SELECT * FROM $tableName WHERE file_loaded =';

  String get getAllWithMissingFiles => '$_whereFileLoaded 0';

  String missingFilesWithLimit(int limit) =>
      '$getAllWithMissingFiles LIMIT $limit';

  String get getAllWithLoadedFiles => '$_whereFileLoaded 1';

  String get setFileLoaded =>
      'UPDATE $tableName SET file_loaded = 1 WHERE id = ?';

  @override
  DbMapTo<UserFile> get convertToDataModel => DbUserFile.fromDbMap;

  Future<Iterable<UserFile>> getMissingFiles({int? limit}) async {
    final result = await db.rawQuery(
      limit != null ? missingFilesWithLimit(limit) : getAllWithMissingFiles,
    );
    return result.map(convertToDataModel).map((data) => data.model);
  }

  Future<Iterable<UserFile>> getAllLoadedFiles() async {
    final result = await db.rawQuery(getAllWithLoadedFiles);
    return result.map(convertToDataModel).map((data) => data.model);
  }

  Future setFileLoadedForId(String id) async {
    await db.rawQuery(setFileLoaded, [id]);
  }

  final _log = Logger((UserFileDb).toString());
  @override
  Logger get log => _log;
}
