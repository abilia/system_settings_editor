import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications_platform_interface/flutter_local_notifications_platform_interface.dart';
import 'package:mocktail/mocktail.dart';

class FakeFlutterLocalNotificationsPlugin extends Fake
    implements FlutterLocalNotificationsPlugin {
  @override
  Future<void> cancel(int id, {String? tag}) async {}
  @override
  Future<void> cancelAll() async {}
  @override
  Future<List<PendingNotificationRequest>> pendingNotificationRequests() =>
      Future.value([]);
  @override
  T? resolvePlatformSpecificImplementation<
          T extends FlutterLocalNotificationsPlatform>() =>
      null;
}
