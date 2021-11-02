import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  const MethodChannel systemSettingsChannel =
      MethodChannel('system_settings_editor');
  const MethodChannel batteryChannel =
      MethodChannel('dev.fluttercommunity.plus/battery');
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    systemSettingsChannel
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return 0.5;
    });
    batteryChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      return 20;
    });
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: DateTime(2021, 04, 17, 09, 20),
      )
      ..client = Fakes.client()
      ..database = FakeDatabase()
      ..syncDelay = SyncDelays.zero
      ..genericDb = FakeGenericDb()
      ..sortableDb = FakeSortableDb()
      ..init();
  });

  tearDown(() {
    systemSettingsChannel.setMockMethodCallHandler(null);
    batteryChannel.setMethodCallHandler(null);
    GetIt.I.reset();
  });

  group('Quick settings page', () {
    testWidgets('Brightness slider is shown with correct value',
        (tester) async {
      await tester.goToQuickSettings();
      expect(find.byType(QuickSettingsPage), findsOneWidget);
      expect(
        tester.widget(find.byType(AbiliaSlider)),
        isA<AbiliaSlider>().having((t) => t.value, 'value of brightness', 0.5),
      );
    });

    testWidgets('Correct battery level icon is shown', (tester) async {
      await tester.goToQuickSettings();
      expect(find.byType(BatteryLevelDisplay), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.batteryLevel_20), findsOneWidget);
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
