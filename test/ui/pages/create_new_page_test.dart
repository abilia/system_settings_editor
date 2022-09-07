import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';
import '../../mocks/mocks.dart';

import '../../test_helpers/app_pumper.dart';
import '../../test_helpers/register_fallback_values.dart';
import '../../test_helpers/tts.dart';
import '../../test_helpers/enter_text.dart';
import '../../test_helpers/activity_db_in_memory.dart';

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
    MemoplannerSettingBloc? memoplannerSettingBloc,
    SortableBloc? sortableBloc,
  }) =>
      TopLevelProvider(
        child: AuthenticatedBlocsProvider(
          memoplannerSettingBloc: memoplannerSettingBloc,
          sortableBloc: sortableBloc,
          authenticatedState: const Authenticated(userId: 1),
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
      );

  late ActivityDbInMemory mockActivityDb;
  late MockGenericDb mockGenericDb;
  late MockSortableDb mockSortableDb;
  late MockTimerDb mockTimerDb;

  ActivityResponse activityResponse = () => [];
  SortableResponse sortableResponse = () => [];
  GenericResponse genericResponse = () => [];
  final initialDay = DateTime(2020, 08, 05);

  setUpAll(() {
    registerFallbackValues();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;
  });

  setUp(() async {
    setupPermissions();
    setupFakeTts();
    tz.initializeTimeZones();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    final mockFirebasePushService = MockFirebasePushService();
    when(() => mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));

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

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker.fake(initialTime: initialDay)
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client(
        activityResponse: activityResponse,
        sortableResponse: sortableResponse,
        genericResponse: genericResponse,
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
      ..init();
  });

  tearDown(() {
    activityResponse = () => [];
    sortableResponse = () => [];
    genericResponse = () => [];
    GetIt.I.reset();
  });

  group('create new page', () {
    group('activities', () {
      testWidgets('New activity', (WidgetTester tester) async {
        await tester.pumpWidget(App());
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
          await tester.pumpWidget(App());
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
          final settings = Generic.createNew<MemoplannerSettingData>(
            data: MemoplannerSettingData.fromData(
              data: false,
              identifier: DisplaySettings.functionMenuDisplayNewTimerKey,
            ),
          );
          genericResponse = () => [settings];

          await tester.pumpWidget(App());
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
        final wizardSetting = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
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

        expect(find.byType(AvailableForWiz), findsOneWidget);
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(RecurringWiz), findsOneWidget); // Recurrance
        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();

        expect(find.byType(ActivityWizardPage), findsNothing);
        expect(find.byType(OneTimepillarCalendar), findsOneWidget);

        final activities = await mockActivityDb.getAll();
        final activity = activities.first;
        expect(activities.length, 1);
        expect(activity.title, title);
        expect(activity.checkable, true);
      });

      testWidgets('New activity with wizard, custom steps',
          (WidgetTester tester) async {
        final wizardSetting = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: AddActivitySettings.addActivityTypeAdvancedKey,
          ),
        );
        final removeAfter = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: StepByStepSettings.removeAfterKey,
          ),
        );
        final reminderStep = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: StepByStepSettings.remindersKey,
          ),
        );
        final noBasic = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: StepByStepSettings.templateKey,
          ),
        );
        final noImage = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: StepByStepSettings.imageKey,
          ),
        );
        final noDate = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
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

        expect(find.byType(RemindersWiz), findsOneWidget);
        final fiveMinutesText = 5.minutes().toDurationString(translate);
        await tester.tap(find.text(fiveMinutesText));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(RecurringWiz), findsOneWidget);
        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();

        expect(find.byType(ActivityWizardPage), findsNothing);
        expect(find.byType(OneTimepillarCalendar), findsOneWidget);

        final savedActivity = (await mockActivityDb.getAll()).first;
        expect(savedActivity.title, title);
        expect(savedActivity.checkable, true);
        expect(savedActivity.removeAfter, true);
        expect(savedActivity.reminders.length, 1);
        expect(savedActivity.reminders.first, 5.minutes());
      });

      group('basic activity', () {
        testWidgets('No option for basic activity when step-by-step',
            (WidgetTester tester) async {
          genericResponse = () => [
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: AddActivitySettings.addActivityTypeAdvancedKey,
                  ),
                ),
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: StepByStepSettings.templateKey,
                  ),
                ),
              ];
          await tester.pumpWidget(App());
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
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: EditActivitySettings.templateKey,
                  ),
                ),
              ];
          await tester.pumpWidget(App());
          await tester.pumpAndSettle();
          await tester.tap(addActivityButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byType(CreateNewPage),
              Config.isMP ? findsNothing : findsOneWidget);
          expect(find.byKey(TestKey.basicActivityChoice), findsNothing);
        });

        testWidgets(
            'New activity - name and title off: only basic activity choice ',
            (WidgetTester tester) async {
          genericResponse = () => [
                Generic.createNew(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: EditActivitySettings.titleKey,
                  ),
                ),
                Generic.createNew(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: EditActivitySettings.imageKey,
                  ),
                ),
              ];
          await tester.pumpWidget(App());
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
          await tester.pumpWidget(App());
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
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: AddActivitySettings.addActivityTypeAdvancedKey,
                  ),
                ),
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: StepByStepSettings.titleKey,
                  ),
                ),
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: StepByStepSettings.imageKey,
                  ),
                ),
              ];

          final basicActivity = Sortable.createNew(
            data: BasicActivityDataItem.createNew(title: 'title'),
          );

          sortableResponse = () => [basicActivity];

          await tester.pumpWidget(App());
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
              .widget<TimeIntervallPicker>(find.byType(TimeIntervallPicker));
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
          expect(find.byType(BasicTemplatePickField<BasicActivityData>),
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
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                  data: DayCalendarType.list.index,
                  identifier: MemoplannerSettings.viewOptionsTimeViewKey),
            ),
          ];

      await tester.pumpWidget(App());
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
          await tester.pumpWidget(App());
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
          final settings = Generic.createNew<MemoplannerSettingData>(
            data: MemoplannerSettingData.fromData(
              data: false,
              identifier: DisplaySettings.functionMenuDisplayNewActivityKey,
            ),
          );
          genericResponse = () => [settings];

          await tester.pumpWidget(App());
          await tester.pumpAndSettle();
          await tester.tap(addTimerButtonFinder);
          await tester.pumpAndSettle();
          expect(find.byKey(TestKey.newActivityChoice), findsNothing);
          expect(find.byKey(TestKey.basicActivityChoice), findsNothing);
          expect(find.byKey(TestKey.newTimerChoice), findsOneWidget);
          expect(find.byKey(TestKey.basicTimerChoice), findsOneWidget);
        },
      );

      testWidgets('from scratch, with automatically set name from typing',
          (WidgetTester tester) async {
        await tester.pumpWidget(App());
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
        expect(find.byType(TimerTimepillardCard), findsOneWidget);
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
        await tester.pumpWidget(App());
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
        expect(find.byType(TimerTimepillardCard), findsOneWidget);
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
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(addTimerButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.newTimerChoice));
        await tester.pumpAndSettle();
        expect(find.text('00:00:00'), findsOneWidget);

        final timerWheel = find.byType(TimerWheel);
        final offset = Offset(tester.getSize(timerWheel).height / 3, 5);
        await tester.tapAt(tester.getCenter(timerWheel) + offset);
        await tester.pumpAndSettle();
        expect(find.text('00:45:00'), findsOneWidget);
      });

      testWidgets('from scratch, with custom name',
          (WidgetTester tester) async {
        NameInput timerNameWidget() =>
            tester.firstWidget(find.byKey(TestKey.timerNameText)) as NameInput;

        await tester.pumpWidget(App());
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
        expect(find.byType(TimerTimepillardCard), findsOneWidget);
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
          find.byType(BasicTemplatePickField<BasicTimerData>),
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
        expect(find.byType(BasicTemplatePickField<BasicTimerData>),
            findsOneWidget);
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
    });

    group('Skip create new page only on MP', () {
      testWidgets('Only activity shown skips create new page on MP',
          (WidgetTester tester) async {
        genericResponse = () => [
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier: DisplaySettings.functionMenuDisplayNewTimerKey,
                ),
              ),
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier: EditActivitySettings.templateKey,
                ),
              ),
            ];
        await tester.pumpWidget(App());
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
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier: DisplaySettings.functionMenuDisplayNewTimerKey,
                ),
              ),
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier: EditActivitySettings.titleKey,
                ),
              ),
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: false,
                  identifier: EditActivitySettings.imageKey,
                ),
              ),
            ];
        await tester.pumpWidget(App());
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
