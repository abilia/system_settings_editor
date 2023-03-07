import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

class FakeSharedPreferences {
  static Future<SharedPreferences> getInstance({bool loggedIn = true}) {
    SharedPreferences.setMockInitialValues({});
    return SharedPreferences.getInstance();
  }
}
