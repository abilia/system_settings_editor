import 'dart:convert';

import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDb {
  static const String _USER_RECORD = 'user';

  insertUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_USER_RECORD, json.encode(user.toJson()));
  }

  Future<User> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return User.fromJson(json.decode(prefs.getString(_USER_RECORD)));
  }

  deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_USER_RECORD);
  }
}
