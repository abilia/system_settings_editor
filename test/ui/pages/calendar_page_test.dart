import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';
import '../../mocks/mocks.dart';

import '../../test_helpers/register_fallback_values.dart';
import '../../test_helpers/tts.dart';
import '../../test_helpers/enter_text.dart';
import '../../test_helpers/tap_link.dart';
import '../../test_helpers/verify_generic.dart';

void main() {
  final nextDayButtonFinder = find.byIcon(AbiliaIcons.goToNextPage),
      previousDayButtonFinder = find.byIcon(AbiliaIcons.returnToPreviousPage);

  final translate = Locales.language.values.first;

  Future goToTimePillar(WidgetTester tester) async {
    await tester.tap(find.byType(EyeButtonDay));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.timeline));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.ok));
    await tester.pumpAndSettle();
  }

  final userRepository = UserRepository(
    client: Fakes.client(),
    tokenDb: FakeTokenDb(),
    userDb: FakeUserDb(),
    licenseDb: FakeLicenseDb(),
    baseUrl: 'fake',
  );

  Widget wrapWithMaterialApp(
    Widget widget, {
    MemoplannerSettingBloc? memoplannerSettingBloc,
    SortableBloc? sortableBloc,
  }) =>
      TopLevelBlocsProvider(
        baseUrl: 'test',
        child: AuthenticatedBlocsProvider(
          memoplannerSettingBloc: memoplannerSettingBloc,
          sortableBloc: sortableBloc,
          authenticatedState: Authenticated(
            token: '',
            userId: 1,
            userRepository: userRepository,
          ),
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

  late MockActivityDb mockActivityDb;
  late MockGenericDb mockGenericDb;
  late MockSortableDb mockSortableDb;
  late MockTimerDb mockTimerDb;

  ActivityResponse activityResponse = () => [];
  SortableResponse sortableResponse = () => [];
  final initialDay = DateTime(2020, 08, 05);

  setUpAll(() {
    registerFallbackValues();
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

    mockActivityDb = MockActivityDb();
    when(() => mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activityResponse()));
    when(() => mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value([]));
    when(() => mockActivityDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));
    when(() => mockActivityDb.getLastRevision())
        .thenAnswer((_) => Future.value(100));
    when(() => mockActivityDb.insert(any()))
        .thenAnswer((_) => Future.value(100));

    mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value([]));
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
    when(() => mockTimerDb.insert(any())).thenAnswer((_) => Future.value());

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker(
          stream: StreamController<DateTime>().stream, initialTime: initialDay)
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client(
        activityResponse: activityResponse,
        sortableResponse: sortableResponse,
      )
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..settingsDb = FakeSettingsDb()
      ..genericDb = mockGenericDb
      ..sortableDb = mockSortableDb
      ..database = FakeDatabase()
      ..battery = FakeBattery()
      ..timerDb = mockTimerDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('calendar page', () {
    group('create new activity', () {
      testWidgets('New activity', (WidgetTester tester) async {
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AddButton));
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();
        expect(find.byType(EditActivityPage), findsOneWidget);
      });

      testWidgets('New activity with wizard, default steps',
          (WidgetTester tester) async {
        final wizardSetting = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.addActivityTypeAdvancedKey,
          ),
        );
        when(() => mockGenericDb.getAllNonDeletedMaxRevision())
            .thenAnswer((_) => Future.value([wizardSetting]));

        const title = 'title';
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AddButton));
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPage), findsOneWidget);

        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();
        expect(find.byType(DatePickerWiz), findsOneWidget);

        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();
        expect(find.byType(TitleWiz), findsOneWidget);

        await tester.enterText(find.byType(TextField), title);
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(ImageWiz), findsOneWidget);
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        await tester.pumpAndSettle();
        expect(find.byType(AvailableForWiz), findsOneWidget);
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(CheckableWiz), findsOneWidget);
        await tester.tap(find.byKey(TestKey.checkableRadio));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(TimeWiz), findsOneWidget);
        await tester.enterText(find.byKey(TestKey.startTimeInput), '1337');
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(RecurringWiz), findsOneWidget); // Recurrance
        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();

        expect(find.byType(ActivityWizardPage), findsNothing);
        expect(find.byType(Agenda), findsOneWidget);

        final captured =
            verify(() => mockActivityDb.insertAndAddDirty(captureAny()))
                .captured;
        final savedActivity = captured.single.single as Activity;
        expect(savedActivity.title, title);
        expect(savedActivity.checkable, true);
      });

      testWidgets('New activity with wizard, custom steps',
          (WidgetTester tester) async {
        final wizardSetting = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.addActivityTypeAdvancedKey,
          ),
        );
        final removeAfter = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: WizardStepsSettings.wizardRemoveAfterStepKey,
          ),
        );
        final reminderStep = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: WizardStepsSettings.wizardRemindersStepKey,
          ),
        );
        final noBasic = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: WizardStepsSettings.wizardTemplateStepKey,
          ),
        );
        final noImage = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: WizardStepsSettings.wizardImageStepKey,
          ),
        );
        final noDate = Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: WizardStepsSettings.wizardDatePickerStepKey,
          ),
        );
        when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
          (_) => Future.value(
            [
              wizardSetting,
              removeAfter,
              reminderStep,
              noBasic,
              noImage,
              noDate,
            ],
          ),
        );

        const title = 'title';
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AddButton));
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();

        expect(find.byType(TitleWiz), findsOneWidget);
        await tester.enterText(find.byType(TextField), title);
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        await tester.pumpAndSettle();
        expect(find.byType(AvailableForWiz), findsOneWidget);
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

        expect(find.byType(TimeWiz), findsOneWidget);
        await tester.enterText(find.byKey(TestKey.startTimeInput), '1337');
        await tester.pumpAndSettle();
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
        expect(find.byType(Agenda), findsOneWidget);

        final captured =
            verify(() => mockActivityDb.insertAndAddDirty(captureAny()))
                .captured;
        final savedActivity = captured.single.single as Activity;
        expect(savedActivity.title, title);
        expect(savedActivity.checkable, true);
        expect(savedActivity.removeAfter, true);
        expect(savedActivity.reminders.length, 1);
        expect(savedActivity.reminders.first, 5.minutes());
      });

      group('basic activity', () {
        testWidgets('No option for basic activity when option set',
            (WidgetTester tester) async {
          when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
            (_) => Future.value(
              [
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: MemoplannerSettings.advancedActivityTemplateKey,
                  ),
                ),
              ],
            ),
          );
          await tester.pumpWidget(App());
          await tester.pumpAndSettle();
          await tester.tap(find.byType(AddButton));
          await tester.pumpAndSettle();
          expect(find.byType(CreateNewPage), findsOneWidget);
          expect(find.byKey(TestKey.basicActivityChoice), findsNothing);
        });

        testWidgets('Empty message when no basic activities',
            (WidgetTester tester) async {
          await tester.pumpWidget(App());
          await tester.pumpAndSettle();
          await tester.tap(find.byType(AddButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();
          expect(find.text(translate.noBasicActivities), findsOneWidget);
        });

        testWidgets(
            'if wizard enabled, title and image disabled and '
            'one basic activites: No new activity option',
            (WidgetTester tester) async {
          when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
            (_) => Future.value(
              [
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: MemoplannerSettings.addActivityTypeAdvancedKey,
                  ),
                ),
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: WizardStepsSettings.wizardTitleStepKey,
                  ),
                ),
                Generic.createNew<MemoplannerSettingData>(
                  data: MemoplannerSettingData.fromData(
                    data: false,
                    identifier: WizardStepsSettings.wizardImageStepKey,
                  ),
                ),
              ],
            ),
          );

          final basicActivity = Sortable.createNew(
            data: BasicActivityDataItem.createNew(title: 'title'),
          );

          sortableResponse = () => [basicActivity];

          await tester.pumpWidget(App());
          await tester.pumpAndSettle();
          await tester.tap(find.byType(AddButton));
          await tester.pumpAndSettle();
          expect(find.byKey(TestKey.newActivityChoice), findsNothing);
          expect(find.byKey(TestKey.basicActivityChoice), findsOneWidget);
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
          await tester.tap(find.byType(AddButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();
          expect(
              find.byType(SortableLibrary<BasicActivityData>), findsOneWidget);
          expect(find.byType(BasicActivityLibraryItem), findsOneWidget);
          expect(find.text(title), findsOneWidget);
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(NextButton));
          await tester.pumpAndSettle();
          expect(find.byType(EditActivityPage), findsOneWidget);
          final nameAndPicture = find.byType(NameAndPictureWidget);
          expect(nameAndPicture, findsOneWidget);
          final nameAndPictureWidget =
              tester.firstWidget(nameAndPicture) as NameAndPictureWidget;
          expect(nameAndPictureWidget.text, title);
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
          await tester.tap(find.byType(AddButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(NextButton));
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
          await tester.tap(find.byType(AddButton));
          await tester.pumpAndSettle();

          // Act Go to basic activity archive
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();

          // Act Go to into folder
          await tester.tap(find.byType(LibraryFolder));
          await tester.pumpAndSettle();

          // Assert no folder, on item, nothing selected, next button disabled
          expect(find.byType(LibraryFolder), findsNothing);
          expect(find.byType(BasicActivityLibraryItem), findsOneWidget);
          expect(find.text(title), findsOneWidget);
          expect(find.text(folderTitle), findsOneWidget);
          expect(
            tester.widget<NextButton>(find.byType(NextButton)).onPressed,
            isNull,
          );

          // Act - Select item
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();

          // Assert - Next button enabled
          expect(
            tester.widget<NextButton>(find.byType(NextButton)).onPressed,
            isNotNull,
          );

          // Act - Go back
          await tester.tap(find.byType(PreviousButton));
          await tester.pumpAndSettle();

          // Assert - Next button disabled, no folder
          expect(
            tester.widget<NextButton>(find.byType(NextButton)).onPressed,
            isNull,
          );
          expect(find.byType(LibraryFolder), findsOneWidget);

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
          await tester.tap(find.byType(AddButton));
          await tester.pumpAndSettle();

          // Act Go to basic activity archive
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();

          expect(find.byType(BasicActivityPickerPage), findsOneWidget);
          // Act - choose basic activity
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(NextButton));
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
          await tester.tap(find.byType(AddButton));
          await tester.pumpAndSettle();

          // Act Go to basic activity archive
          await tester.tap(find.byKey(TestKey.basicActivityChoice));
          await tester.pumpAndSettle();

          expect(find.byType(BasicActivityPickerPage), findsOneWidget);
          // Act - Select item
          await tester.tap(find.text(title));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(NextButton));
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
          await tester.tap(find.byType(AddButton));
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

    group('Add timer', () {
      testWidgets('New timer choice', (WidgetTester tester) async {
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AddButton));
        await tester.pumpAndSettle();
        expect(find.byType(CreateNewPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.newTimerChoice));
        await tester.pumpAndSettle();
        expect(find.byType(TimerWizardPage), findsOneWidget);
        expect(find.byType(TimerDurationWiz), findsOneWidget);
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerByTypingPage), findsOneWidget);

        await tester.enterText(find.byKey(TestKey.minutes), '20');
        await tester.pumpAndSettle();
        await tester.tap(find.byType(SaveButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();
        expect(find.byType(TimerStartWiz), findsOneWidget);

        await tester.tap(find.byType(StartButton));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);

        final captured =
            verify(() => mockTimerDb.insert(captureAny())).captured;
        final savedTimer = captured.single.single as AbiliaTimer;
        expect(savedTimer.duration, 20.minutes());
        expect(
            savedTimer.title,
            const Duration(minutes: 20)
                .toDurationString(translate, shortMin: false));
        expect(savedTimer.paused, false);
        expect(savedTimer.pausedAt, Duration.zero);
      });
    });

    testWidgets('navigation', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(tester.widget<DayAppBar>(find.byType(DayAppBar)).day, initialDay);
      await tester.tap(nextDayButtonFinder);
      await tester.tap(nextDayButtonFinder);
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<DayAppBar>(find.byType(DayAppBar)).day,
          initialDay.add(3.days()));
      await tester.tap(find.byType(GoToNowButton));
      await tester.pumpAndSettle();

      expect(tester.widget<DayAppBar>(find.byType(DayAppBar)).day, initialDay);
    });

    testWidgets('Tapping Day in TabBar returns to this week',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(nextDayButtonFinder);
      await tester.tap(nextDayButtonFinder);
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.day));
      await tester.pumpAndSettle();
      expect(tester.widget<DayAppBar>(find.byType(DayAppBar)).day, initialDay);
    });

    group('Premissions', () {
      final translate = Locales.language.values.first;

      tearDown(() {
        setupPermissions();
      });
      testWidgets('Notification permission is requested at start up',
          (WidgetTester tester) async {
        setupPermissions();
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(requestedPermissions, {Permission.notification});
      });

      testWidgets('Denied notifications shows popup and warnings',
          (WidgetTester tester) async {
        setupPermissions({
          Permission.notification: PermissionStatus.denied,
          Permission.systemAlertWindow: PermissionStatus.granted,
        });
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(
            find.byType(NotificationPermissionWarningDialog), findsOneWidget);
        await tester.tap(find.byType(CloseButton));
        expect(find.byType(OrangeDot), findsOneWidget);
        expect(find.byType(ErrorMessage), findsOneWidget);
      });

      testWidgets('Granted premission shows nothing',
          (WidgetTester tester) async {
        setupPermissions({
          Permission.notification: PermissionStatus.granted,
          Permission.systemAlertWindow: PermissionStatus.granted,
        });
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(NotificationPermissionWarningDialog), findsNothing);
        expect(find.byType(OrangeDot), findsNothing);
        expect(find.byType(ErrorMessage), findsNothing);
      });

      testWidgets('Denied systemAlertWindow shows warning dot',
          (WidgetTester tester) async {
        setupPermissions({
          Permission.notification: PermissionStatus.granted,
          Permission.systemAlertWindow: PermissionStatus.denied,
        });
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(OrangeDot), findsOneWidget);
      });

      testWidgets('Denied notifications tts', (WidgetTester tester) async {
        setupPermissions({Permission.notification: PermissionStatus.denied});
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.verifyTts(find.text(translate.allowNotifications),
            exact: translate.allowNotifications);
        final compound = translate.allowNotificationsDescription;
        await tester.verifyTts(find.byType(NotificationBodyTextWarning),
            exact: compound);
        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        await tester.verifyTts(find.byType(ErrorMessage),
            exact: translate.notificationsWarningText);
      });

      testWidgets('Denied notifications link to permission settings',
          (WidgetTester tester) async {
        setupPermissions({Permission.notification: PermissionStatus.denied});
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.tapTextSpan(translate.settingsLink), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(PermissionsPage), findsOneWidget);
      });
    });
  });

  group('Choosen calendar setting', () {
    final timepillarGeneric = Generic.createNew<MemoplannerSettingData>(
      data: MemoplannerSettingData.fromData(
        data: DayCalendarType.oneTimepillar.index,
        identifier: MemoplannerSettings.viewOptionsTimeViewKey,
      ),
    );

    testWidgets('no settings shows agenda', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(TimepillarCalendar), findsNothing);
      expect(find.byType(Agenda), findsOneWidget);
    });

    testWidgets(
        'timepillar is choosen in memoplanner settings shows timepillar view',
        (WidgetTester tester) async {
      when(() => mockGenericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value([timepillarGeneric]));

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(Agenda), findsNothing);
      expect(find.byType(TimepillarCalendar), findsOneWidget);
    });

    testWidgets('when calendar is changed, settings is saved unsynced',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await goToTimePillar(tester);

      verifyUnsyncGeneric(
        tester,
        mockGenericDb,
        key: MemoplannerSettings.viewOptionsTimeViewKey,
        matcher: DayCalendarType.oneTimepillar.index,
      );
    });
  });

  group('MemoPlanner settings', () {
    late MemoplannerSettingBloc memoplannerSettingBlocMock;

    setUp(() {
      initializeDateFormatting();
      memoplannerSettingBlocMock = MockMemoplannerSettingBloc();
      when(() => memoplannerSettingBlocMock.stream)
          .thenAnswer((_) => const Stream.empty());
    });

    testWidgets(
        'SGC-533 Can save full day on current day when activityTimeBeforeCurrent is false',
        (WidgetTester tester) async {
      const testActivityTitle = 'fulldayactivity';
      when(() => memoplannerSettingBlocMock.state)
          .thenReturn(const MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ));
      await tester.pumpWidget(wrapWithMaterialApp(
        const CalendarPage(),
      ));

      // Navigate to EditActivityPage
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AddButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.newActivityChoice));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
      expect(find.byType(CalendarPage), findsNothing);

      await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField), testActivityTitle);
      await tester.pumpAndSettle();
      await tester.dragFrom(tester.getCenter(find.byType(EditActivityPage)),
          const Offset(0.0, -200));
      await tester.pump();
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextWizardStepButton));
      await tester.pumpAndSettle();
      expect(find.text(translate.startTimeBeforeNowError), findsNothing);
      expect(find.byType(EditActivityPage), findsNothing);
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(find.text(testActivityTitle), findsOneWidget);
    });

    testWidgets(
        'SGC-533 Cannot save full day activity on yesterday when activityTimeBeforeCurrent is false',
        (WidgetTester tester) async {
      const testActivityTitle = 'fulldayactivity';
      when(() => memoplannerSettingBlocMock.state)
          .thenReturn(const MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ));
      await tester.pumpWidget(wrapWithMaterialApp(
        const CalendarPage(),
        memoplannerSettingBloc: memoplannerSettingBlocMock,
      ));

      // Navigate to EditActivityPage
      await tester.pumpAndSettle();
      await tester.tap(find.byType(AddButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.newActivityChoice));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
      expect(find.byType(CalendarPage), findsNothing);

      // Enter activity information
      await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField), testActivityTitle);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
          of: find.text('${initialDay.subtract(1.days()).day}'),
          matching: find.byType(MonthDayView)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.dragFrom(tester.getCenter(find.byType(EditActivityPage)),
          const Offset(0.0, -200));
      await tester.pump();
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextWizardStepButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(translate.startTimeBeforeNowError), findsOneWidget);
      expect(find.byType(EditActivityPage), findsOneWidget);
      expect(find.byType(CalendarPage), findsNothing);
    });

    group('Color settings', () {
      void _expectCorrectColor(WidgetTester tester, Color color) {
        final at = find.byKey(TestKey.animatedTheme);
        expect(at, findsOneWidget);
        final theme = tester.firstWidget(at) as AnimatedTheme;
        expect(theme.data.appBarTheme.backgroundColor, color);
      }

      const noDayColor = AbiliaColors.black80,
          mondayColor = AbiliaColors.green,
          tuesdayColor = AbiliaColors.blue,
          wednesdayColor = AbiliaColors.white,
          thursdayColor = AbiliaColors.thursdayBrown,
          fridayColor = AbiliaColors.yellow,
          saturdayColor = AbiliaColors.pink,
          sundayColor = AbiliaColors.sundayRed;

      testWidgets('Color settings with colors on all days',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarDayColor: DayColor.allDays.index),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, wednesdayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, thursdayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, fridayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, saturdayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, sundayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, mondayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, tuesdayColor);
      });

      testWidgets('Color settings with colors only on weekends',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(
              calendarDayColor: DayColor.saturdayAndSunday.index),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, saturdayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, sundayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
      });

      testWidgets('Color settings with no colors', (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarDayColor: DayColor.noColors.index),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, noDayColor);
      });
    });

    group('dayCaptionShowDayButtons settings', () {
      testWidgets('show next/previous day buttons',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(const MemoplannerSettingsLoaded(
          MemoplannerSettings(dayCaptionShowDayButtons: true),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();

        expect(nextDayButtonFinder, findsOneWidget);
        expect(previousDayButtonFinder, findsOneWidget);

        await goToTimePillar(tester);

        expect(nextDayButtonFinder, findsOneWidget);
        expect(previousDayButtonFinder, findsOneWidget);
      });

      testWidgets('do not show next/previous day buttons',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(const MemoplannerSettingsLoaded(
          MemoplannerSettings(dayCaptionShowDayButtons: false),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();

        expect(nextDayButtonFinder, findsNothing);
        expect(previousDayButtonFinder, findsNothing);

        await goToTimePillar(tester);

        expect(nextDayButtonFinder, findsNothing);
        expect(previousDayButtonFinder, findsNothing);
      });
    });

    group('calendarActivityTypeShowTypes setting', () {
      testWidgets('Timepillar is left when no categories',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(
            calendarActivityTypeShowTypes: false,
            viewOptionsTimeView: DayCalendarType.oneTimepillar.index,
          ),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();

        final w = find.byType(TimePillar);
        final topLeft = tester.getTopLeft(w);
        expect(topLeft.dx, 0);
      });

      testWidgets(
          'Center of timepillar is center of page when categories are on',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(
            calendarActivityTypeShowTypes: true,
            viewOptionsTimeView: DayCalendarType.oneTimepillar.index,
          ),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();

        final timepillarCenter = tester.getCenter(find.byType(TimePillar));
        final calendarCenter = tester.getCenter(find.byType(CalendarPage));
        expect(timepillarCenter.dx, calendarCenter.dx);
      });
    });
  });

  group('edit all day', () {
    const title1 = 'fulldaytitle1';
    const title2 = 'fullday title 2';
    const title3 = 'full day title 3';
    final date = initialDay.onlyDays();

    final day1Finder = find.text(title1);
    final day2Finder = find.text(title2);
    final day3Finder = find.text(title3);
    final cardFinder = find.byType(ActivityCard);
    final showAllFullDayButtonFinder =
        find.byType(ShowAllFullDayActivitiesButton);
    final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
    final editTitleFieldFinder = find.byKey(TestKey.editTitleTextFormField);
    final saveEditActivityButtonFinder = find.byType(NextWizardStepButton);
    final editPictureFinder = find.byKey(TestKey.addPicture);

    setUp(() {
      final fullDayActivities = [
        FakeActivity.fullday(date, title1),
        FakeActivity.fullday(date, title2),
        FakeActivity.fullday(date, title3),
      ];
      activityResponse = () => fullDayActivities;
      when(() => mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(fullDayActivities));
    });

    testWidgets('Show full days activity', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(day1Finder, findsOneWidget);
      expect(day2Finder, findsOneWidget);
      expect(day3Finder, findsNothing);
      expect(cardFinder, findsNWidgets(2));
      expect(showAllFullDayButtonFinder, findsOneWidget);
    });

    testWidgets('Show all full days activity list',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      expect(day1Finder, findsOneWidget);
      expect(day2Finder, findsOneWidget);
      expect(day3Finder, findsOneWidget);
      expect(cardFinder, findsNWidgets(3));
    });

    testWidgets('Show info on full days activity from activity list',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(day3Finder);
      await tester.pumpAndSettle();
      expect(day1Finder, findsNothing);
      expect(day2Finder, findsNothing);
      expect(day3Finder, findsOneWidget);
      expect(cardFinder, findsNothing);
      expect(find.byType(ActivityInfo), findsOneWidget);
    });

    testWidgets('Can show edit from full day list',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(day3Finder);
      await tester.pumpAndSettle();
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      expect(day3Finder, findsOneWidget);
      expect(find.byType(EditActivityPage), findsOneWidget);
    });

    testWidgets('Can edit from full day list', (WidgetTester tester) async {
      const newTitle = 'A brand new title!';
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(day3Finder);
      await tester.pumpAndSettle();
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.ourEnterText(editTitleFieldFinder, newTitle);
      await tester.tap(saveEditActivityButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text(newTitle), findsOneWidget);
    });

    testWidgets('Can edit from full day list shows on full day list',
        (WidgetTester tester) async {
      const newTitle = 'A brand new title!';
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(day3Finder);
      await tester.pumpAndSettle();
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.ourEnterText(editTitleFieldFinder, newTitle);
      await tester.tap(saveEditActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.activityBackButton));
      await tester.pumpAndSettle();

      expect(day1Finder, findsOneWidget);
      expect(day2Finder, findsOneWidget);
      expect(cardFinder, findsNWidgets(3));
      expect(day3Finder, findsNothing);
      expect(find.text(newTitle), findsOneWidget);
    });

    testWidgets('Can edit picture from full day list',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(day3Finder);
      await tester.pumpAndSettle();
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(editPictureFinder);
      await tester.pumpAndSettle();
      expect(find.byType(SelectPicturePage), findsOneWidget);
    });

    testWidgets('Can show image archive from full day list',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(day3Finder);
      await tester.pumpAndSettle();
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(editPictureFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.imageArchiveButton));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchivePage), findsOneWidget);
    });
  });

  group('Week calendar', () {
    const fridayTitle = 'f-r-i-d-a-y',
        nextWeekTitle = 'N-e-x-t week title',
        todaytitle = 't-o-d-a-y';
    final friday = initialDay.addDays(2);
    final nextWeek = initialDay.nextWeek();
    setUp(() {
      final activities = [
        FakeActivity.starts(initialDay, title: todaytitle),
        FakeActivity.starts(friday, title: fridayTitle),
        FakeActivity.starts(nextWeek, title: nextWeekTitle),
      ];
      activityResponse = () => activities;
      when(() => mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(activities));
    });
    testWidgets('Can navigate to week calendar', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('Activities are shown in week calendar',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.text(fridayTitle), findsOneWidget);
      expect(find.text(nextWeekTitle), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      expect(find.text(fridayTitle), findsNothing);
      expect(find.text(nextWeekTitle), findsOneWidget);
    });

    testWidgets('Tapping Week in TabBar returns to this week',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();
      expect(find.byType(GoToCurrentActionButton), findsOneWidget);
      await tester.verifyTts(find.byType(WeekAppBar), contains: 'week 30');
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(GoToCurrentActionButton), findsNothing);
      await tester.verifyTts(find.byType(WeekAppBar), contains: 'week 32');
    });

    testWidgets('Tapping week in TabBar, current day is selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(nextDayButtonFinder);
      await tester.tap(nextDayButtonFinder);
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      final allHeadings = tester.widgetList<WeekCalenderHeadingContent>(
          find.byType(WeekCalenderHeadingContent));

      final selected = allHeadings.firstWhere((element) => element.selected);

      expect(selected.day, initialDay);
    });

    testWidgets(
        'BUG SGC-756 tapping day goes back to that day calendar, then go back to now goes back to now',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(Agenda), findsOneWidget);

      expect(find.text(todaytitle), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
      await tester.tap(find.text(translate.shortWeekday(friday.weekday)));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
      await tester.tap(find.text(translate.shortWeekday(friday.weekday)));
      await tester.pumpAndSettle();

      expect(find.byType(Agenda), findsOneWidget);
      expect(find.text(fridayTitle), findsOneWidget);

      await tester.tap(find.byType(GoToNowButton));
      await tester.pumpAndSettle();
      expect(find.text(fridayTitle), findsNothing);
      expect(find.text(todaytitle), findsOneWidget);
    });

    testWidgets('Clicking activity in week calendar navigates to activity view',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(Agenda), findsOneWidget);

      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);

      await tester.tap(find.text(fridayTitle));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityPage), findsOneWidget);
      expect(find.text(fridayTitle), findsOneWidget);

      await tester.tap(find.byKey(TestKey.activityBackButton));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('BUG SGC-833 expanded day updates in when returning to week',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      final selectedHeadingsInitial = tester.widgetList(find.byWidgetPredicate(
          (widget) => widget is WeekCalenderHeadingContent && widget.selected));
      expect(selectedHeadingsInitial, hasLength(1));

      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();

      final selectedHeadingsnextWeekPreSelect = tester.widgetList(
          find.byWidgetPredicate((widget) =>
              widget is WeekCalenderHeadingContent && widget.selected));
      expect(selectedHeadingsnextWeekPreSelect, isEmpty);

      final d = initialDay.addDays(8).day;
      await tester.tap(find.text('$d'));
      await tester.pumpAndSettle();
      final selectedHeadingsnextWeekPostSelect = tester.widgetList(
          find.byWidgetPredicate((widget) =>
              widget is WeekCalenderHeadingContent && widget.selected));
      expect(selectedHeadingsnextWeekPostSelect, hasLength(1));

      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();

      final selectedHeadingsInitialPostSelect = tester.widgetList(
          find.byWidgetPredicate((widget) =>
              widget is WeekCalenderHeadingContent && widget.selected));
      expect(selectedHeadingsInitialPostSelect, isEmpty);

      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(GoToCurrentActionButton));
      await tester.pumpAndSettle();

      final goToCurrentSelect = tester.widgetList(find.byWidgetPredicate(
          (widget) => widget is WeekCalenderHeadingContent && widget.selected));
      expect(goToCurrentSelect, hasLength(1));
    });

    testWidgets('Overflow issue during development of SGC-754',
        (WidgetTester tester) async {
      final activities = [
        FakeActivity.starts(initialDay, title: 'one')
            .copyWith(startTime: initialDay.add(const Duration(hours: 1))),
        FakeActivity.starts(initialDay, title: 'two')
            .copyWith(startTime: initialDay.add(const Duration(hours: 2))),
        FakeActivity.starts(initialDay, title: 'three')
            .copyWith(startTime: initialDay.add(const Duration(hours: 3))),
        FakeActivity.starts(initialDay, title: 'four')
            .copyWith(startTime: initialDay.add(const Duration(hours: 4))),
        FakeActivity.starts(initialDay, title: 'five')
            .copyWith(startTime: initialDay.add(const Duration(hours: 5))),
        FakeActivity.starts(initialDay, title: 'six')
            .copyWith(startTime: initialDay.add(const Duration(hours: 6))),
        FakeActivity.starts(initialDay, title: 'seven')
            .copyWith(startTime: initialDay.add(const Duration(hours: 7))),
        FakeActivity.starts(initialDay, title: 'eight')
            .copyWith(startTime: initialDay.add(const Duration(hours: 8))),
        FakeActivity.starts(initialDay, title: 'nine')
            .copyWith(startTime: initialDay.add(const Duration(hours: 9))),
        FakeActivity.starts(initialDay, title: 'ten')
            .copyWith(startTime: initialDay.add(const Duration(hours: 10))),
        FakeActivity.starts(initialDay, title: 'eleven')
            .copyWith(startTime: initialDay.add(const Duration(hours: 11))),
        FakeActivity.starts(initialDay, title: 'twelve')
            .copyWith(startTime: initialDay.add(const Duration(hours: 12))),
      ];
      activityResponse = () => activities;
      when(() => mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(activities));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.text('one'), findsOneWidget);
      expect(find.text('twelve'), findsOneWidget);
    });
  });

  group('disable alarm button', () {
    late MemoplannerSettingBloc memoplannerSettingBlocMock;

    setUp(() {
      initializeDateFormatting();
      memoplannerSettingBlocMock = MockMemoplannerSettingBloc();
      when(() => memoplannerSettingBlocMock.stream)
          .thenAnswer((_) => const Stream.empty());
    });

    testWidgets('displays alarm button', (WidgetTester tester) async {
      when(() => memoplannerSettingBlocMock.state)
          .thenReturn(const MemoplannerSettingsLoaded(
        MemoplannerSettings(alarm: AlarmSettings(showAlarmOnOffSwitch: true)),
      ));

      await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      expect(find.byType(MonthCalendarTab), findsOneWidget);
      expect(find.byType(MonthAppBar), findsOneWidget);
      expect(find.byType(ToggleAlarmButton), findsOneWidget);
    });

    testWidgets("don't display alarm button", (WidgetTester tester) async {
      when(() => memoplannerSettingBlocMock.state)
          .thenReturn(const MemoplannerSettingsLoaded(
        MemoplannerSettings(alarm: AlarmSettings(showAlarmOnOffSwitch: false)),
      ));

      await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      expect(find.byType(MonthCalendarTab), findsOneWidget);
      expect(find.byType(MonthAppBar), findsOneWidget);
      expect(find.byType(ToggleAlarmButton), findsNothing);
    });

    testWidgets('SGC-1129 alarm button toggleable',
        (WidgetTester tester) async {
      final expectedTime = initialDay.nextDay().millisecondsSinceEpoch;
      when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: AlarmSettings.showAlarmOnOffSwitchKey,
              ),
            )
          ],
        ),
      );

      await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage()));
      await tester.pumpAndSettle();
      expect(find.byType(ToggleAlarmButtonInactive), findsOneWidget);

      when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: AlarmSettings.showAlarmOnOffSwitchKey,
              ),
            ),
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: expectedTime,
                identifier: AlarmSettings.alarmsDisabledUntilKey,
              ),
            ),
          ],
        ),
      );

      await tester.tap(find.byType(ToggleAlarmButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifyUnsyncGeneric(
        tester,
        mockGenericDb,
        key: AlarmSettings.alarmsDisabledUntilKey,
        matcher: expectedTime,
      );
      expect(find.byType(ToggleAlarmButtonInactive), findsNothing);
      expect(find.byType(ToggleAlarmButtonActive), findsOneWidget);
    });
  });
}
