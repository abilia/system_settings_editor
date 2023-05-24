import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_fakes/all.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/default_sortables.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';
import '../../../test_helpers/tts.dart';

void main() {
  final startTime = DateTime(2021, 09, 22, 12, 46);
  final today = startTime.onlyDays();
  final translate = Locales.language.values.first;

  late MockSortableBloc mockSortableBloc;
  late MockUserFileBloc mockUserFileBloc;
  late MockTimerCubit mockTimerCubit;
  late MemoplannerSettingsBloc mockMemoplannerSettingsBloc;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    tz.initializeTimeZones();
    await initializeDateFormatting();
    mockSortableBloc = MockSortableBloc();
    when(() => mockSortableBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockSortableBloc.state).thenReturn(
      SortablesLoaded(
        sortables: defaultSortables,
      ),
    );
    mockUserFileBloc = MockUserFileBloc();
    when(() => mockUserFileBloc.stream).thenAnswer((_) => const Stream.empty());
    mockTimerCubit = MockTimerCubit();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
      MemoplannerSettingsLoaded(
        const MemoplannerSettings(
          addActivity: AddActivitySettings(
            mode: AddActivityMode.stepByStep,
          ),
        ),
      ),
    );
    when(() => mockMemoplannerSettingsBloc.stream).thenAnswer(
      (_) => const Stream.empty(),
    );

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..database = FakeDatabase()
      ..baseUrlDb = MockBaseUrlDb()
      ..init();
  });

  tearDown(GetIt.I.reset);

  Future<void> skipTitleTimeAndCategoryWidgets(WidgetTester tester) async {
    expect(find.byType(TitleWiz), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'title');
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(TimeWiz), findsOneWidget);
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '1137');
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();
  }

  Widget wizardPage({
    bool use24 = false,
    BasicActivityDataItem? basicActivityData,
  }) {
    final navKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      navigatorKey: navKey,
      localizationsDelegates: const [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale?.languageCode,
              orElse: () => supportedLocales.first),
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => navKey.currentState?.push(
            MaterialPageRoute(builder: (context) => const ActivityWizardPage()),
          ),
        );

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24),
          child: FakeAuthenticatedBlocsProvider(
            child: MultiBlocProvider(
              providers: [
                BlocProvider<ClockBloc>(
                  create: (context) => ClockBloc.fixed(startTime),
                ),
                BlocProvider<MemoplannerSettingsBloc>.value(
                  value: mockMemoplannerSettingsBloc,
                ),
                BlocProvider<ActivitiesBloc>(
                    create: (_) => FakeActivitiesBloc()),
                BlocProvider<SupportPersonsCubit>(
                    create: (_) => FakeSupportPersonsCubit()),
                BlocProvider<EditActivityCubit>(
                  create: (context) => EditActivityCubit.newActivity(
                    day: today,
                    defaultsSettings: DefaultsAddActivitySettings(
                        alarm: mockMemoplannerSettingsBloc
                            .state.addActivity.defaults.alarm),
                    basicActivityData: basicActivityData,
                    calendarId: 'calendarId',
                  ),
                ),
                BlocProvider<WizardCubit>(
                  create: (context) => ActivityWizardCubit.newActivity(
                    supportPersonsCubit:
                        FakeSupportPersonsCubit.withSupportPerson(),
                    activitiesBloc: context.read<ActivitiesBloc>(),
                    clockBloc: context.read<ClockBloc>(),
                    editActivityCubit: context.read<EditActivityCubit>(),
                    addActivitySettings: context
                        .read<MemoplannerSettingsBloc>()
                        .state
                        .addActivity,
                    showCategories: context
                        .read<MemoplannerSettingsBloc>()
                        .state
                        .calendar
                        .categories
                        .show,
                  ),
                ),
                BlocProvider<SortableBloc>.value(value: mockSortableBloc),
                BlocProvider<UserFileBloc>.value(value: mockUserFileBloc),
                BlocProvider<DayPickerBloc>(
                  create: (context) => DayPickerBloc(
                    clockBloc: context.read<ClockBloc>(),
                  ),
                ),
                BlocProvider<SpeechSettingsCubit>(
                  create: (context) => FakeSpeechSettingsCubit(),
                ),
                BlocProvider<PermissionCubit>(
                  create: (context) => PermissionCubit()..checkAll(),
                ),
                BlocProvider<WakeLockCubit>(
                  create: (context) => WakeLockCubit(
                    settingsDb: FakeSettingsDb(),
                    battery: FakeBattery(),
                    hasBattery: true,
                  ),
                ),
                BlocProvider<TimerCubit>.value(value: mockTimerCubit),
                BlocProvider<SpeechSettingsCubit>(
                  create: (context) => FakeSpeechSettingsCubit(),
                ),
                BlocProvider<VoicesCubit>(
                  create: (context) => FakeVoicesCubit(),
                ),
                BlocProvider<DayPartCubit>(
                  create: (context) => FakeDayPartCubit(),
                ),
              ],
              child: child!,
            ),
          ),
        );
      },
      home: Container(color: Colors.blueGrey),
    );
  }

  testWidgets('wizard shows all steps', (WidgetTester tester) async {
    await tester.pumpWidget(wizardPage(use24: true));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityWizardPage), findsOneWidget);
    expect(find.byType(TitleWiz), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'title');
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(ImageWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(FullDayWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(TimeWiz), findsOneWidget);
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '1337');
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(CategoryWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(CheckableWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(RemoveAfterWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(AvailableForWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlarmWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(RemindersWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(RecurringWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(ExtraFunctionWiz), findsOneWidget);
    await tester.tap(find.byType(SaveButton));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityWizardPage), findsNothing);
  });

  group('title step', () {
    const titleOnlyMemoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: false,
          title: true,
          fullDay: false,
          availability: false,
          checkable: false,
          removeAfter: false,
          alarm: false,
          notes: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('only title step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          titleOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TitleWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text(translate.missingTitleOrImage), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
    });

    testWidgets(
        'SGC-1805 submitting from the keyboard behaves the same as clicking next',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          titleOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TitleWiz), findsOneWidget);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text(translate.missingTitleOrImage), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'title');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
    });

    testWidgets('title and image shows no warning step',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: true,
                title: true,
                fullDay: false,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TitleWiz), findsOneWidget);

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ImageWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text(translate.missingTitleOrImage), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(ImageWiz), findsOneWidget);

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
    });

    testWidgets('title shows when going back', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          titleOnlyMemoSettings,
        ),
      );
      const title = 'title';
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      expect(find.text(title), findsNothing);

      await tester.enterText(find.byType(TextField), title);
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
      expect(find.text(title), findsNothing);

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('title from basic activity', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: true,
                date: false,
                image: false,
                title: true,
                fullDay: false,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      const title = 'testtitle';

      await tester.pumpWidget(
        wizardPage(
          basicActivityData: BasicActivityDataItem.createNew(title: title),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TitleWiz), findsOneWidget);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('SGC-1730 TTS play button appears when entering a title',
        (WidgetTester tester) async {
      setupFakeTts();
      const title = 'title';
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), title);
      await tester.pumpAndSettle();
      expect(find.byType(TtsPlayButton), findsOneWidget);
      expect(find.text(title), findsOneWidget);

      await tester.verifyTts(
        find.byType(TtsPlayButton),
        exact: title,
        useTap: true,
      );
    });
  });

  group('time step', () {
    testWidgets('time from basic activity', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: true,
                date: false,
                image: false,
                title: true,
                fullDay: false,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      const title = 'testtitle';

      await tester.pumpWidget(
        wizardPage(
          basicActivityData: BasicActivityDataItem.createNew(
            title: title,
            startTime: const Duration(hours: 5, minutes: 55),
            duration: const Duration(hours: 2, minutes: 5),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
      expect(find.byType(AbiliaClock), findsOneWidget);

      expect(find.text('05:55'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
    });

    testWidgets('can enter start and end time', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: true,
                fullDay: false,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      const title = 'testtitle';

      await tester.pumpWidget(wizardPage(use24: true));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), title);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
      expect(find.text('--:--'), findsNWidgets(2));

      await tester.enterTime(find.byKey(TestKey.startTimeInput), '1337');
      expect(find.text('13:37'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);

      await tester.enterTime(find.byKey(TestKey.endTimeInput), '1448');
      expect(find.text('--:--'), findsNothing);
      expect(find.text('13:37'), findsOneWidget);
      expect(find.text('14:48'), findsOneWidget);
    });

    testWidgets('time is saved', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: true,
                fullDay: false,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: false,
                reminders: true,
              ),
            ),
          ),
        ),
      );
      const title = 'testtitle';

      await tester.pumpWidget(wizardPage(use24: true));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), title);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      await tester.enterTime(find.byKey(TestKey.startTimeInput), '1337');
      await tester.enterTime(find.byKey(TestKey.endTimeInput), '1448');

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();

      expect(find.text('--:--'), findsNothing);
      expect(find.text('13:37'), findsOneWidget);
      expect(find.text('14:48'), findsOneWidget);
    });
  });

  group('full day step', () {
    const fullDayOnlyMemoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: false,
          title: false,
          fullDay: true,
          availability: false,
          checkable: false,
          removeAfter: false,
          alarm: false,
          notes: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('only full day step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          fullDayOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(FullDayWiz), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.restore), findsNWidgets(2));
    });

    testWidgets('Select full day removes time and category step',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: true,
                fullDay: true,
                availability: false,
                checkable: true,
                removeAfter: false,
                alarm: false,
                notes: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      expect(find.byType(TitleWiz), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(FullDayWiz), findsOneWidget);

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(TimeWiz), findsOneWidget);

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();
      expect(find.byType(FullDayWiz), findsOneWidget);

      await tester.tap(find.byType(SwitchField)); // all day radio
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(TimeWiz), findsNothing);
      expect(find.byType(CategoryWiz), findsNothing);
      expect(find.byType(CheckableWiz), findsOneWidget);
    });
  });

  group('category step', () {
    const fullDayAndCheckableMemoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: false,
          title: false,
          fullDay: true,
          availability: false,
          checkable: true,
          removeAfter: false,
          alarm: false,
          notes: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('Not checking full day activity shows category step',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          fullDayAndCheckableMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(FullDayWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
      await tester.enterTime(find.byKey(TestKey.startTimeInput), '1111');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryWiz), findsOneWidget);
    });

    testWidgets('If categories is off do not show category step',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            calendar: GeneralCalendarSettings(
              categories: CategoriesSettings(
                show: false,
              ),
            ),
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: false,
                fullDay: true,
                availability: false,
                checkable: true,
                removeAfter: false,
                alarm: false,
                notes: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(FullDayWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
      await tester.enterTime(find.byKey(TestKey.startTimeInput), '1111');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryWiz), findsNothing);
    });
  });

  group('available for step', () {
    const availableForOnlyMemoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          title: true,
          image: false,
          date: false,
          fullDay: false,
          removeAfter: false,
          availability: true,
          alarm: false,
          checkable: false,
          notes: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('only available for step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          availableForOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityWizardPage), findsOneWidget);

      await skipTitleTimeAndCategoryWidgets(tester);

      expect(find.byType(AvailableForWiz), findsOneWidget);
    });
  });

  group('checkable step', () {
    const checkableOnlyMemoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: false,
          title: true,
          fullDay: false,
          availability: false,
          checkable: true,
          removeAfter: false,
          alarm: false,
          notes: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('only checkable step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          checkableOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);

      await skipTitleTimeAndCategoryWidgets(tester);

      expect(find.byType(CheckableWiz), findsOneWidget);
    });
  });

  group('remove after step', () {
    const removeAfterOnlyMemoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: false,
          title: true,
          fullDay: false,
          availability: false,
          checkable: false,
          removeAfter: true,
          alarm: false,
          notes: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('only remove after step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(removeAfterOnlyMemoSettings),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);

      await skipTitleTimeAndCategoryWidgets(tester);

      expect(find.byType(RemoveAfterWiz), findsOneWidget);
    });
  });

  group('recurring step', () {
    const recurringOnly = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: true,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: false,
          title: false,
          fullDay: true,
          availability: false,
          checkable: false,
          removeAfter: false,
          alarm: false,
          notes: false,
          checklist: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('changing recurring changes save button',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(recurringOnly),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(FullDayWiz), findsOneWidget);
      await tester.tap(find.byType(SwitchField));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(RecurringWiz), findsOneWidget);
      expect(find.byType(SaveButton), findsOneWidget);
      expect(find.byType(NextButton), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(SaveButton), findsNothing);
      expect(find.byType(NextButton), findsOneWidget);

      await tester.tap(find.byIcon(AbiliaIcons.basicActivity)); // yearly
      await tester.pumpAndSettle();
      expect(find.byType(SaveButton), findsOneWidget);
      expect(find.byType(NextButton), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      expect(find.byType(SaveButton), findsNothing);
      expect(find.byType(NextButton), findsOneWidget);
    });

    testWidgets('weekly recurring shows weekly recurring',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: true,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: true,
                fullDay: true,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: false,
                checklist: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(FullDayWiz), findsOneWidget);
      await tester.tap(find.byType(SwitchField));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(RecurringWiz), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(RecurringWeeklyWiz), findsOneWidget);
      expect(find.byType(Weekdays), findsOneWidget);
      expect(find.byType(SelectAllWeekdaysButton), findsOneWidget);
      expect(find.byType(EveryOtherWeekSwitch), findsOneWidget);
      expect(find.byType(EndDateWizWidget), findsOneWidget);

      await tester.tap(find.text(translate.shortWeekday(today.weekday)));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(
        find.text(translate.recurringDataEmptyErrorMessage),
        findsOneWidget,
      );

      // Dismiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SelectAllWeekdaysButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(EndDatePickerWiz), findsOneWidget);
      expect(find.byType(SaveButton), findsOneWidget);

      await tester.tap(find.text('${today.day + 1}'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsNothing);
    });

    testWidgets('monthly recurring shows monthly recurring',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(const MemoplannerSettings(
          addActivity: AddActivitySettings(
            mode: AddActivityMode.stepByStep,
            general: GeneralAddActivitySettings(
              addRecurringActivity: true,
            ),
            stepByStep: StepByStepSettings(
              template: false,
              date: false,
              image: false,
              title: true,
              fullDay: true,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: false,
              checklist: false,
              reminders: false,
            ),
          ),
        )),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(FullDayWiz), findsOneWidget);
      await tester.tap(find.byType(SwitchField));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(RecurringWiz), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(RecurringMonthlyWiz), findsOneWidget);
      expect(find.byType(MonthDays), findsOneWidget);
      expect(find.byType(EndDateWizWidget), findsOneWidget);

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(
        find.text(translate.recurringDataEmptyErrorMessage),
        findsOneWidget,
      );

      // Dismiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.text('31'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(EndDatePickerWiz), findsOneWidget);
      expect(find.byType(SaveButton), findsOneWidget);

      await tester.tap(find.text('${today.day + 1}'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsNothing);
    });

    testWidgets('No end date defaults to selected',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: true,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: true,
                fullDay: true,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchField));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      // Assert
      final noEndDateSwitchValue = (find
              .byKey(TestKey.noEndDateSwitch)
              .evaluate()
              .first
              .widget as SwitchField)
          .value;
      expect(noEndDateSwitchValue, true);
    });
  });

  group('image step', () {
    const imageOnlyMemoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: true,
          title: false,
          fullDay: false,
          availability: false,
          checkable: false,
          removeAfter: false,
          alarm: false,
          notes: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('only image step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(imageOnlyMemoSettings),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(ImageWiz), findsOneWidget);
    });
  });

  group('reminders step', () {
    const remindersOnlyMemoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: false,
          title: false,
          fullDay: true,
          availability: false,
          checkable: false,
          removeAfter: false,
          alarm: false,
          checklist: false,
          notes: false,
          reminders: true,
        ),
      ),
    );

    testWidgets('reminders step present', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(remindersOnlyMemoSettings),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(FullDayWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(TimeWiz), findsOneWidget);
      await tester.enterTime(find.byKey(TestKey.startTimeInput), '1111');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(CategoryWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(RemindersWiz), findsOneWidget);
    });

    testWidgets('no reminders when full day', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(remindersOnlyMemoSettings),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(FullDayWiz), findsOneWidget);
      await tester.tap(find.byType(SwitchField));
      await tester.pumpAndSettle();
      expect(find.byType(NextButton), findsNothing);
      expect(find.byType(SaveButton), findsOneWidget);
    });
  });

  group('extra function step', () {
    testWidgets('Both show', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: false,
                fullDay: true,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: true,
                checklist: true,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchField)); // fullday
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExtraFunctionWiz), findsOneWidget);

      await tester.tap(find.byType(ChangeInfoItemPicker));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.infoItemChecklistRadio), findsOneWidget);
      expect(find.byKey(TestKey.infoItemNoteRadio), findsOneWidget);
    });

    testWidgets('only note show', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: false,
                fullDay: true,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: true,
                checklist: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchField)); // fullday
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExtraFunctionWiz), findsOneWidget);

      await tester.tap(find.byType(ChangeInfoItemPicker));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.infoItemChecklistRadio), findsNothing);
      expect(find.byKey(TestKey.infoItemNoteRadio), findsOneWidget);

      await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.byType(EditNoteWidget), findsOneWidget);
    });

    testWidgets('only checklist show', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              mode: AddActivityMode.stepByStep,
              general: GeneralAddActivitySettings(
                addRecurringActivity: false,
              ),
              stepByStep: StepByStepSettings(
                template: false,
                date: false,
                image: false,
                title: false,
                fullDay: true,
                availability: false,
                checkable: false,
                removeAfter: false,
                alarm: false,
                notes: false,
                checklist: true,
                reminders: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchField)); // fullday
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExtraFunctionWiz), findsOneWidget);

      await tester.tap(find.byType(ChangeInfoItemPicker));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.infoItemChecklistRadio), findsOneWidget);
      expect(find.byKey(TestKey.infoItemNoteRadio), findsNothing);

      await tester.tap(find.byKey(TestKey.infoItemChecklistRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.byType(EditChecklistWidget), findsOneWidget);
    });
  });

  group('alarm step', () {
    const memoSettings = MemoplannerSettings(
      addActivity: AddActivitySettings(
        mode: AddActivityMode.stepByStep,
        general: GeneralAddActivitySettings(
          addRecurringActivity: false,
        ),
        stepByStep: StepByStepSettings(
          template: false,
          date: false,
          image: false,
          title: false,
          fullDay: true,
          availability: false,
          checkable: false,
          removeAfter: false,
          alarm: true,
          notes: false,
          checklist: false,
          reminders: false,
        ),
      ),
    );

    testWidgets('alarm step shown', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          memoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      await tester.enterTime(
          find.byKey(TestKey.startTimeInput), '1111'); // time wiz
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(AlarmWiz), findsOneWidget);
    });

    testWidgets('no alarm step when fullDay', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          memoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SwitchField)); // fullday
      await tester.pumpAndSettle();

      expect(find.byType(SaveButton), findsOneWidget);
      expect(find.byType(AlarmWiz), findsNothing);
    });
  });
}
