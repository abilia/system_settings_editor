import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/db/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'all.dart';

class FakeSharedPreferences {
  static Future<SharedPreferences> getInstance({bool loggedIn = true}) {
    SharedPreferences.setMockInitialValues({
      if (loggedIn) LoginDb.tokenKey: Fakes.token,
      VoiceDb.textToSpeechRecord: true,
    });
    return SharedPreferences.getInstance();
  }
}
