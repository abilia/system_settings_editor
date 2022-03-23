import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/ui/all.dart';

import '../mocks/mock_bloc.dart';
import '../mocks/mocks.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WakeLockCubit wakeLockCubit;
  late Battery mockBattery;
  late StreamController<BatteryState> _batteryStreamController;
  late MemoplannerSettingBloc mockMemoplannerSettingBloc;

  const _setScreenOffTimeout = 'setScreenOffTimeout',
      _getScreenOffTimeout = 'getScreenOffTimeout',
      _canWriteSettings = 'canWriteSettings';

  const systemTimeOutMs = 60000;
  Map<String, int> systemSettingsChannelCallCounter = {};
  Map<String, dynamic> systemSettingsChannelCallArguments = {};
  const MethodChannel systemSettingsChannel =
      MethodChannel('system_settings_editor');
  setUpMockSystemSettingsChannel({
    int screenOffTimeout = systemTimeOutMs,
    bool canWriteSettings = true,
  }) {
    systemSettingsChannelCallCounter = {};
    systemSettingsChannelCallArguments = {};
    systemSettingsChannel
        .setMockMethodCallHandler((MethodCall methodCall) async {
      var cc = systemSettingsChannelCallCounter[methodCall.method] ?? 0;
      systemSettingsChannelCallCounter[methodCall.method] = cc + 1;
      if (methodCall.arguments != null) {
        systemSettingsChannelCallArguments[methodCall.method] =
            methodCall.arguments;
      }
      switch (methodCall.method) {
        case _canWriteSettings:
          return canWriteSettings;
        case _getScreenOffTimeout:
          return screenOffTimeout;
      }
    });
  }

  setUp(() async {
    setUpMockSystemSettingsChannel();
    registerFallbackValues();

    mockBattery = MockBattery();
    _batteryStreamController = StreamController<BatteryState>();
    when(() => mockBattery.onBatteryStateChanged)
        .thenAnswer((_) => _batteryStreamController.stream);
    mockMemoplannerSettingBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingBloc.state)
        .thenReturn(const MemoplannerSettingsNotLoaded());

    wakeLockCubit = WakeLockCubit(
      battery: mockBattery,
      memoSettingsBloc: mockMemoplannerSettingBloc,
      screenTimeoutCallback: Future.value(
        const Duration(milliseconds: systemTimeOutMs),
      ),
    );
  });

  tearDown(() {
    _batteryStreamController.close();
  });

  Widget _wrapWithMaterialApp() => MaterialApp(
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

    await tester.pumpWidget(_wrapWithMaterialApp());
    await tester.pumpAndSettle();
    wakeLockCubit.setScreenTimeout(newTimeout);
    await tester.pumpAndSettle();

    expect(systemSettingsChannelCallCounter[_setScreenOffTimeout], isNull);
  });

  testWidgets('When new timeout, not same as settings, change', (tester) async {
    const newTimeout = Duration(minutes: 3);

    await tester.pumpWidget(_wrapWithMaterialApp());
    await tester.pumpAndSettle();
    wakeLockCubit.setScreenTimeout(newTimeout);
    await tester.pumpAndSettle();

    expect(systemSettingsChannelCallCounter[_setScreenOffTimeout], 1);
    expect(systemSettingsChannelCallArguments[_setScreenOffTimeout]['timeout'],
        newTimeout.inMilliseconds);
  });
}
