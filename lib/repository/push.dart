// @dart=2.9

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushService {
  Future<String> initPushToken() => FirebaseMessaging.instance.getToken();
}
