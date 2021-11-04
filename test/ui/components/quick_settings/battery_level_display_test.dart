import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';

void main() {
  late MockBatteryCubit mockBatteryCubit;

  setUp(() {
    mockBatteryCubit = MockBatteryCubit();
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
          BlocProvider<BatteryCubit>.value(value: mockBatteryCubit),
        ], child: widget),
      );

  testWidgets('Battery level critical', (WidgetTester tester) async {
    when(() => mockBatteryCubit.state).thenReturn(1);
    await tester.pumpWidget(wrapWithMaterialApp(const BatteryLevel()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevelCritical), findsOneWidget);
  });

  testWidgets('Battery level 10%', (WidgetTester tester) async {
    when(() => mockBatteryCubit.state).thenReturn(10);
    await tester.pumpWidget(wrapWithMaterialApp(const BatteryLevel()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_10), findsOneWidget);
  });

  testWidgets('Battery level 20%', (WidgetTester tester) async {
    when(() => mockBatteryCubit.state).thenReturn(20);
    await tester.pumpWidget(wrapWithMaterialApp(const BatteryLevel()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_20), findsOneWidget);
  });

  testWidgets('Battery level 40%', (WidgetTester tester) async {
    when(() => mockBatteryCubit.state).thenReturn(40);
    await tester.pumpWidget(wrapWithMaterialApp(const BatteryLevel()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_40), findsOneWidget);
  });

  testWidgets('Battery level 60%', (WidgetTester tester) async {
    when(() => mockBatteryCubit.state).thenReturn(60);
    await tester.pumpWidget(wrapWithMaterialApp(const BatteryLevel()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_60), findsOneWidget);
  });

  testWidgets('Battery level 80%', (WidgetTester tester) async {
    when(() => mockBatteryCubit.state).thenReturn(80);
    await tester.pumpWidget(wrapWithMaterialApp(const BatteryLevel()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_80), findsOneWidget);
  });

  testWidgets('Battery level 100%', (WidgetTester tester) async {
    when(() => mockBatteryCubit.state).thenReturn(100);
    await tester.pumpWidget(wrapWithMaterialApp(const BatteryLevel()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.batteryLevel_100), findsOneWidget);
  });
}
