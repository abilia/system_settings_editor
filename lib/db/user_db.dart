import 'package:seagull/db/sembast.dart';
import 'package:seagull/models.dart';
import 'package:sembast/sembast.dart';

class UserDb {
  static const String _USER_RECORD = 'user';
  final _store = StoreRef.main();
  Future<Database> get _db async => await SembastDb.instance.database;

  insertUser(User user) async {
    print('Insert user to db');
    await _store.record(_USER_RECORD).put(await _db, user.toJson());
  }

  Future<User> getUser() async {
    print('Get user from db');
    var user = await _store.record(_USER_RECORD).get(await _db) as Map;
    if (user == null) {
      throw Exception("No user in db");
    }
    return User.fromJson(user);
  }

  removeUser() async {
    await _store.record(_USER_RECORD).delete(await _db);
  }
}
