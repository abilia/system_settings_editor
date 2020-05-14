import 'dart:convert';

import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDb {
  static const String _USER_RECORD = 'user';

  Future insertUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_USER_RECORD, json.encode(user.toJson()));
  }

  Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return User.fromJson(json.decode(prefs.getString(_USER_RECORD)));
  }

  Future deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_USER_RECORD);
  }
}
