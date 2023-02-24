import 'dart:convert';


import 'package:auth/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Handles storage of auth token and other login info used when accessing backend.
// NOTE: there was a problem when accessing secure storage when app in background.
// Therefore shared preferences is used instead.
class LoginDb {
  static const String tokenKey = 'tokenKey';
  static const String loginInfoKey = 'loginInfoKey';
  final SharedPreferences prefs;

  const LoginDb(this.prefs);

  // Token was moved to LoginInfo at 2022-01-27 (MPGO version 1.4)
  // and getToken() and deleteToken() can be deleted when most users
  // have logged in using MPGO 1.4 or above. When removing getting token by tokenKey
  // users that have no LoginInfo will have to login again.
  String? getToken() => getLoginInfo()?.token ?? prefs.getString(tokenKey);
  Future<void> deleteToken() => prefs.remove(tokenKey);

  Future<void> persistLoginInfo(LoginInfo loginInfo) =>
      prefs.setString(loginInfoKey, jsonEncode(loginInfo.toJson()));
  LoginInfo? getLoginInfo() {
    final loginInfoString = prefs.getString(loginInfoKey);
    if (loginInfoString != null) {
      return LoginInfo.fromJson(
        jsonDecode(loginInfoString),
      );
    }
    return null;
  }

  Future<void> deleteLoginInfo() => prefs.remove(loginInfoKey);
}
