import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/main.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest.dart' as tz;

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/app_pumper.dart';
import '../../test_helpers/enter_text.dart';
import '../../test_helpers/register_fallback_values.dart';
import '../../test_helpers/tts.dart';

void main() {
  final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
  final editTitleFieldFinder = find.byKey(TestKey.editTitleTextFormField);
  final saveEditActivityButtonFinder = find.byType(NextWizardStepButton);
  final addActivityButtonFinder = find.byKey(TestKey.addActivityButton);
  final addTimerButtonFinder = find.byKey(
    Config.isMPGO ? TestKey.addActivityButton : TestKey.addTimerButton,
  );

  final translate = Locales.language.values.first;

  Widget wrapWithMaterialApp(
    Widget widget, {
    MemoplannerSettingsBloc? memoplannerSettingBloc,
    SortableBloc? sortableBloc,
  }) =>
      TopLevelProvider(
        child: AuthenticationBlocProvider(
          child: AuthenticatedBlocsProvider(
            memoplannerSettingBloc: memoplannerSettingBloc,
            sortableBloc: sortableBloc,
            authenticatedState: const Authenticated(user: user),
            child: MaterialApp(
              theme: abiliaTheme,
              supportedLocales: Translator.supportedLocals,
              localizationsDelegates: const [Translator.delegate],
              localeResolutionCallback: (locale, supportedLocales) =>
                  supportedLocales.firstWhere(
                      (l) => l.languageCode == locale?.languageCode,
                      orElse: () => supportedLocales.first),
              home: Material(child: widget),
            ),
          ),
        ),
      );

  late ActivityDbInMemory mockActivityDb;
  late MockGenericDb mockGenericDb;
  late MockSortableDb mockSortableDb;
  late MockTimerDb mockTimerDb;
  late MockSupportPersonsDb mockSupportPersonsDb;
  late SharedPreferences fakeSharedPreferences;

  ActivityResponse activityResponse = () => [];
  SortableResponse sortableResponse = () => defaultSortables;
  GenericResponse genericResponse = () => [];
  SessionsResponse sessionResponse = () => fakeSessions;
  final initialDay = DateTime(2020, 08, 05);

  setUpAll(() {
    registerFallbackValues();
    scheduleNotificationsIsolated = noAlarmScheduler;
  });

  setUp(() async {
    setupPermissions();
    setupFakeTts();
    tz.initializeTimeZones();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;

    final mockFirebasePushService = MockFirebasePushService();
    when(() => mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));

    mockSupportPersonsDb = MockSupportPersonsDb();
    when(() => mockSupportPersonsDb.getAll()).thenAnswer(
      (_) => {
        const SupportPerson(
          id: 1,
          name: 'name',
          image: 'image',
        )
      },
    );

    mockActivityDb = ActivityDbInMemory();

    mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));
    when(() => mockGenericDb.getById(any()))
        .thenAnswer((_) => Future.value(null));
    when(() => mockGenericDb.insert(any())).thenAnswer((_) async {});
    when(() => mockGenericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));
    when(() => mockGenericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.getLastRevision())
        .thenAnswer((_) => Future.value(100));

    mockSortableDb = MockSortableDb();
    when(() => mockSortableDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(sortableResponse()));
    when(() => mockSortableDb.getById(any()))
        .thenAnswer((_) => Future.value(null));
    when(() => mockSortableDb.insert(any())).thenAnswer((_) async {});
    when(() => mockSortableDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));
    when(() => mockSortableDb.getAllDirty())
        .thenAnswer((_) => Future.value([]));
    when(() => mockSortableDb.getLastRevision())
        .thenAnswer((_) => Future.value(100));

    mockTimerDb = MockTimerDb();
    when(() => mockTimerDb.getAllTimers()).thenAnswer((_) => Future.value([]));
    when(() => mockTimerDb.insert(any())).thenAnswer((_) => Future.value(1));
    when(() => mockTimerDb.getRunningTimersFrom(any()))
        .thenAnswer((_) => Future.value([]));

    fakeSharedPreferences = await FakeSharedPreferences.getInstance();

    GetItInitializer()
      ..sharedPreferences = fakeSharedPreferences
      ..activityDb = mockActivityDb
      ..ticker = Ticker.fake(initialTime: initialDay)
      ..fireBasePushService = mockFirebasePushService
      ..client = fakeClient(
        activityResponse: () => activityResponse(),
        sortableResponse: () => sortableResponse(),
        genericResponse: () => genericResponse(),
        sessionsResponse: () => sessionResponse(),
      )
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..settingsDb = FakeSettingsDb()
      ..genericDb = mockGenericDb
      ..sortableDb = mockSortableDb
      ..database = FakeDatabase()
      ..battery = FakeBattery()
      ..timerDb = mockTimerDb
      ..deviceDb = FakeDeviceDb()
      ..supportPersonsDb = mockSupportPersonsDb
      ..init();
  });

  tearDown(() {
    activityResponse = () => [];
    sortableResponse = () => defaultSortables;
    genericResponse = () => [];
    sessionResponse = () => fakeSessions;
    GetIt.I.reset();
  });

  group('create new page', () {
    group('activities', () {
      testWidgets('New activity', (WidgetTester tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        await tester.tap(addActivityButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();
        expect(find.byType(EditActivityPage), findsOneWidget);
      });

      testWidgets(
        'Only show activity related options on MP',
        (WidgetTester tester) async {
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byKey(TestKey.newActivityChoice), findsOneWidget);
          expect(find.byKey(TestKey.basicActivityChoice), findsOneWidget);
          expect(find.byKey(TestKey.newTimerChoice), findsNothing);
          expect(find.byKey(TestKey.basicTimerChoice), findsNothing);
        },
        skip: Config.isMPGO,
      );

      testWidgets(
        'Only show activity related options if add timer button is hidden',
        (WidgetTester tester) async {
          final settings = Generic.createNew<GenericSettingData>(
            data: GenericSettingData.fromData(
              data: false,
              identifier: DisplaySettings.functionMenuDisplayNewTimerKey,
            ),
          );
          genericResponse = () => [settings];

          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byKey(TestKey.newActivityChoice), findsOneWidget);
          expect(find.byKey(TestKey.basicActivityChoice), findsOneWidget);
          expect(find.byKey(TestKey.newTimerChoice), findsNothing);
          expect(find.byKey(TestKey.basicTimerChoice), findsNothing);
        },
      );

      testWidgets('New activity with wizard, default steps',
          (WidgetTester tester) async {
        mockActivityDb.clear();
        final wizardSetting = Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: AddActivitySettings.addActivityTypeAdvancedKey,
          ),
        );
        genericResponse = () => [wizardSetting];

        const title = 'title';
        await tester.pumpApp(use24: true);
        await tester.tap(addActivityButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPage), findsOneWidget);

        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();
        expect(find.byType(TitleWiz), findsOneWidget);

        await tester.enterText(find.byType(TextField), title);
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
        await tester.tap(find.byKey(TestKey.checkableRadio));
        await tester.pumpAndSettle();
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

        expect(find.byType(RecurringWiz), findsOneWidget); // Recurrance
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(ExtraFunctionWiz), findsOneWidget);
        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();

        expect(find.byType(ActivityWizardPage), findsNothing);
        expect(find.byType(OneTimepillarCalendar), findsOneWidget);

        final activities = await mockActivityDb.getAllNonDeleted();
        final activity = activities.first;
        expect(activities.length, 1);
        expect(activity.title, title);
        expect(activity.checkable, true);
      });

      testWidgets('New activity with wizard, custom steps',
          (WidgetTester tester) async {
        final wizardSetting = Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: AddActivitySettings.addActivityTypeAdvancedKey,
          ),
        );
        final removeAfter = Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: StepByStepSettings.removeAfterKey,
          ),
        );
        final reminderStep = Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: StepByStepSettings.remindersKey,
          ),
        );
        final noBasic = Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: StepByStepSettings.templateKey,
          ),
        );
        final noImage = Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: StepByStepSettings.imageKey,
          ),
        );
        final noDate = Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: StepByStepSettings.dateKey,
          ),
        );
        genericResponse = () => [
              wizardSetting,
              removeAfter,
              reminderStep,
              noBasic,
              noImage,
              noDate,
            ];

        const title = 'title';
        await tester.pumpApp(use24: true);
        await tester.tap(addActivityButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();

        expect(find.byType(TitleWiz), findsOneWidget);
        await tester.enterText(find.byType(TextField), title);
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
        await tester.tap(find.byKey(TestKey.checkableRadio));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(RemoveAfterWiz), findsOneWidget);
        await tester.tap(find.byKey(TestKey.removeAfterRadio));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(AvailableForWiz), findsOneWidget);
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlarmWiz), findsOneWidget);
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(RemindersWiz), findsOneWidget);
        final fiveMinutesText = 5.minutes().toDurationString(translate);
        await tester.tap(find.text(fiveMinutesText));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(RecurringWiz), findsOneWidget);
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(ExtraFunctionWiz), findsOneWidget);
        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();

        expect(find.byType(ActivityWizardPage), findsNothing);
        expect(find.byType(OneTimepillarCalendar), findsOneWidget);

        final savedActivity = (await mockActivityDb.getAllNonDeleted()).first;
        expect(savedActivity.title, title);
        expect(savedActivity.checkable, true);
        expect(savedActivity.removeAfter, true);
        expect(savedActivity.reminders.length, 1);
        expect(savedActivity.reminders.first, 5.minutes());
      });

      group('Discard warning dialog activities', () {
        Future<void> navigateToEditActivityPage(WidgetTester tester) async {
          await tester.pumpApp();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.newActivityChoice));
          await tester.pumpAndSettle();
        }

        testWidgets(
            'Making a change and clicking previous triggers discard warning dialog',
            (WidgetTester tester) async {
          await navigateToEditActivityPage(tester);
          expect(find.byType(EditActivityPage), findsOneWidget);
          await tester.tap(find.byKey(TestKey.fullDaySwitch));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();
          expect(find.byType(EditActivityPage), findsOneWidget);
          expect(find.byType(DiscardWarningDialog), findsOneWidget);
        });

        testWidgets('Accept discard changes pops back',
            (WidgetTester tester) async {
          await navigateToEditActivityPage(tester);
          expect(find.byType(EditActivityPage), findsOneWidget);
          await tester.tap(find.byKey(TestKey.fullDaySwitch));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();
          expect(find.byType(DiscardWarningDialog), findsOneWidget);
          await tester.tap(find.text('Discard'));
          await tester.pumpAndSettle();
          expect(find.byType(DiscardWarningDialog), findsNothing);
          expect(find.byType(EditActivityPage), findsNothing);
        });

        testWidgets('Keep editing keeps user on the edit activity page',
            (WidgetTester tester) async {
          await navigateToEditActivityPage(tester);
          expect(find.byType(EditActivityPage), findsOneWidget);
          await tester.tap(find.byKey(TestKey.fullDaySwitch));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();
          expect(find.byType(DiscardWarningDialog), findsOneWidget);
          await tester.tap(find.text('Keep editing'));
          await tester.pumpAndSettle();
          expect(find.byType(DiscardWarningDialog), findsNothing);
          expect(find.byType(EditActivityPage), findsOneWidget);
        });

        testWidgets(
            'Making no change and clicking previous do not trigger discard warning dialog',
            (WidgetTester tester) async {
          await navigateToEditActivityPage(tester);
          expect(find.byType(EditActivityPage), findsOneWidget);
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();
          expect(find.byType(EditActivityPage), findsNothing);
          expect(find.byType(DiscardWarningDialog), findsNothing);
        });
      });

      group('basic activity', () {
        testWidgets('No option for basic activity when step-by-step',
            (WidgetTester tester) async {
          genericResponse = () => [
                Generic.createNew<GenericSettingData>(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: AddActivitySettings.addActivityTypeAdvancedKey,
                  ),
                ),
                Generic.createNew<GenericSettingData>(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: StepByStepSettings.templateKey,
                  ),
                ),
              ];
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byType(CreateNewPage),
              Config.isMP ? findsNothing : findsOneWidget);
          expect(find.byKey(TestKey.basicActivityChoice), findsNothing);
        });

        testWidgets('No option for basic activity when option set',
            (WidgetTester tester) async {
          genericResponse = () => [
                Generic.createNew<GenericSettingData>(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: EditActivitySettings.templateKey,
                  ),
                ),
              ];
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byType(CreateNewPage),
              Config.isMP ? findsNothing : findsOneWidget);
          expect(find.byKey(TestKey.basicActivityChoice), findsNothing);
        });

        testWidgets(
            'BUG - 2060 can save when template activity when option not set',
            (WidgetTester tester) async {
          genericResponse = () => [
                Generic.createNew<GenericSettingData>(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: EditActivitySettings.templateKey,
                  ),
                ),
              ];
          // Act - Go to add activity page
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          if (Config.isMPGO) {
            await tester.tap(find.byKey(TestKey.newActivityChoice));
            await tester.pumpAndSettle();
          }
          expect(find.byType(EditActivityPage), findsOneWidget);
          // Act - fill in min
          await tester.tap(find.byKey(TestKey.fullDaySwitch));
          await tester.pumpAndSettle();
          await tester.ourEnterText(editTitleFieldFinder, 'title');
          // Act - save
          await tester.tap(find.byType(SaveButton));
          await tester.pumpAndSettle();
          // Assert - Back at CalendarPage
          expect(find.byType(CalendarPage), findsOneWidget);
          expect(find.widgetWithText(ActivityCard, 'title'), findsOneWidget);
        });

        testWidgets(
            'New activity - name and title off: only basic activity choice ',
            (WidgetTester tester) async {
          genericResponse = () => [
                Generic.createNew(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: EditActivitySettings.titleKey,
                  ),
                ),
                Generic.createNew(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: EditActivitySettings.imageKey,
                  ),
                ),
              ];
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byType(CreateNewPage),
              Config.isMP ? findsNothing : findsOneWidget);
          expect(find.byKey(TestKey.newActivityChoice), findsNothing);
          expect(find.byKey(TestKey.basicActivityChoice),
              Config.isMP ? findsNothing : findsOneWidget);
        });

        testWidgets('Empty message when no basic activities',
            (WidgetTester tester) async {
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();
          expect(find.text(translate.noTemplates), findsOneWidget);
        });

        testWidgets(
            'if wizard enabled, title and image disabled and '
            'one basic activites: No new activity option',
            (WidgetTester tester) async {
          genericResponse = () => [
                Generic.createNew<GenericSettingData>(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: AddActivitySettings.addActivityTypeAdvancedKey,
                  ),
                ),
                Generic.createNew<GenericSettingData>(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: StepByStepSettings.titleKey,
                  ),
                ),
                Generic.createNew<GenericSettingData>(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: StepByStepSettings.imageKey,
                  ),
                ),
              ];

          final basicActivity = Sortable.createNew(
            data: BasicActivityDataItem.createNew(title: 'title'),
          );

          sortableResponse = () => [basicActivity];

          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byKey(TestKey.newActivityChoice), findsNothing);
          expect(find.byKey(TestKey.basicActivityChoice),
              Config.isMP ? findsNothing : findsOneWidget);
        });

        testWidgets('New activity from basic activity gets correct title',
            (WidgetTester tester) async {
          await initializeDateFormatting();
          final sortableBlocMock = MockSortableBloc();
          const title = 'testtitle';
          when(() => sortableBlocMock.state)
              .thenReturn(SortablesLoaded(sortables: [
            Sortable.createNew<BasicActivityDataItem>(
              data: BasicActivityDataItem.createNew(title: title),
            ),
          ]));
          when(() => sortableBlocMock.stream)
              .thenAnswer((realInvocation) => const Stream.empty());
          await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
              sortableBloc: sortableBlocMock));
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();
          expect(find.byType(ListLibrary<BasicActivityData>), findsOneWidget);
          expect(find.byType(ListDataItem), findsOneWidget);
          expect(find.text(title), findsOneWidget);
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();
          expect(find.byType(EditActivityPage), findsOneWidget);
          final nameAndPicture = find.byType(NameAndPictureWidget);
          expect(nameAndPicture, findsOneWidget);
          final nameAndPictureWidget =
              tester.firstWidget(nameAndPicture) as NameAndPictureWidget;
          expect(nameAndPictureWidget.text, title);
          expect(find.text(title), findsOneWidget);
        });

        testWidgets(
            'SGC-860 New activity from basic activity starting 00:00 has no start time',
            (WidgetTester tester) async {
          await initializeDateFormatting();
          final sortableBlocMock = MockSortableBloc();
          const title = 'testtitle';
          when(() => sortableBlocMock.state)
              .thenReturn(SortablesLoaded(sortables: [
            Sortable.createNew<BasicActivityDataItem>(
              data: BasicActivityDataItem.createNew(
                title: title,
                startTime: Duration.zero,
              ),
            ),
          ]));
          when(() => sortableBlocMock.stream)
              .thenAnswer((realInvocation) => const Stream.empty());

          await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
              sortableBloc: sortableBlocMock));
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();
          final dateAndTime = tester
              .widget<TimeIntervalPicker>(find.byType(TimeIntervalPicker));
          final timeInterval = dateAndTime.timeInterval;
          expect(timeInterval, TimeInterval(startDate: initialDay));
          expect(find.text('00:00'), findsNothing);
        });

        testWidgets('basic activity library navigation',
            (WidgetTester tester) async {
          await initializeDateFormatting();
          final sortableBlocMock = MockSortableBloc();
          const title = 'testtitle', folderTitle = 'folderTitle';

          final folder = Sortable.createNew<BasicActivityDataFolder>(
            isGroup: true,
            data: BasicActivityDataFolder.createNew(name: folderTitle),
          );
          when(() => sortableBlocMock.state)
              .thenReturn(SortablesLoaded(sortables: [
            Sortable.createNew<BasicActivityDataItem>(
                data: BasicActivityDataItem.createNew(title: title),
                groupId: folder.id),
            folder,
          ]));
          when(() => sortableBlocMock.stream)
              .thenAnswer((realInvocation) => const Stream.empty());

          //Act
          await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
              sortableBloc: sortableBlocMock));
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();

          // Act Go to basic activity archive
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();

          // Act Go to into folder
          await tester.tap(find.byIcon(AbiliaIcons.folder));
          await tester.pumpAndSettle();

          // Assert no folder, one item, nothing selected
          expect(find.byIcon(AbiliaIcons.folder), findsNothing);
          expect(find.byType(TemplatePickField<BasicActivityData>),
              findsOneWidget);
          expect(find.text(title), findsOneWidget);
          expect(find.text(folderTitle), findsOneWidget);

          // Act - Go back
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();

          expect(find.byIcon(AbiliaIcons.folder), findsOneWidget);

          // Act - Go back
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();

          // Assert back at create acitivy page
          expect(find.byType(CreateNewPage), findsOneWidget);
          expect(
            find.byType(SortableLibrary<BasicActivityData>),
            findsNothing,
          );

          // Act - Go back
          await tester.tap(find.byType(CancelButton));
          await tester.pumpAndSettle();

          // Assert - Back at calendar page
          expect(find.byType(CalendarPage), findsOneWidget);
        });

        testWidgets('basic activity library navigation SAVE from edit page',
            (WidgetTester tester) async {
          await initializeDateFormatting();
          final sortableBlocMock = MockSortableBloc();
          const title = 'testtitle';
          when(() => sortableBlocMock.state)
              .thenReturn(SortablesLoaded(sortables: [
            Sortable.createNew<BasicActivityDataItem>(
              data: BasicActivityDataItem.createNew(
                title: title,
                startTime: const Duration(hours: 11),
              ),
            ),
          ]));
          when(() => sortableBlocMock.stream)
              .thenAnswer((realInvocation) => const Stream.empty());

          //Act
          await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
              sortableBloc: sortableBlocMock));
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();

          // Act Go to basic activity archive
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();

          expect(find.byType(BasicActivityPickerPage), findsOneWidget);
          // Act - choose basic activity
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();

          expect(find.byType(EditActivityPage), findsOneWidget);

          // Act - save
          await tester.tap(find.byType(NextWizardStepButton));
          await tester.pumpAndSettle();

          // Assert - Back at picker page
          expect(find.byType(BasicActivityPickerPage), findsNothing);
          expect(find.byType(CalendarPage), findsOneWidget);
        });

        testWidgets('basic activity library navigation back from edit page',
            (WidgetTester tester) async {
          await initializeDateFormatting();
          final sortableBlocMock = MockSortableBloc();
          const title = 'testtitle';
          when(() => sortableBlocMock.state)
              .thenReturn(SortablesLoaded(sortables: [
            Sortable.createNew<BasicActivityDataItem>(
              data: BasicActivityDataItem.createNew(title: title),
            ),
          ]));
          when(() => sortableBlocMock.stream)
              .thenAnswer((realInvocation) => const Stream.empty());

          //Act
          await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
              sortableBloc: sortableBlocMock));
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();

          // Act Go to basic activity archive
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();

          expect(find.byType(BasicActivityPickerPage), findsOneWidget);
          // Act - Select item
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();

          expect(find.byType(EditActivityPage), findsOneWidget);

          // Act - Go back
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();

          // Assert - Back at picker page
          expect(find.byType(CreateNewPage), findsOneWidget);
          expect(find.byType(BasicActivityPickerPage), findsNothing);
        });

        testWidgets(
            'Bug SGC-627 Previous button after selecting a Basic Activity',
            (WidgetTester tester) async {
          await initializeDateFormatting();
          final sortableBlocMock = MockSortableBloc();
          const title = 'testtitle';
          when(() => sortableBlocMock.state)
              .thenReturn(SortablesLoaded(sortables: [
            Sortable.createNew<BasicActivityDataItem>(
              data: BasicActivityDataItem.createNew(title: title),
            ),
          ]));
          when(() => sortableBlocMock.stream)
              .thenAnswer((realInvocation) => const Stream.empty());

          //Act
          await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
              sortableBloc: sortableBlocMock));
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();

          // Act Go to basic activity archive
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();

          expect(find.byType(BasicActivityPickerPage), findsOneWidget);
          // Act - Select item
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();

          // Act - Go back
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();

          // Assert - Back at picker page
          expect(find.byType(CreateNewPage), findsOneWidget);
          expect(find.byType(BasicActivityPickerPage), findsNothing);
        });
      });
    });

    testWidgets('Can edit activity', (WidgetTester tester) async {
      const title1 = 'Titel uno';
      const newTitle = 'A brand new title!';

      final d = initialDay.add(12.hours());
      final aFinder = find.text(title1);

      final activities = [Activity.createNew(title: title1, startTime: d)];
      mockActivityDb.initWithActivities(activities);
      fakeSharedPreferences.setInt(
        DayCalendarViewSettings.viewOptionsCalendarTypeKey,
        DayCalendarType.list.index,
      );
      await tester.pumpWidget(const App());
      await tester.pumpAndSettle();
      await tester.tap(aFinder);
      await tester.pumpAndSettle();
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.ourEnterText(editTitleFieldFinder, newTitle);
      await tester.tap(saveEditActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.activityBackButton));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityCard), findsOneWidget);
      expect(find.text(newTitle), findsOneWidget);
      expect(aFinder, findsNothing);
    });

    group('timers', () {
      testWidgets(
        'Only show timer related options on MP',
        (WidgetTester tester) async {
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addTimerButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byKey(TestKey.newActivityChoice), findsNothing);
          expect(find.byKey(TestKey.basicActivityChoice), findsNothing);
          expect(find.byKey(TestKey.newTimerChoice), findsOneWidget);
          expect(find.byKey(TestKey.basicTimerChoice), findsOneWidget);
        },
        skip: Config.isMPGO,
      );

      testWidgets(
        'Only show timer related options if add activity button is hidden',
        (WidgetTester tester) async {
          final settings = Generic.createNew<GenericSettingData>(
            data: GenericSettingData.fromData(
              data: false,
              identifier: DisplaySettings.functionMenuDisplayNewActivityKey,
            ),
          );
          genericResponse = () => [settings];

          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addTimerButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byKey(TestKey.newActivityChoice), findsNothing);
          expect(find.byKey(TestKey.basicActivityChoice), findsNothing);
          expect(find.byKey(TestKey.newTimerChoice), findsOneWidget);
          expect(find.byKey(TestKey.basicTimerChoice), findsOneWidget);
        },
      );

      group('Timers mpgo mp4 session', () {
        testWidgets(
          'with mp4 session show timer on MPGO ',
          (WidgetTester tester) async {
            await tester.pumpWidget(const App());
            await tester.pumpAndSettle();
            await tester.tap(addActivityButtonFinder);
            await tester.pumpAndSettle();
            expect(find.byKey(TestKey.newActivityChoice), findsOneWidget);
            expect(find.byKey(TestKey.basicActivityChoice), findsOneWidget);
            expect(find.byKey(TestKey.newTimerChoice), findsOneWidget);
            expect(find.byKey(TestKey.basicTimerChoice), findsOneWidget);
          },
        );

        testWidgets(
          'without mp4 session dont show timer on mpgo ',
          (WidgetTester tester) async {
            sessionResponse = () => [];
            await tester.pumpWidget(const App());
            await tester.pumpAndSettle();
            await tester.tap(addActivityButtonFinder);
            await tester.pumpAndSettle();
            expect(find.byKey(TestKey.newActivityChoice), findsOneWidget);
            expect(find.byKey(TestKey.basicActivityChoice), findsOneWidget);
            expect(find.byKey(TestKey.newTimerChoice), findsNothing);
            expect(find.byKey(TestKey.basicTimerChoice), findsNothing);
          },
        );
      }, skip: !Config.isMPGO);

      testWidgets('from scratch, with automatically set name from typing',
          (WidgetTester tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        await tester.tap(addTimerButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPage), findsOneWidget);

        await tester.tap(find.byKey(TestKey.newTimerChoice));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerPage), findsOneWidget);

        await tester.tap(find.byType(PickField));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerDurationPage), findsOneWidget);

        await tester.enterTime(find.byKey(TestKey.minutes), '20');
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        expect(find.text('20 minutes'), findsOneWidget);

        await tester.tap(find.byType(StartButton));
        await tester.pumpAndSettle();
        expect(find.byType(TimerPage), findsOneWidget);
        expect(find.text('20 minutes'), findsOneWidget);

        await tester.tap(find.byIcon(AbiliaIcons.navigationPrevious));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        expect(find.byType(TimerTimepillarCard), findsOneWidget);
        expect(find.text('20 minutes'), findsOneWidget);

        final captured =
            verify(() => mockTimerDb.insert(captureAny())).captured;
        final savedTimer = captured.single as AbiliaTimer;
        expect(savedTimer.duration, 20.minutes());
        expect(
            savedTimer.title,
            const Duration(minutes: 20)
                .toDurationString(translate, shortMin: false));
        expect(savedTimer.paused, false);
        expect(savedTimer.pausedAt, Duration.zero);
      });

      testWidgets('from scratch, with automatically set name from timer wheel',
          (WidgetTester tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        await tester.tap(addTimerButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.newTimerChoice));
        await tester.pumpAndSettle();

        final timerWheel = find.byType(TimerWheel);
        final offset = Offset(tester.getSize(timerWheel).height / 3, 5);
        await tester.tapAt(tester.getCenter(timerWheel) + offset);
        await tester.pumpAndSettle();
        expect(find.text('45 minutes'), findsOneWidget);

        await tester.tap(find.byType(StartButton));
        await tester.pumpAndSettle();
        expect(find.byType(TimerPage), findsOneWidget);
        expect(find.text('45 minutes'), findsOneWidget);

        await tester.tap(find.byIcon(AbiliaIcons.navigationPrevious));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        expect(find.byType(TimerTimepillarCard), findsOneWidget);
        expect(find.text('45 minutes'), findsOneWidget);

        final captured =
            verify(() => mockTimerDb.insert(captureAny())).captured;
        final savedTimer = captured.single as AbiliaTimer;
        expect(savedTimer.duration, 45.minutes());
        expect(
            savedTimer.title,
            const Duration(minutes: 45)
                .toDurationString(translate, shortMin: false));
        expect(savedTimer.paused, false);
        expect(savedTimer.pausedAt, Duration.zero);
      });

      testWidgets('duration text updates when timer wheel is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        await tester.tap(addTimerButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.newTimerChoice));
        await tester.pumpAndSettle();
        expect(find.text('00:00'), findsOneWidget);

        final timerWheel = find.byType(TimerWheel);
        final offset = Offset(tester.getSize(timerWheel).height / 3, 5);
        await tester.tapAt(tester.getCenter(timerWheel) + offset);
        await tester.pumpAndSettle();
        expect(find.text('00:45'), findsOneWidget);
      });

      testWidgets('from scratch, with custom name',
          (WidgetTester tester) async {
        NameInput timerNameWidget() =>
            tester.firstWidget(find.byKey(TestKey.timerNameText)) as NameInput;

        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        await tester.tap(addTimerButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.newTimerChoice));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PickField));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerDurationPage), findsOneWidget);

        // Setting the timer duration updates the timer name
        await tester.enterTime(find.byKey(TestKey.minutes), '20');
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerPage), findsOneWidget);
        expect(timerNameWidget().text, '20 minutes');

        // Can set the timer name manually
        const emptyTimerName = '';
        await tester.tap(find.byKey(TestKey.timerNameText));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(TestKey.input), emptyTimerName);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        expect(timerNameWidget().text, emptyTimerName);

        // The timer name doesn't change after it has been set manually
        await tester.tap(find.byType(PickField));
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(TestKey.minutes), '15');
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        expect(timerNameWidget().text, emptyTimerName);

        // Tapping timer wheel doesn't change timer name
        final timerWheel = find.byType(TimerWheel);
        final offset = Offset(tester.getSize(timerWheel).height / 3, 5);
        await tester.tapAt(tester.getCenter(timerWheel) - offset);
        await tester.pumpAndSettle();
        expect(timerNameWidget().text, emptyTimerName);

        await tester.tap(find.byType(StartButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.navigationPrevious));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        expect(find.byType(TimerTimepillarCard), findsOneWidget);
        expect(find.byType(TimerTopInfo), findsNothing);

        final captured =
            verify(() => mockTimerDb.insert(captureAny())).captured;
        final savedTimer = captured.single as AbiliaTimer;
        expect(savedTimer.duration, 15.minutes());
        expect(savedTimer.title, emptyTimerName);
        expect(savedTimer.paused, false);
        expect(savedTimer.pausedAt, Duration.zero);
      });

      testWidgets('basic timer gets correct title and duration',
          (WidgetTester tester) async {
        await initializeDateFormatting();
        final sortableBlocMock = MockSortableBloc();
        const title = 'Basictajmer';
        when(() => sortableBlocMock.state)
            .thenReturn(SortablesLoaded(sortables: [
          Sortable.createNew<BasicTimerDataItem>(
            data: BasicTimerDataItem.fromJson(
                '{"duration":60000,"title":"$title"}'),
          ),
        ]));
        when(() => sortableBlocMock.stream)
            .thenAnswer((_) => const Stream.empty());
        await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
            sortableBloc: sortableBlocMock));
        await tester.pumpAndSettle();
        await tester.tap(addTimerButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.basicTimerChoice));
        await tester.pumpAndSettle();
        expect(find.byType(ListLibrary<BasicTimerData>), findsOneWidget);
        expect(
          find.byType(TemplatePickField<BasicTimerData>),
          findsOneWidget,
        );
        expect(find.text(title), findsOneWidget);
        expect(find.text(const Duration(milliseconds: 60000).toHMSorMS()),
            findsOneWidget);

        await tester
            .tap(find.widgetWithIcon(IconAndTextButton, AbiliaIcons.playSound));
        await tester.pumpAndSettle();
        expect(find.byType(TimerPage), findsOneWidget);
        expect(find.text(title), findsOneWidget);
      });

      testWidgets('basic timer library navigation',
          (WidgetTester tester) async {
        await initializeDateFormatting();
        final sortableBlocMock = MockSortableBloc();
        const title = 'testtitle', folderTitle = 'folderTitle';

        final folder = Sortable.createNew<BasicTimerDataFolder>(
          isGroup: true,
          data: BasicTimerDataFolder.createNew(name: folderTitle),
        );
        when(() => sortableBlocMock.state)
            .thenReturn(SortablesLoaded(sortables: [
          Sortable.createNew<BasicTimerDataItem>(
            data: BasicTimerDataItem.fromJson(
              '{"duration":60000,"title":"$title"}',
            ),
            groupId: folder.id,
          ),
          folder,
        ]));
        when(() => sortableBlocMock.stream)
            .thenAnswer((realInvocation) => const Stream.empty());

        //Act
        await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
            sortableBloc: sortableBlocMock));
        await tester.pumpAndSettle();
        await tester.tap(addTimerButtonFinder);
        await tester.pumpAndSettle();

        // Act Go to basic timer archive
        await tester.tap(find.byKey(TestKey.basicTimerChoice));
        await tester.pumpAndSettle();

        // Act Go to into folder
        await tester.tap(find.byKey(TestKey.basicTimerLibraryFolder));
        await tester.pumpAndSettle();

        // Assert no folder, one item
        expect(find.byKey(TestKey.basicTimerLibraryFolder), findsNothing);
        expect(find.byType(TemplatePickField<BasicTimerData>), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        expect(find.text(folderTitle), findsOneWidget);

        // Act - Go back
        await tester.tap(find.byType(PreviousButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PreviousButton));
        await tester.pumpAndSettle();

        // Assert back at create new page
        expect(find.byType(CreateNewPage), findsOneWidget);
        expect(find.byKey(TestKey.basicTimerLibraryFolder), findsNothing);

        // Act - Go back
        await tester.tap(find.byType(CancelButton));
        await tester.pumpAndSettle();

        // Assert - Back at calendar page
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      group('Discard warning dialog timers', () {
        Future<void> navigateToEditTimerPage(WidgetTester tester) async {
          await tester.pumpWidget(const App());
          await tester.pumpAndSettle();
          await tester.tap(addTimerButtonFinder);
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.newTimerChoice));
          await tester.pumpAndSettle();
        }

        testWidgets(
            'Making a change and clicking previous triggers discard warning dialog',
            (WidgetTester tester) async {
          await navigateToEditTimerPage(tester);

          final timerWheel = find.byType(TimerWheel);
          final offset = Offset(tester.getSize(timerWheel).height / 3, 5);
          await tester.tapAt(tester.getCenter(timerWheel) + offset);
          await tester.pumpAndSettle();
          expect(find.text('00:45'), findsOneWidget);

          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();
          expect(find.byType(EditTimerPage), findsOneWidget);
          expect(find.byType(DiscardWarningDialog), findsOneWidget);
        });

        testWidgets(
            'Making no change and clicking previous do not trigger discard warning dialog',
            (WidgetTester tester) async {
          await navigateToEditTimerPage(tester);
          expect(find.byType(EditTimerPage), findsOneWidget);
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();
          expect(find.byType(EditTimerPage), findsNothing);
          expect(find.byType(DiscardWarningDialog), findsNothing);
        });
      });
    });

    group('Skip create new page only on MP', () {
      testWidgets('Only activity shown skips create new page on MP',
          (WidgetTester tester) async {
        genericResponse = () => [
              Generic.createNew<GenericSettingData>(
                data: GenericSettingData.fromData(
                  data: false,
                  identifier: DisplaySettings.functionMenuDisplayNewTimerKey,
                ),
              ),
              Generic.createNew<GenericSettingData>(
                data: GenericSettingData.fromData(
                  data: false,
                  identifier: EditActivitySettings.templateKey,
                ),
              ),
            ];
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        await tester.tap(addActivityButtonFinder);
        await tester.pumpAndSettle();
        expect(
          find.byType(Config.isMP ? ActivityWizardPage : CreateNewPage),
          findsOneWidget,
        );
      });

      testWidgets('Only basic activity shown skips create new page on MP',
          (WidgetTester tester) async {
        genericResponse = () => [
              Generic.createNew<GenericSettingData>(
                data: GenericSettingData.fromData(
                  data: false,
                  identifier: DisplaySettings.functionMenuDisplayNewTimerKey,
                ),
              ),
              Generic.createNew<GenericSettingData>(
                data: GenericSettingData.fromData(
                  data: false,
                  identifier: EditActivitySettings.titleKey,
                ),
              ),
              Generic.createNew<GenericSettingData>(
                data: GenericSettingData.fromData(
                  data: false,
                  identifier: EditActivitySettings.imageKey,
                ),
              ),
            ];
        await tester.pumpWidget(const App());
        await tester.pumpAndSettle();
        await tester.tap(addActivityButtonFinder);
        await tester.pumpAndSettle();
        expect(
          find.byType(Config.isMP ? BasicActivityPickerPage : CreateNewPage),
          findsOneWidget,
        );
      });
    });
  });
}
