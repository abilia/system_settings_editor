import 'package:auth/push.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeFirebasePushService extends Fake implements FirebasePushService {
  @override
  Future<String?> initPushToken() => Future.value('fakeToken');
}
