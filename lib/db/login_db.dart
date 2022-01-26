import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Handles storage of auth token and other login info used when accessing backend.
// NOTE: there was a problem when accessing secure storage when app in background.
// Therefore shared preferences is used instead.
class LoginDb {
  @visibleForTesting
  static const String tokenKey = 'tokenKey';
  static const String loginInfoKey = 'loginInfoKey';
  final SharedPreferences prefs;

  const LoginDb(this.prefs);

  Future<void> persistToken(String token) => prefs.setString(tokenKey, token);
  String? getToken() => prefs.getString(tokenKey);
  Future<void> deleteToken() => prefs.remove(tokenKey);

  Future<void> persistLoginInfo(LoginInfo loginInfo) =>
      prefs.setString(loginInfoKey, jsonEncode(loginInfo.toJson()));
  LoginInfo? getLoginInfo() {
    final loginInfoString = prefs.getString(loginInfoKey);
    if (loginInfoString != null) {
      return LoginInfo.fromJson(jsonDecode(loginInfoString));
    }
    return null;
  }

  Future<void> deleteLoginInfo() => prefs.remove(loginInfoKey);
}
