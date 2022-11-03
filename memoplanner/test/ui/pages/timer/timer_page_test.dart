import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/ticker.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/navigation_observer.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  final startTime = DateTime(2021, 12, 22, 08, 10);
  final defaultTimer = AbiliaTimer.createNew(
      title: 'test timer',
      duration: const Duration(minutes: 5),
      startTime: startTime);
  final depletedTimer = AbiliaTimer.createNew(
      title: 'test timer 2',
      duration: const Duration(minutes: 5),
      startTime: startTime.subtract(const Duration(minutes: 10)));
  final pausedTimer = defaultTimer.pause(startTime);
  late MemoplannerSettingsBloc mockMemoplannerSettingsBloc;
  late MockUserFileCubit mockUserFileCubit;
  late MockTimerDb mockTimerDb;
  late MockTimerAlarmBloc mockTimerAlarmBloc;
  late NavObserver navObserver;
  late TimerCubit timerCubit;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    tz.initializeTimeZones();
    await initializeDateFormatting();

    navObserver = NavObserver();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
      MemoplannerSettingsLoaded(
        const MemoplannerSettings(
          addActivity: AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        ),
      ),
    );
    when(() => mockMemoplannerSettingsBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    mockUserFileCubit = MockUserFileCubit();
    when(() => mockUserFileCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    mockTimerDb = MockTimerDb();
    when(() => mockTimerDb.getAllTimers())
        .thenAnswer((_) => Future(() => [defaultTimer]));
    when(() => mockTimerDb.update(any())).thenAnswer((_) => Future.value(1));
    when(() => mockTimerDb.delete(any())).thenAnswer((_) => Future.value(1));
    mockTimerAlarmBloc = MockTimerAlarmBloc();
    when(() => mockTimerAlarmBloc.state).thenReturn(TimerAlarmState(
      timers: [
        defaultTimer.toOccasion(startTime),
        depletedTimer.toOccasion(startTime)
      ],
      queue: [defaultTimer.toOccasion(startTime)],
    ));
    timerCubit = TimerCubit(
      timerDb: mockTimerDb,
      ticker: Ticker.fake(initialTime: startTime),
    );
    GetItInitializer()
      ..ticker = Ticker.fake(initialTime: startTime)
      ..sharedPreferences =
          await FakeSharedPreferences.getInstance(loggedIn: false)
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(() async {
    setupPermissions();
    await GetIt.I.reset();
  });

  Widget wrapWithMaterialApp({required AbiliaTimer timer}) => MaterialApp(
      navigatorObservers: [navObserver],
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: const [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale?.languageCode,
              orElse: () => supportedLocales.first),
      builder: (context, child) => MultiBlocProvider(providers: [
            BlocProvider<ClockBloc>(
              create: (context) => ClockBloc.fixed(startTime),
            ),
            BlocProvider<TimerCubit>(
              create: (context) => timerCubit,
            ),
            BlocProvider<MemoplannerSettingsBloc>.value(
              value: mockMemoplannerSettingsBloc,
            ),
            BlocProvider<UserFileCubit>.value(value: mockUserFileCubit),
            BlocProvider<TimerAlarmBloc>.value(value: mockTimerAlarmBloc),
            BlocProvider<TimepillarCubit>(
              create: (context) => FakeTimepillarCubit(),
            ),
            BlocProvider<SpeechSettingsCubit>(
              create: (context) => FakeSpeechSettingsCubit(),
            ),
            BlocProvider<DayPartCubit>(
              create: (context) => FakeDayPartCubit(),
            ),
          ], child: child!),
      home: TimerPage(
        timerOccasion: TimerOccasion(timer, Occasion.current),
        day: timer.startTime,
      ));

  testWidgets('Page visible', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(timer: defaultTimer));
    await tester.pumpAndSettle();
    expect(find.byType(TimerPage), findsOneWidget);
  });

  testWidgets('BUG SGC-1503 really long title', (WidgetTester tester) async {
    final longTitleTimer = AbiliaTimer.createNew(
        title: 'Phone: iPhone 11App version: 1.4.0-alpha (1111)'
            'Steps to reproduce'
            'Test to login to myAbilia and navigate to Basic timer.'
            'Create a Basic timer with a very long title and upload picture (attached file: upload). Duration: 1 minute'
            'Test to open up MEMOplanner Go app. Select (newly created myAbilia) Basic Timerc.'
            'Actual result: Picture is truncated and text-overflow in activity/alarm screen.'
            'See flow (steps) in attached screenshot.Expected result:  Entire picture should displays and no text-overflow.',
        duration: const Duration(hours: 16),
        startTime: startTime);
    await tester.pumpWidget(wrapWithMaterialApp(timer: longTitleTimer));
    await tester.pumpAndSettle();
    expect(find.text(longTitleTimer.title), findsOneWidget);
    expect(tester.widget<Text>(find.text(longTitleTimer.title)).maxLines, 3);
  });

  testWidgets('Running timer has TimerTickerBuilder',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(timer: defaultTimer));
    await tester.pumpAndSettle();
    expect(find.byType(TimerTickerBuilder), findsOneWidget);
  });

  testWidgets('Depleted timer has no TimerTickerBuilder',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(timer: depletedTimer));
    await tester.pumpAndSettle();
    expect(find.byType(TimerTickerBuilder), findsNothing);
  });

  testWidgets('Delete timer removes TimerPage (and dialog)',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(timer: defaultTimer));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.deleteAllClear));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(YesButton));
    await tester.pumpAndSettle();
    expect(navObserver.routesPoped, hasLength(2));
  });

  testWidgets('Pausing timer, TimerCubit emits "paused" timer ',
      (WidgetTester tester) async {
    final expect = expectLater(
      timerCubit.stream,
      emits(TimerState(timers: [pausedTimer])),
    );
    await tester.pumpWidget(wrapWithMaterialApp(timer: defaultTimer));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.pause));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(YesButton));
    await tester.pumpAndSettle();
    await expect;
  }, skip: Config.release);

  testWidgets('Pausing timer, cancel pause', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(timer: defaultTimer));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.pause));
    await tester.pumpAndSettle();
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    expect(find.byType(TimerTickerBuilder), findsOneWidget);
  }, skip: Config.release);

  testWidgets('Resuming timer, TimerCubit emits "default"(non-paused) timer',
      (WidgetTester tester) async {
    when(() => mockTimerAlarmBloc.state).thenReturn(TimerAlarmState(
      timers: [
        pausedTimer.toOccasion(startTime),
      ],
      queue: [pausedTimer.toOccasion(startTime)],
    ));
    final expect = expectLater(
      timerCubit.stream,
      emits(TimerState(timers: [defaultTimer])),
    );
    await tester.pumpWidget(wrapWithMaterialApp(timer: pausedTimer));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.playSound));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(YesButton));
    await tester.pumpAndSettle();
    await expect;
  }, skip: Config.release);
}
