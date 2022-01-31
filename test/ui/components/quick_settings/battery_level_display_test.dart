import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  late MockBattery mockBattery;

  setUp(() {
    registerFallbackValue(BatteryState.unknown);
    mockBattery = MockBattery();
    when(() => mockBattery.onBatteryStateChanged)
        .thenAnswer((_) => Stream.value(BatteryState.unknown));
  });

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.fixed(DateTime(1919)),
          ),
          BlocProvider<MemoplannerSettingBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(
              settingsDb: FakeSettingsDb(),
            ),
          ),
        ], child: widget),
      );

  testWidgets('Battery level critical', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(1));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevelCritical), findsOneWidget);
  });

  testWidgets('Battery level 10%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(10));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_10), findsOneWidget);
  });

  testWidgets('Battery level 20%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(20));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_20), findsOneWidget);
  });

  testWidgets('Battery level 40%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(40));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_40), findsOneWidget);
  });

  testWidgets('Battery level 60%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(60));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_60), findsOneWidget);
  });

  testWidgets('Battery level 80%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(80));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_80), findsOneWidget);
  });

  testWidgets('Battery level 100%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(100));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_100), findsOneWidget);
  });
}
