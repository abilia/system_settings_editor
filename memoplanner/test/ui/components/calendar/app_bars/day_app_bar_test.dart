import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_fakes/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mock_bloc.dart';
import '../../../../test_helpers/register_fallback_values.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  final day = DateTime(2020, 10, 05, 08, 00);
  final defaultClockBloc = ClockBloc.fixed(day);
  late MockMemoplannerSettingBloc memoplannerSettingsBlocMock;
  late FakeTimepillarCubit timepillarCubit;
  final translate = Locales.language.values.first;

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
          BlocProvider<TimepillarCubit>(
            create: (context) => timepillarCubit,
          ),
          BlocProvider<MemoplannerSettingsBloc>(
            create: (context) => memoplannerSettingsBlocMock,
          ),
          BlocProvider<DayPartCubit>(
            create: (context) => DayPartCubit(
              memoplannerSettingsBlocMock,
              clockBloc,
            ),
          ),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit(),
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
    timepillarCubit = FakeTimepillarCubit();
  });

  void expectSettings(MemoplannerSettings settings) {
    when(() => memoplannerSettingsBlocMock.state)
        .thenReturn(MemoplannerSettingsLoaded(settings));
  }

  testWidgets('Standard heading today', (WidgetTester tester) async {
    when(() => memoplannerSettingsBlocMock.state)
        .thenReturn(MemoplannerSettingsLoaded(const MemoplannerSettings()));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text(translate.earlyMorning), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Standard heading tomorrow - no day part',
      (WidgetTester tester) async {
    expectSettings(const MemoplannerSettings());
    await tester.pumpWidget(wrapWithMaterialApp(
        DayAppBar(day: day.add(24.hours())), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Tuesday'), findsOneWidget);
    expect(find.text(translate.earlyMorning), findsNothing);
    expect(find.text('6 October 2020'), findsOneWidget);
  });

  testWidgets('No day part when setting is false', (WidgetTester tester) async {
    expectSettings(const MemoplannerSettings(
        dayCalendar:
            DayCalendarSettings(appBar: AppBarSettings(showDayPeriod: false))));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text(translate.earlyMorning), findsNothing);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets(
      'No date when setting is false - and day and day part on different rows',
      (WidgetTester tester) async {
    expectSettings(const MemoplannerSettings(
        dayCalendar:
            DayCalendarSettings(appBar: AppBarSettings(showDate: false))));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text(translate.earlyMorning), findsOneWidget);
    expect(find.text('5 October 2020'), findsNothing);
  });

  testWidgets('No weekday when setting is false', (WidgetTester tester) async {
    expectSettings(const MemoplannerSettings(
        dayCalendar:
            DayCalendarSettings(appBar: AppBarSettings(showWeekday: false))));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsNothing);
    expect(find.text(translate.earlyMorning), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Only weekday', (WidgetTester tester) async {
    expectSettings(const MemoplannerSettings(
      dayCalendar: DayCalendarSettings(
        appBar: AppBarSettings(
          showDate: false,
          showDayPeriod: false,
        ),
      ),
    ));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text(translate.earlyMorning), findsNothing);
    expect(find.text('5 October 2020'), findsNothing);
  });

  testWidgets('Only day part', (WidgetTester tester) async {
    expectSettings(const MemoplannerSettings(
      dayCalendar: DayCalendarSettings(
        appBar: AppBarSettings(
          showDate: false,
          showWeekday: false,
          showDayPeriod: true,
        ),
      ),
    ));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsNothing);
    expect(find.text(translate.earlyMorning), findsOneWidget);
    expect(find.text('5 October 2020'), findsNothing);
  });

  testWidgets('Only date', (WidgetTester tester) async {
    expectSettings(const MemoplannerSettings(
      dayCalendar: DayCalendarSettings(
        appBar: AppBarSettings(
          showDate: true,
          showWeekday: false,
          showDayPeriod: false,
        ),
      ),
    ));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsNothing);
    expect(find.text(translate.earlyMorning), findsNothing);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Display nothing', (WidgetTester tester) async {
    expectSettings(const MemoplannerSettings(
      dayCalendar: DayCalendarSettings(
        appBar: AppBarSettings(
          showDate: false,
          showWeekday: false,
          showDayPeriod: false,
        ),
      ),
    ));
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), defaultClockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsNothing);
    expect(find.text(translate.earlyMorning), findsNothing);
    expect(find.text('5 October 2020'), findsNothing);
  });

  testWidgets('Evening starts at 18.00 as default',
      (WidgetTester tester) async {
    final evening = DateTime(2020, 10, 05, 18, 00);
    final clockBloc = ClockBloc.fixed(evening);
    expectSettings(const MemoplannerSettings());
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
    final clockBloc = ClockBloc.fixed(noEvening);
    expectSettings(
      MemoplannerSettings(
        calendar: GeneralCalendarSettings(
          dayParts: DayParts(
            evening: 19.hours(),
          ),
        ),
      ),
    );
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text('afternoon'), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('Mid morning at 11.59', (WidgetTester tester) async {
    final midMorning = DateTime(2020, 10, 05, 11, 59);
    final clockBloc = ClockBloc.fixed(midMorning);
    expectSettings(const MemoplannerSettings()); //
    await tester
        .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
    await tester.pumpAndSettle();
    expect(find.text('Monday'), findsOneWidget);
    expect(find.text(translate.midMorning), findsOneWidget);
    expect(find.text('5 October 2020'), findsOneWidget);
  });

  testWidgets('afternoon at 12.00', (WidgetTester tester) async {
    final midMorning = DateTime(2020, 10, 05, 12);
    final clockBloc = ClockBloc.fixed(midMorning);
    expectSettings(const MemoplannerSettings()); //
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
      final midMorning = DateTime(2020, 10, 05, 12, 5);
      final clockBloc = ClockBloc.fixed(midMorning);
      expectSettings(const MemoplannerSettings());
      await tester
          .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
      await tester.pumpAndSettle();
      tester.verifyTts(find.byType(AnalogClock),
          exact: 'the time is five past 12 in the afternoon');
    });

    testWidgets('clock tts test midMorning', (WidgetTester tester) async {
      final midMorning = DateTime(2020, 10, 05, 10, 25);
      final clockBloc = ClockBloc.fixed(midMorning);
      expectSettings(const MemoplannerSettings());
      await tester
          .pumpWidget(wrapWithMaterialApp(DayAppBar(day: day), clockBloc));
      await tester.pumpAndSettle();
      tester.verifyTts(find.byType(AnalogClock),
          exact: 'the time is twenty five past 10 in the mid-morning');
    });

    testWidgets('tts on nav buttons', (WidgetTester tester) async {
      expectSettings(const MemoplannerSettings());
      await tester.pumpWidget(
        wrapWithMaterialApp(
            DayAppBar(
              day: day,
              leftAction: LeftNavButton(
                onPressed: () => {},
              ),
              rightAction: RightNavButton(
                onPressed: () => {},
              ),
            ),
            defaultClockBloc),
      );
      await tester.pumpAndSettle();
      await tester.verifyTts(find.byType(LeftNavButton), exact: translate.back);
      await tester.verifyTts(
        find.byType(RightNavButton),
        exact: translate.next,
      );
    });
  });
}
