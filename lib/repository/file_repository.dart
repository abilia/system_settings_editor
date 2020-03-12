import 'package:http/src/base_client.dart';
import 'package:meta/meta.dart';
import 'package:seagull/db/user_file_db.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

class UserFileRepository extends DataRepository<UserFile> {
  final UserFileDb userFileDb;

  UserFileRepository({
    @required BaseClient httpClient,
    @required String baseUrl,
    @required this.userFileDb,
  }) : super(httpClient, baseUrl);

  @override
  Future<Iterable<UserFile>> load() async {
    try {} catch (e) {
      print('Error when loading $e');
    }
    return userFileDb.getAllNonDeleted();
  }

  @override
  Future<void> save(Iterable<UserFile> userFiles) async {
    userFileDb.insertAndAddDirty(userFiles);
  }

  @override
  Future<bool> synchronize() {
    // TODO: implement synchronize
    return null;
  }
}
