import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

void main() {
  const MethodChannel channel = MethodChannel('system_settings_editor');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return 0.5;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getBrightness', () async {
    expect(await SystemSettingsEditor.brightness, 0.5);
  });
}
