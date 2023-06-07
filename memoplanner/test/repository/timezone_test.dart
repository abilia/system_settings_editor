import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/utils/all.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('flutter_native_timezone'), (methodCall) async {
      switch (methodCall.method) {
        case 'getLocalTimezone':
          return 'UTC+2';
      }
      return null;
    });
  });

  test('utc timezone does not throw - Bug SGC-529', configureLocalTimeZone);
}
