import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeSharedPreferences {
  static Future<SharedPreferences> getInstance({bool loggedIn = true}) {
    SharedPreferences.setMockInitialValues({
      if (loggedIn) TokenDb.tokenKey: Fakes.token,
    });
    return SharedPreferences.getInstance();
  }
}
