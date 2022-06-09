import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/data_repository/support_persons_repository.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  final startTime = DateTime(2020, 02, 10, 15, 30);
  final today = startTime.onlyDays();
  final startActivity = Activity.createNew(
    title: '',
    startTime: startTime,
  );

  late MockSortableBloc mockSortableBloc;
  late MockUserFileCubit mockUserFileCubit;
  late MockTimerCubit mockTimerCubit;
  late MemoplannerSettingBloc mockMemoplannerSettingsBloc;
  late FakeAuthenticationBloc fakeAuthenticationBloc;
  late MockSupportPersonsRepository supportUserRepo;
  late MockBaseUrlDb mockBaseUrlDb;

  setUpAll(() async {
    registerFallbackValues();
    tz.initializeTimeZones();
    await initializeDateFormatting();
  });

  setUp(() async {
    mockSortableBloc = MockSortableBloc();
    when(() => mockSortableBloc.stream).thenAnswer((_) => const Stream.empty());
    mockUserFileCubit = MockUserFileCubit();
    when(() => mockUserFileCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    mockTimerCubit = MockTimerCubit();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
      const MemoplannerSettingsLoaded(
        MemoplannerSettings(
          editActivity: EditActivitySettings(template: false),
        ),
      ),
    );
    when(() => mockMemoplannerSettingsBloc.stream)
        .thenAnswer((_) => const Stream.empty());

    fakeAuthenticationBloc = FakeAuthenticationBloc();

    supportUserRepo = MockSupportPersonsRepository();
    when(() => supportUserRepo.load()).thenAnswer((_) =>
        Future.value(const [SupportPerson(id: 0, name: 'Test', image: '')]));

    mockBaseUrlDb = MockBaseUrlDb();
    when(() => mockBaseUrlDb.baseUrl).thenAnswer((_) => 'mockUrl');

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..baseUrlDb = mockBaseUrlDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  Widget createEditActivityPage({
    Activity? givenActivity,
    bool use24H = false,
    bool newActivity = false,
  }) {
    final activity = givenActivity ?? startActivity;
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: const [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale?.languageCode,
              orElse: () => supportedLocales.first),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24H),
        child: FakeAuthenticatedBlocsProvider(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ClockBloc>(
                create: (context) => ClockBloc.fixed(startTime),
              ),
              BlocProvider<MemoplannerSettingBloc>.value(
                value: mockMemoplannerSettingsBloc,
              ),
              BlocProvider<ActivitiesBloc>(create: (_) => FakeActivitiesBloc()),
              BlocProvider<EditActivityCubit>(
                create: (context) => newActivity
                    ? EditActivityCubit.newActivity(
                        day: today,
                        defaultAlarmTypeSetting: mockMemoplannerSettingsBloc
                            .state.defaultAlarmTypeSetting,
                        calendarId: 'calendarId',
                      )
                    : EditActivityCubit.edit(
                        ActivityDay(activity, today),
                      ),
              ),
              BlocProvider<WizardCubit>(
                create: (context) => newActivity
                    ? ActivityWizardCubit.newActivity(
                        activitiesBloc: context.read<ActivitiesBloc>(),
                        clockBloc: context.read<ClockBloc>(),
                        editActivityCubit: context.read<EditActivityCubit>(),
                        settings: context.read<MemoplannerSettingBloc>().state,
                      )
                    : ActivityWizardCubit.edit(
                        activitiesBloc: context.read<ActivitiesBloc>(),
                        clockBloc: context.read<ClockBloc>(),
                        editActivityCubit: context.read<EditActivityCubit>(),
                        allowPassedStartTime: context
                            .read<MemoplannerSettingBloc>()
                            .state
                            .settings
                            .addActivity
                            .allowPassedStartTime,
                      ),
              ),
              BlocProvider<SortableBloc>.value(value: mockSortableBloc),
              BlocProvider<UserFileCubit>.value(value: mockUserFileCubit),
              BlocProvider<DayPickerBloc>(
                create: (context) => DayPickerBloc(
                  clockBloc: context.read<ClockBloc>(),
                ),
              ),
              BlocProvider<SettingsCubit>(
                create: (context) => SettingsCubit(
                  settingsDb: FakeSettingsDb(),
                ),
              ),
              BlocProvider<PermissionCubit>(
                create: (context) => PermissionCubit()..checkAll(),
              ),
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  screenTimeoutCallback: Future.value(30.minutes()),
                  memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                  battery: FakeBattery(),
                ),
              ),
              BlocProvider<TimerCubit>.value(value: mockTimerCubit),
              BlocProvider<AuthenticationBloc>.value(
                  value: fakeAuthenticationBloc),
            ],
            child: RepositoryProvider<SupportPersonsRepository>(
              create: (context) => supportUserRepo,
              child: BlocProvider<AvailableForCubit>(
                create: (context) => AvailableForCubit(
                  supportPersonsRepository:
                      context.read<SupportPersonsRepository>(),
                )..setAvailableFor(activity.availableFor),
                child: child!,
              ),
            ),
          ),
        ),
      ),
      home: const AvailableForPage(),
    );
  }

  testWidgets('Show support persons when tapping Selected Support Persons',
      (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage());
    await tester.pumpAndSettle();

    expect(find.byType(AvailableForPage), findsOneWidget);

    await tester.tap(find.byIcon(AbiliaIcons.selectedSupport));

    await tester.pumpAndSettle();

    expect(find.byType(SupportPersonsWidget), findsOneWidget);
  });

  testWidgets('Don\'t show support persons when tapping other radio buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage());
    await tester.pumpAndSettle();

    expect(find.byType(AvailableForPage), findsOneWidget);

    await tester.tap(find.byIcon(AbiliaIcons.lock));

    await tester.pumpAndSettle();

    expect(find.byType(SupportPersonsWidget), findsNothing);

    await tester.tap(find.byIcon(AbiliaIcons.unlock).last);

    await tester.pumpAndSettle();

    expect(find.byType(SupportPersonsWidget), findsNothing);
  });
}
