import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/repository/timezone.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel('flutter_native_timezone')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getLocalTimezone':
          return 'UTC+2';
      }
    });
  });

  test('utc timezone does not throw - Bug SGC-529', configureLocalTimeZone);
}
