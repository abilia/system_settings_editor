import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/screen_timeout/wake_lock_cubit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/duration.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';

void main() {
  late MockWakeLockCubit mockWakeLockCubit;
  const Translator _translator = Translator(Locale('en'));

  setUp(() {
    registerFallbackValue(const KeepScreenAwakeState(
        screenTimeout: Duration(minutes: -1), screenOnWhileCharging: false));
    mockWakeLockCubit = MockWakeLockCubit();
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
          BlocProvider<WakeLockCubit>.value(value: mockWakeLockCubit),
        ], child: widget),
      );

  testWidgets('Timeout set to one minute', (WidgetTester tester) async {
    const time = Duration(minutes: 1);

    when(() => mockWakeLockCubit.state).thenReturn(const KeepScreenAwakeState(
        screenTimeout: time, screenOnWhileCharging: false));
    await tester
        .pumpWidget(wrapWithMaterialApp(const ScreenTimeoutPickField()));
    await tester.pumpAndSettle();

    expect(find.text(time.toDurationString(_translator.translate)),
        findsOneWidget);
  }, skip: !Config.isMP);

  testWidgets('Timeout set to 30 minutes', (WidgetTester tester) async {
    const time = Duration(minutes: 30);
    when(() => mockWakeLockCubit.state).thenReturn(const KeepScreenAwakeState(
        screenTimeout: time, screenOnWhileCharging: false));
    await tester
        .pumpWidget(wrapWithMaterialApp(const ScreenTimeoutPickField()));
    await tester.pumpAndSettle();

    expect(find.text(time.toDurationString(_translator.translate)),
        findsOneWidget);
  }, skip: !Config.isMP);

  testWidgets('Timeout disabled', (WidgetTester tester) async {
    const time = Duration(days: 0);
    when(() => mockWakeLockCubit.state).thenReturn(const KeepScreenAwakeState(
        screenTimeout: time, screenOnWhileCharging: false));
    await tester
        .pumpWidget(wrapWithMaterialApp(const ScreenTimeoutPickField()));
    await tester.pumpAndSettle();

    expect(find.text(_translator.translate.alwaysOn), findsOneWidget);
  }, skip: !Config.isMP);
}
