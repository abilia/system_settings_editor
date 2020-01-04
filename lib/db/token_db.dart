import 'package:shared_preferences/shared_preferences.dart';

class TokenDb {
  final String _tokenKey = 'tokenKey';

  Future persistToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  delete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
