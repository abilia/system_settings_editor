import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  const MethodChannel systemSettingsChannel =
      MethodChannel('system_settings_editor');
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    systemSettingsChannel
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getSoundEffectsEnabled':
          return true;
        case 'getBrightness':
          return 0.5;
        case 'getScreenOffTimeout':
          return 60000;
        case 'canWriteSettings':
          return true;
      }
    });
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker.fake(initialTime: DateTime(2021, 04, 17, 09, 20))
      ..client = Fakes.client()
      ..database = FakeDatabase()
      ..genericDb = FakeGenericDb()
      ..sortableDb = FakeSortableDb()
      ..battery = FakeBattery()
      ..init();
  });

  tearDown(() {
    systemSettingsChannel.setMockMethodCallHandler(null);
    GetIt.I.reset();
  });

  group('Quick settings page', () {
    testWidgets('All fields are setup correctly', (tester) async {
      await tester.goToQuickSettings();
      expect(find.byType(QuickSettingsPage), findsOneWidget);
      expect(find.byType(AlarmVolumeSlider), findsOneWidget);
      expect(find.byType(MediaVolumeSlider), findsOneWidget);
      expect(find.byType(KeepOnWhileChargingSwitch), findsOneWidget);
      expect(
        tester.widget(find.byKey(TestKey.brightnessSlider)),
        isA<AbiliaSlider>().having((t) => t.value, 'value of brightness', 0.5),
      );
      expect(find.byType(BatteryLevel), findsOneWidget);

      expect(find.byType(WiFiPickField), findsOneWidget);
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> goToQuickSettings() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(QuickSettingsButton));
    await pumpAndSettle();
  }
}
