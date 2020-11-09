import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Handles storage of auth token used when accessing backend.
// NOTE: there was a problem when accessing secure storage when app in background.
// Therefore shared preferences is used instead.
class TokenDb {
  @visibleForTesting
  static const String tokenKey = 'tokenKey';
  final SharedPreferences prefs;

  const TokenDb(this.prefs);

  Future persistToken(String token) => prefs.setString(tokenKey, token);

  String getToken() {
    try {
      return prefs.getString(tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future delete() => prefs.remove(tokenKey);
}
