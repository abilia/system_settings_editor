import 'dart:convert';

import 'package:memoplanner/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDb {
  static const String _userRecord = 'user';
  final SharedPreferences prefs;

  const UserDb(this.prefs);

  Future insertUser(User user) =>
      prefs.setString(_userRecord, json.encode(user.toJson()));

  User? getUser() {
    final userString = prefs.getString(_userRecord);
    return userString == null ? null : User.fromJson(json.decode(userString));
  }

  Future deleteUser() => prefs.remove(_userRecord);
}
