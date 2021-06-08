// @dart=2.9

import 'dart:convert';

import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDb {
  static const String _USER_RECORD = 'user';
  final SharedPreferences prefs;

  const UserDb(this.prefs);

  Future insertUser(User user) =>
      prefs.setString(_USER_RECORD, json.encode(user.toJson()));

  User getUser() {
    final userString = prefs.getString(_USER_RECORD);
    return userString == null ? null : User.fromJson(json.decode(userString));
  }

  Future deleteUser() => prefs.remove(_USER_RECORD);
}
