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
    final userString = prefs.getString(_USER_RECORD);
    return userString == null ? null : User.fromJson(json.decode(userString));
  }

  Future deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_USER_RECORD);
  }
}
