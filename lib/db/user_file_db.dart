import 'package:seagull/models/all.dart';

import 'all.dart';

class UserFileDb extends DataDb<UserFile> {
  @override
  String get tableName => 'user_file';
  @override
  DbMapTo<UserFile> get convertToDataModel => DbUserFile.fromDbMap;
}
