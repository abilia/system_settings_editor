import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/abilia_timer.dart';
import 'package:seagull/models/settings/memoplanner_settings.dart';
import 'package:seagull/ui/all.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import '../../../fakes/fake_db_and_repository.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  final startTime = DateTime(2021, 12, 22, 08, 10);
  final defaultTimer = AbiliaTimer(
      id: 'fake-id',
      title: 'test timer',
      duration: const Duration(minutes: 5),
      startTime: startTime);
  late MemoplannerSettingBloc mockMemoplannerSettingsBloc;
  late MockUserFileCubit mockUserFileCubit;
  late MockTimerDb mockTimerDb;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    tz.initializeTimeZones();
    await initializeDateFormatting();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
            MemoplannerSettings(advancedActivityTemplate: false)));
    when(() => mockMemoplannerSettingsBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    mockUserFileCubit = MockUserFileCubit();
    when(() => mockUserFileCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    mockTimerDb = MockTimerDb();
    when(() => mockTimerDb.getAllTimers())
        .thenAnswer((_) => Future(() => [defaultTimer]));
  });

  Widget wrapWithMaterialApp({required AbiliaTimer timer}) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.fixed(startTime),
          ),
          BlocProvider<TimerCubit>(
            create: (context) => TimerCubit(timerDb: mockTimerDb),
          ),
          BlocProvider<MemoplannerSettingBloc>.value(
            value: mockMemoplannerSettingsBloc,
          ),
          BlocProvider<UserFileCubit>.value(value: mockUserFileCubit),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: FakeSettingsDb(),
            ),
          ),
        ], child: ViewTimerPage(timer: timer)),
      );

  testWidgets('Page visible', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(timer: defaultTimer));
    await tester.pumpAndSettle();
    expect(find.byType(ViewTimerPage), findsOneWidget);
  });
}
