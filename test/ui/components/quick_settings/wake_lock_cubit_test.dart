import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/screen_timeout/wake_lock_cubit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';

void main() {
  const MethodChannel systemSettingsChannel =
      MethodChannel('system_settings_editor');
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockBatteryCubit mockBatteryCubit;
  late WakeLockCubit wakeLockCubit;
  late FakeGenericBloc fakeGenericBloc;
  late MockWakeLockCubit mockWakeLockCubit;

  setUp(() {
    registerFallbackValue(const BatteryCubitState(BatteryState.full, 100));
    mockBatteryCubit = MockBatteryCubit();
    fakeGenericBloc = FakeGenericBloc();
    wakeLockCubit = WakeLockCubit(
        genericBloc: fakeGenericBloc,
        batteryCubit: mockBatteryCubit,
        screenAwakeSettings: const KeepScreenAwakeSettings());
  });

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc(StreamController<DateTime>().stream,
                initialTime: DateTime(1919)),
          ),
          BlocProvider<MemoplannerSettingBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: FakeSettingsDb(),
            ),
          ),
          BlocProvider<GenericBloc>.value(value: fakeGenericBloc),
          BlocProvider<BatteryCubit>.value(value: mockBatteryCubit),
          BlocProvider<WakeLockCubit>.value(value: wakeLockCubit),
        ], child: widget),
      );

  testWidgets('Battery level critical', (WidgetTester tester) async {
    await tester
        .pumpWidget(wrapWithMaterialApp(const ScreenTimeoutPickField()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevelCritical), findsOneWidget);
  });
}
