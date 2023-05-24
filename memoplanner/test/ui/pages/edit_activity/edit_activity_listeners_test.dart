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
import '../../../mocks/mocks.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  final startTime = DateTime(2020, 02, 10, 15, 30);
  final today = startTime.onlyDays();
  final startActivity = Activity.createNew(
    title: '',
    startTime: startTime,
  );
  final translate = Locales.language.values.first;

  final timeFieldFinder = find.byType(TimeIntervalPicker);
  final okButtonFinder = find.byType(OkButton);

  late MockActivitiesBloc mockActivitiesBloc;
  late MockActivityRepository mockActivityRepository;
  late MemoplannerSettingsBloc mockMemoplannerSettingsBloc;

  setUpAll(() {
    registerFallbackValues();
    tz.initializeTimeZones();
  });

  setUp(() async {
    await initializeDateFormatting();
    mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state).thenReturn(ActivitiesChanged());
    when(() => mockActivitiesBloc.stream)
        .thenAnswer((_) => const Stream.empty());
    mockActivityRepository = MockActivityRepository();
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([]));
    when(() => mockActivitiesBloc.activityRepository)
        .thenReturn(mockActivityRepository);
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
    GetItInitializer()
      ..fileStorage = FakeFileStorage()
      ..database = FakeDatabase()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..init();
  });

  tearDown(GetIt.I.reset);

  Widget createEditActivityPage({
    Activity? givenActivity,
    bool use24H = false,
    bool newActivity = false,
  }) {
    final activity = givenActivity ?? startActivity;
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
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24H),
          child: FakeAuthenticatedBlocsProvider(
            child: MultiBlocProvider(
              providers: [
                BlocProvider<ClockBloc>(
                  create: (context) => ClockBloc.fixed(startTime),
                ),
                BlocProvider<MemoplannerSettingsBloc>(
                  create: (_) => mockMemoplannerSettingsBloc,
                ),
                BlocProvider<ActivitiesBloc>.value(value: mockActivitiesBloc),
                BlocProvider<SupportPersonsCubit>.value(
                  value: FakeSupportPersonsCubit(),
                ),
                BlocProvider<EditActivityCubit>(
                  create: (context) => newActivity
                      ? EditActivityCubit.newActivity(
                          day: today,
                          defaultsSettings: context
                              .read<MemoplannerSettingsBloc>()
                              .state
                              .addActivity
                              .defaults,
                          calendarId: 'calendarId',
                        )
                      : EditActivityCubit.edit(
                          ActivityDay(activity, today),
                        ),
                ),
                BlocProvider<WizardCubit>(
                  create: (context) => newActivity
                      ? ActivityWizardCubit.newActivity(
                          supportPersonsCubit: FakeSupportPersonsCubit(),
                          activitiesBloc: context.read<ActivitiesBloc>(),
                          clockBloc: context.read<ClockBloc>(),
                          editActivityCubit: context.read<EditActivityCubit>(),
                          addActivitySettings: context
                              .read<MemoplannerSettingsBloc>()
                              .state
                              .addActivity,
                        )
                      : ActivityWizardCubit.edit(
                          activitiesBloc: context.read<ActivitiesBloc>(),
                          clockBloc: context.read<ClockBloc>(),
                          editActivityCubit: context.read<EditActivityCubit>(),
                          allowPassedStartTime: context
                              .read<MemoplannerSettingsBloc>()
                              .state
                              .addActivity
                              .general
                              .allowPassedStartTime,
                        ),
                ),
                BlocProvider<SortableBloc>(create: (_) => FakeSortableBloc()),
                BlocProvider<UserFileBloc>(create: (_) => FakeUserFileBloc()),
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
                BlocProvider<TimerCubit>(
                  create: (context) => MockTimerCubit(),
                ),
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
      home: Container(color: Colors.amber),
    );
  }

  final submitButtonFinder = find.byType(NextWizardStepButton);

  testWidgets('pressing add activity button with no title nor time shows error',
      (WidgetTester tester) async {
    // Act press submit
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert error message
    expect(
        find.text(translate.missingTitleOrImageAndStartTime), findsOneWidget);
    // Act dissmiss
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    // Assert no error message
    expect(find.text(translate.missingTitleOrImageAndStartTime), findsNothing);
  });

  testWidgets('pressing add activity button without time shows error',
      (WidgetTester tester) async {
    const newActivtyName = 'new activity name';

    // Act press submit
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), newActivtyName);
    await tester.pumpAndSettle();

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert error message
    expect(find.text(translate.missingStartTime), findsOneWidget);
    // Act dissmiss
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    // Assert no error message
    expect(find.text(translate.missingStartTime), findsNothing);
  });

  testWidgets('pressing add activity button with no title shows error',
      (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();
    // Act press fullday
    await tester.scrollDown(dy: -150);
    await tester.tap(find.byKey(TestKey.fullDaySwitch));
    await tester.pumpAndSettle();

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert error message
    expect(find.text(translate.missingTitleOrImage), findsOneWidget);
    // Act dissmiss
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();
    // Assert no error message
    expect(find.text(translate.missingTitleOrImage), findsNothing);
  });

  testWidgets(
      'pressing add activity on other tab scrolls back to main page on error',
      (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act go to tab
    await tester.goToAlarmTab();
    await tester.pumpAndSettle();
    // Assert not at main tab
    expect(find.byType(MainTab), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert error message
    expect(
        find.text(translate.missingTitleOrImageAndStartTime), findsOneWidget);

    // Act dissmiss
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    // Assert at main tab
    expect(find.byType(MainTab), findsOneWidget);
  });

  testWidgets('pressing add activity before now shows warning',
      (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();
    await tester.scrollDown(dy: -100);

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '0133');
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmWarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.text(translate.startTimeBeforeNowWarning), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // // Assert - finds nothing
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.text(translate.startTimeBeforeNowWarning), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });

  testWidgets(
      'pressing add activity before now with no title shows error no warning',
      (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();
    await tester.scrollDown(dy: -100);

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '0133');
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act -- press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert -- no title error message, no warning
    expect(find.byType(ErrorDialog), findsOneWidget);
    expect(find.text(translate.missingTitleOrImage), findsOneWidget);
    expect(find.byType(ConfirmWarningDialog), findsNothing);

    // Act -- dissmiss, enter title, press submit
    await tester.tap(
      find.descendant(
        of: find.byType(ErrorDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollDown(dy: 100);
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert now show warning
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);
    expect(find.byType(ErrorDialog), findsNothing);

    // Act -- Ok the warning
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert -- leaves editactivitypage
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });

  Future<void> testRecurrenceError(WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act -- enter title
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'activityName');
    await tester.pumpAndSettle();
    await tester.scrollDown(dy: -100);

    // Act -- set time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '1130');
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act -- go to recurrence tab
    await tester.goToRecurrenceTab();
    await tester.pumpAndSettle();

    // Act -- set to weekly, deselect all days
    await tester.tap(find.byIcon(AbiliaIcons.week));
    await tester.pumpAndSettle();
    await tester.tap(find.byWidgetPredicate(
        (widget) => widget is SelectableField && widget.selected));
    await tester.pumpAndSettle();

    // Act -- go to main tab
    await tester.goToTab(AbiliaIcons.myPhotos);
    await tester.pumpAndSettle();

    // Act -- press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert -- error message
    expect(find.text(translate.recurringDataEmptyErrorMessage), findsOneWidget);

    // Act -- dissmiss
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    // Assert -- at recurrence tab
    expect(find.byType(RecurrenceTab), findsOneWidget);
  }

  testWidgets(
      'pressing add activity on other tab scrolls to recurring page on recurrence error',
      (WidgetTester tester) async {
    await testRecurrenceError(tester);
  });

  testWidgets(
      'pressing add activity on other tab scrolls to recurring page on recurrence error, when InfoItemTab is hidden',
      (WidgetTester tester) async {
    // Act -- hide InfoItemTab
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
      MemoplannerSettingsLoaded(
        const MemoplannerSettings(
          addActivity: AddActivitySettings(
            editActivity: EditActivitySettings(notes: false, checklist: false),
          ),
        ),
      ),
    );

    // Assert -- InfoItemTab hidden
    expect(
        find.byWidgetPredicate((widget) =>
            widget is TabItem && widget.iconData == AbiliaIcons.attachment),
        findsNothing);

    // Assert -- works with InfoItemTab hidden
    await testRecurrenceError(tester);
  });

  testWidgets(
      'saving recurring activity without end date tab scrolls '
      'to recurring page and shows error', (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act -- enter title
    await tester.ourEnterText(find.byKey(TestKey.editTitleTextFormField), 'AW');
    await tester.pumpAndSettle();
    await tester.scrollDown(dy: -100);

    // Act -- set time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '1130');
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act -- go to recurrence tab
    await tester.goToRecurrenceTab();
    await tester.pumpAndSettle();

    // Act -- set to weekly, deselect all days
    await tester.tap(find.byIcon(AbiliaIcons.week));
    await tester.pumpAndSettle();

    // Act -- turn off no end date
    await tester.scrollDown(dy: -250);
    await tester.tap(find.text(translate.noEndDate));
    await tester.pumpAndSettle();

    // Act -- go to main tab
    await tester.goToTab(AbiliaIcons.myPhotos);
    await tester.pumpAndSettle();

    // Act -- press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert -- error message
    expect(
        find.text(translate.endDateNotSpecifiedErrorMessage), findsOneWidget);

    // Act -- dissmiss
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    // Assert -- at recurrence tab
    expect(find.byType(RecurrenceTab), findsOneWidget);
  });

  testWidgets(
      'edit recurring activity TDO change time before now shows warning',
      (WidgetTester tester) async {
    final edit = Activity.createNew(
      title: 'recurring',
      startTime: startTime.subtract(40.days()),
      recurs: Recurs.everyDay,
    );
    await tester.pumpWidget(createEditActivityPage(givenActivity: edit));
    await tester.pumpAndSettle();
    await tester.scrollDown(dy: -100);

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '0133');
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act -- press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert -- select recurrence page shows
    expect(find.byType(SelectRecurrentTypePage), findsOneWidget);

    // Act -- this day onlu selected, pressing OK
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert -- before now warning
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act -- Ok the warning
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert -- leaves editactivitypage
    expect(find.byType(SelectRecurrentTypePage), findsNothing);
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });

  testWidgets('pressing add activity with conflict shows warning',
      (WidgetTester tester) async {
    // Arrange
    final conflicting = Activity.createNew(
      title: 'conflict',
      startTime: startTime,
      duration: 30.minutes(),
    );
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([conflicting]));
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();
    await tester.scrollDown(dy: -100);

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '0333');
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmWarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.text(translate.conflictWarning), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // // Assert - finds nothing
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.text(translate.conflictWarning), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });

  testWidgets('add activity with conflict and before now shows both warning',
      (WidgetTester tester) async {
    // Arrange
    final conflictingActivity = Activity.createNew(
      title: 'conflict',
      startTime: startTime.subtract(10.minutes()),
      duration: 30.minutes(),
    );
    when(() => mockActivityRepository.allBetween(any(), any()))
        .thenAnswer((_) => Future.value([conflictingActivity]));
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();
    await tester.scrollDown(dy: -100);

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.startTimeInput), '0325');
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message before now
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmWarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(ConfirmWarningDialog), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message before now
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert warning message conflict
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert - finds nothing
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });
}

extension on WidgetTester {
  Future scrollDown({double dy = -800.0}) async {
    final center = getCenter(find.byType(EditActivityPage));
    await dragFrom(center, Offset(0.0, dy));
    await pump();
  }

  Future goToAlarmTab() async => goToTab(AbiliaIcons.attention);

  Future goToRecurrenceTab() async => goToTab(AbiliaIcons.repeat);

  Future goToTab(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }
}
