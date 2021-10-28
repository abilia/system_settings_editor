import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:seagull/utils/all.dart';

import '../../../../mocks/mock_bloc.dart';
import '../../../../test_helpers/register_fallback_values.dart';
import '../../../../fakes/all.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  final day = DateTime(2020, 10, 05, 08, 00);
  final defaultClockBloc =
      ClockBloc(StreamController<DateTime>().stream, initialTime: day);
  late MockMemoplannerSettingBloc memoplannerSettingsBlocMock;

  Widget wrapWithMaterialApp(Widget widget, ClockBloc clockBloc) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockBloc>(
            create: (context) => clockBloc,
          ),
          BlocProvider<MemoplannerSettingBloc>(
            create: (context) => memoplannerSettingsBlocMock,
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: FakeSettingsDb(),
            ),
          ),
        ], child: widget),
      );

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    initializeDateFormatting();
    memoplannerSettingsBlocMock = MockMemoplannerSettingBloc();
    when(() => memoplannerSettingsBlocMock.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  void _expectSettings(MemoplannerSettings settings) {
    when(() => memoplannerSettingsBlocMock.state)
        .thenReturn(MemoplannerSettingsLoaded(settings));
  }

  testWidgets('Standard heading today', (WidgetTester tester) async {
    when(() => memoplannerSettingsBlocMock.state)
        .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings()));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('morning'), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Standard heading tomorrow - no day part',
      (WidgetTester tester) async {
    _expectSettings(const MemoplannerSettings());
    await tester.pumpWidget(wrapWithMaterialApp(
        DayAppBar(day: day.add(24.hours())), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.text('morning'), findsNothing);
    expect(find.text('6 October 2020'), findsOneWidget);
  });

  testWidgets('No day part when setting is false', (WidgetTester tester) async {
    _expectSettings(const MemoplannerSettings(activityDisplayDayPeriod: false));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('morning'), findsNothing);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets(
      'No date when setting is false - and day and day part on different rows',
      (WidgetTester tester) async {
    _expectSettings(const MemoplannerSettings(activityDisplayDate: false));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('morning'), findsOneWidget);
    expect(find.text('5 October 2020'), findsNothing);
  });

  testWidgets('No weekday when setting is false', (WidgetTester tester) async {
    _expectSettings(const MemoplannerSettings(activityDisplayWeekDay: false));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsNothing);
    expect(find.text('morning'), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Only weekday', (WidgetTester tester) async {
    _expectSettings(const MemoplannerSettings(
      activityDisplayDate: false,
      activityDisplayDayPeriod: false,
    ));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('morning'), findsNothing);
    expect(find.text('5 October 2020'), findsNothing);
  });

  testWidgets('Only day part', (WidgetTester tester) async {
    _expectSettings(const MemoplannerSettings(
      activityDisplayDate: false,
      activityDisplayDayPeriod: true,
      activityDisplayWeekDay: false,
    ));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsNothing);
    expect(find.text('morning'), findsOneWidget);
    expect(find.text('5 October 2020'), findsNothing);
  });

  testWidgets('Only date', (WidgetTester tester) async {
    _expectSettings(const MemoplannerSettings(
      activityDisplayDate: true,
      activityDisplayDayPeriod: false,
      activityDisplayWeekDay: false,
    ));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsNothing);
    expect(find.text('morning'), findsNothing);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Display nothing', (WidgetTester tester) async {
    _expectSettings(const MemoplannerSettings(
      activityDisplayDate: false,
      activityDisplayDayPeriod: false,
      activityDisplayWeekDay: false,
    ));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsNothing);
    expect(find.text('morning'), findsNothing);
    expect(find.text('5 October 2020'), findsNothing);
  });

  testWidgets('Evening starts at 18.00 as default',
      (WidgetTester tester) async {
    final evening = DateTime(2020, 10, 05, 18, 00);
    final clockBloc =
        ClockBloc(StreamController<DateTime>().stream, initialTime: evening);
    _expectSettings(const MemoplannerSettings());
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('evening'), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Evening starts at 19.00 if setting says so',
      (WidgetTester tester) async {
    final noEvening = DateTime(2020, 10, 05, 18, 00);
    final clockBloc =
        ClockBloc(StreamController<DateTime>().stream, initialTime: noEvening);
    _expectSettings(const MemoplannerSettings(
        eveningIntervalStart: 19 * 60 * 60 * 1000)); // 19.00 in milliseconds
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('afternoon'), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Forenoon at 11.59', (WidgetTester tester) async {
    final forenoon = DateTime(2020, 10, 05, 11, 59);
    final clockBloc =
        ClockBloc(StreamController<DateTime>().stream, initialTime: forenoon);
    _expectSettings(const MemoplannerSettings()); //
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('forenoon'), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('afternoon at 12.00', (WidgetTester tester) async {
    final forenoon = DateTime(2020, 10, 05, 12);
    final clockBloc =
        ClockBloc(StreamController<DateTime>().stream, initialTime: forenoon);
    _expectSettings(const MemoplannerSettings()); //
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('afternoon'), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  group('tts tests', () {
    setUpAll(() async {
      setupFakeTts();
      GetItInitializer()
        ..database = FakeDatabase()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..init();
    });

    testWidgets('clock tts test afternoon', (WidgetTester tester) async {
      final forenoon = DateTime(2020, 10, 05, 12, 5);
      final clockBloc =
          ClockBloc(StreamController<DateTime>().stream, initialTime: forenoon);
      _expectSettings(const MemoplannerSettings());
      await tester
          .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
      await tester.pumpAndSettle();
      tester.verifyTts(find.byType(AnalogClock),
          exact: 'the time is five past 12 in the afternoon');
    });

    testWidgets('clock tts test forenoon', (WidgetTester tester) async {
      final forenoon = DateTime(2020, 10, 05, 10, 25);
      final clockBloc =
          ClockBloc(StreamController<DateTime>().stream, initialTime: forenoon);
      _expectSettings(const MemoplannerSettings());
      await tester
          .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
      await tester.pumpAndSettle();
      tester.verifyTts(find.byType(AnalogClock),
          exact: 'the time is twenty five past 10 in the mid-morning');
    });
  });
}
