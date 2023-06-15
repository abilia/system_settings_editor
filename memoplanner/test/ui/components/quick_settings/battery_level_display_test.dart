import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/tts.dart';

void main() {
  late MockBattery mockBattery;

  setUpAll(() async {
    await Lokalise.initMock();
  });

  setUp(() async {
    setupFakeTts();
    registerFallbackValue(BatteryState.unknown);
    mockBattery = MockBattery();
    when(() => mockBattery.onBatteryStateChanged)
        .thenAnswer((_) => Stream.value(BatteryState.unknown));
    when(() => mockBattery.batteryState)
        .thenAnswer((_) => Future.value(BatteryState.discharging));
    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        localizationsDelegates: const [Lt.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.fixed(DateTime(1919)),
          ),
          BlocProvider<MemoplannerSettingsBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit(),
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
    await tester.verifyTts(find.byIcon(AbiliaIcons.batteryLevelCritical),
        exact: '1%');
  });

  testWidgets('Battery level 10%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(10));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_10), findsOneWidget);
    await tester.verifyTts(find.byIcon(AbiliaIcons.batteryLevel_10),
        exact: '10%');
  });

  testWidgets('Battery level 20%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(20));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_20), findsOneWidget);
    await tester.verifyTts(find.byIcon(AbiliaIcons.batteryLevel_20),
        exact: '20%');
  });

  testWidgets('Battery level 40%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(40));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_40), findsOneWidget);
    await tester.verifyTts(find.byIcon(AbiliaIcons.batteryLevel_40),
        exact: '40%');
  });

  testWidgets('Battery level 60%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(60));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_60), findsOneWidget);
    await tester.verifyTts(find.byIcon(AbiliaIcons.batteryLevel_60),
        exact: '60%');
  });

  testWidgets('Battery level 80%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(80));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_80), findsOneWidget);
    await tester.verifyTts(find.byIcon(AbiliaIcons.batteryLevel_80),
        exact: '80%');
  });

  testWidgets('Battery level 100%', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(100));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_100), findsOneWidget);
    await tester.verifyTts(find.byIcon(AbiliaIcons.batteryLevel_100),
        exact: '100%');
  });

  testWidgets('Battery charging', (WidgetTester tester) async {
    when(() => mockBattery.batteryLevel).thenAnswer((_) => Future.value(50));
    when(() => mockBattery.batteryState)
        .thenAnswer((_) => Future.value(BatteryState.charging));
    await tester.pumpWidget(
      wrapWithMaterialApp(BatteryLevel(battery: mockBattery)),
    );
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryCharging), findsOneWidget);
  });
}
