import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/ui/all.dart';

import '../fakes/all.dart';
import '../mocks/mocks.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WakeLockCubit wakeLockCubit;
  late Battery mockBattery;
  late StreamController<BatteryState> batteryStreamController;

  const setScreenOffTimeout = 'setScreenOffTimeout',
      getScreenOffTimeout = 'getScreenOffTimeout',
      canWriteSettings = 'canWriteSettings';

  const systemTimeOutMs = 60000;
  Map<String, int> systemSettingsChannelCallCounter = {};
  Map<String, dynamic> systemSettingsChannelCallArguments = {};
  const MethodChannel systemSettingsChannel =
      MethodChannel('system_settings_editor');
  void setUpMockSystemSettingsChannel({
    int screenOffTimeout = systemTimeOutMs,
    bool canWrite = true,
  }) {
    systemSettingsChannelCallCounter = {};
    systemSettingsChannelCallArguments = {};
    systemSettingsChannel
        .setMockMethodCallHandler((MethodCall methodCall) async {
      final cc = systemSettingsChannelCallCounter[methodCall.method] ?? 0;
      systemSettingsChannelCallCounter[methodCall.method] = cc + 1;
      if (methodCall.arguments != null) {
        systemSettingsChannelCallArguments[methodCall.method] =
            methodCall.arguments;
      }
      switch (methodCall.method) {
        case canWriteSettings:
          return canWrite;
        case getScreenOffTimeout:
          return screenOffTimeout;
      }
    });
  }

  setUp(() async {
    setUpMockSystemSettingsChannel();
    registerFallbackValues();

    mockBattery = MockBattery();
    batteryStreamController = StreamController<BatteryState>();
    when(() => mockBattery.onBatteryStateChanged)
        .thenAnswer((_) => batteryStreamController.stream);

    wakeLockCubit = WakeLockCubit(
      battery: mockBattery,
      settingsStream: const Stream.empty(),
      settingsDb: FakeSettingsDb(),
      hasBattery: true,
    );
  });

  tearDown(() {
    batteryStreamController.close();
  });

  Widget wrapWithMaterialApp() => MaterialApp(
        builder: (context, child) => BlocProvider<WakeLockCubit>(
          create: (context) => wakeLockCubit,
          child: MultiBlocListener(
            listeners: [
              KeepScreenAwakeListener(),
            ],
            child: Container(),
          ),
        ),
      );

  testWidgets('When new timeout, but same as settings, do nothing',
      (tester) async {
    const newTimeout = Duration(minutes: 3);
    setUpMockSystemSettingsChannel(screenOffTimeout: newTimeout.inMilliseconds);

    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    wakeLockCubit.setScreenTimeout(newTimeout);
    await tester.pumpAndSettle();

    expect(systemSettingsChannelCallCounter[setScreenOffTimeout], isNull);
  });

  testWidgets('When new timeout, not same as settings, change', (tester) async {
    const newTimeout = Duration(minutes: 3);

    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    wakeLockCubit.setScreenTimeout(newTimeout);
    await tester.pumpAndSettle();

    expect(systemSettingsChannelCallCounter[setScreenOffTimeout], 1);
    expect(systemSettingsChannelCallArguments[setScreenOffTimeout]['timeout'],
        newTimeout.inMilliseconds);
  });

  group('Full App', () {
    setUp(() async {
      setupPermissions();
      setUpMockSystemSettingsChannel(
        screenOffTimeout: const Duration(minutes: 30).inMilliseconds,
      );

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..database = FakeDatabase()
        ..deviceDb = FakeDeviceDb()
        ..sortableDb = FakeSortableDb()
        ..client = Fakes.client()
        ..init();
    });

    testWidgets(
      'Finds KeepScreenAwakeListener in tree and getScreenOffTimeout gets called',
      (tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        expect(find.byType(KeepScreenAwakeListener), findsOneWidget);

        expect(
          systemSettingsChannelCallCounter[getScreenOffTimeout],
          greaterThanOrEqualTo(1),
        );
      },
      skip: !Config.isMP,
    );
  });
}
