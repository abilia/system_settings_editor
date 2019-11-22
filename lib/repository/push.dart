import 'package:firebase_messaging/firebase_messaging.dart';

class FirebasePushService {
  Future<String> initPushToken() async {
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    final token = await _firebaseMessaging.getToken();
    return token;
  }
}
