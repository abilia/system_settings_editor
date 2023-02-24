import 'package:auth/db/login_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSharedPreferences {
  static Future<SharedPreferences> getInstance({bool loggedIn = true}) {
    SharedPreferences.setMockInitialValues({
      if (loggedIn) LoginDb.tokenKey: 'Fakes.token',
    });
    return SharedPreferences.getInstance();
  }
}
