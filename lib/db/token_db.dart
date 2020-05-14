import 'package:shared_preferences/shared_preferences.dart';

// Handles storage of auth token used when accessing backend.
// NOTE: there was a problem when accessing secure storage when app in background.
// Therefore shared preferences is used instead.
class TokenDb {
  final String _tokenKey = 'tokenKey';

  Future persistToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
