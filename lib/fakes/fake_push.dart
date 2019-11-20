import 'package:flutter/material.dart';
import 'package:seagull/repository/push.dart';

class FakePush implements FirebasePush {
  @override
  Future<String> initPushToken() async {
    return 'fakeToken';
  }

  @override
  void initPushListeners(BuildContext context) {
    // Do nothing
  }
}
