import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../fakes/activity_db_in_memory.dart';
import '../../fakes/all.dart';
import '../../mocks/mock_bloc.dart';
import '../../mocks/mocks.dart';
import '../../test_helpers/enter_text.dart';
import '../../test_helpers/register_fallback_values.dart';
import '../../test_helpers/tap_link.dart';
import '../../test_helpers/tts.dart';
import '../../test_helpers/verify_generic.dart';

void main() {
  final nextDayButtonFinder = find.byIcon(AbiliaIcons.goToNextPage);
  final previousDayButtonFinder = find.byIcon(AbiliaIcons.returnToPreviousPage);
  final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
  final editTitleFieldFinder = find.byKey(TestKey.editTitleTextFormField);
  final saveEditActivityButtonFinder = find.byType(NextWizardStepButton);

  final translate = Locales.language.values.first;

  Widget wrapWithMaterialApp(
    Widget widget, {
    MemoplannerSettingBloc? memoplannerSettingBloc,
    SortableBloc? sortableBloc,
    String? languageOverride,
  }) =>
      TopLevelProvider(
        child: AuthenticationBlocProvider(
          child: AuthenticatedBlocsProvider(
            memoplannerSettingBloc: memoplannerSettingBloc,
            sortableBloc: sortableBloc,
            authenticatedState: const Authenticated(userId: 1),
            child: MaterialApp(
              theme: abiliaTheme,
              supportedLocales: Translator.supportedLocals,
              localizationsDelegates: const [Translator.delegate],
              locale:
                  Locale.fromSubtags(languageCode: languageOverride ?? 'und'),
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
  late MockSettingsDb mockSettingsDb;
  TimerResponse timerResponse = () => [];

  SortableResponse sortableResponse = () => [];
  GenericResponse genericResponse = () => [];
  final initialTime = DateTime(2020, 08, 05, 14, 10, 00);

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
    when(() => mockTimerDb.getAllTimers())
        .thenAnswer((_) => Future.value(timerResponse()));
    when(() => mockTimerDb.insert(any())).thenAnswer((_) => Future.value(1));
    when(() => mockTimerDb.getRunningTimersFrom(any()))
        .thenAnswer((_) => Future.value([]));

    mockSettingsDb = MockSettingsDb();
    when(() => mockSettingsDb.leftCategoryExpanded).thenReturn(true);
    when(() => mockSettingsDb.setLeftCategoryExpanded(any()))
        .thenAnswer((_) => Future.value());
    when(() => mockSettingsDb.rightCategoryExpanded).thenReturn(true);
    when(() => mockSettingsDb.setRightCategoryExpanded(any()))
        .thenAnswer((_) => Future.value());
    when(() => mockSettingsDb.language).thenReturn('en');
    when(() => mockSettingsDb.setLanguage(any()))
        .thenAnswer((_) => Future.value());
    when(() => mockSettingsDb.setAlwaysUse24HourFormat(any()))
        .thenAnswer((_) => Future.value());
    when(() => mockSettingsDb.alwaysUse24HourFormat).thenReturn(true);

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker.fake(initialTime: initialTime)
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client(
        sortableResponse: sortableResponse,
        genericResponse: genericResponse,
      )
      ..fileStorage = FakeFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..settingsDb = mockSettingsDb
      ..genericDb = mockGenericDb
      ..sortableDb = mockSortableDb
      ..database = FakeDatabase()
      ..battery = FakeBattery()
      ..timerDb = mockTimerDb
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() {
    sortableResponse = () => [];
    genericResponse = () => [];
    GetIt.I.reset();
  });

  group('calendar page', () {
    testWidgets('navigation', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(tester.widget<DayAppBar>(find.byType(DayAppBar)).day,
          initialTime.onlyDays());
      await tester.tap(nextDayButtonFinder);
      await tester.tap(nextDayButtonFinder);
      await tester.tap(nextDayButtonFinder);
      await tester.pumpAndSettle();

      expect(tester.widget<DayAppBar>(find.byType(DayAppBar)).day,
          initialTime.onlyDays().add(3.days()));
      await tester.tap(find.byType(GoToNowButton));
      await tester.pumpAndSettle();

      expect(tester.widget<DayAppBar>(find.byType(DayAppBar)).day,
          initialTime.onlyDays());
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
      expect(tester.widget<DayAppBar>(find.byType(DayAppBar)).day,
          initialTime.onlyDays());
    });

    testWidgets(
        'SGC-1757 category buttons doesnt change position when changing day interval',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(EyeButtonDay));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.dayNight));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      final leftCategory = find.byType(LeftCategory);
      final leftCategoryOffset = tester.getCenter(leftCategory);

      if (Config.isMP) {
        await tester.tap(find.byType(MenuButton));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byIcon(AbiliaIcons.day));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EyeButtonDay));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.sun));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      expect(tester.getCenter(leftCategory), leftCategoryOffset);
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
      }, skip: Config.isMP);

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
      }, skip: Config.isMP);

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
        identifier: DayCalendarViewOptionsSettings.viewOptionsCalendarTypeKey,
      ),
    );

    testWidgets('SGC-1707 no settings shows timepillar',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(TimepillarCalendar), findsOneWidget);
      expect(find.byType(Agenda), findsNothing);
    });

    testWidgets(
        'timepillar is choosen in memoplanner settings shows timepillar view',
        (WidgetTester tester) async {
      genericResponse = () => [timepillarGeneric];

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(Agenda), findsNothing);
      expect(find.byType(TimepillarCalendar), findsOneWidget);
    });

    testWidgets('when calendar is changed, settings is saved unsynced',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EyeButtonDay));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.calendarList));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.ok));
      await tester.pumpAndSettle();

      verifyUnsyncGeneric(
        tester,
        mockGenericDb,
        key: DayCalendarViewOptionsSettings.viewOptionsCalendarTypeKey,
        matcher: DayCalendarType.list.index,
      );
    });

    group('start calendar', () {
      testWidgets('default', (WidgetTester tester) async {
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(OneTimepillarCalendar), findsOneWidget);
      });

      testWidgets('week', (WidgetTester tester) async {
        genericResponse = () => [
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: StartView.weekCalendar.index,
                  identifier: FunctionsSettings.functionMenuStartViewKey,
                ),
              ),
            ];
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(Agenda), findsNothing);
        expect(find.byType(WeekCalendar), findsOneWidget);
      });

      testWidgets('month', (WidgetTester tester) async {
        genericResponse = () => [
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: StartView.monthCalendar.index,
                  identifier: FunctionsSettings.functionMenuStartViewKey,
                ),
              ),
            ];
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(Agenda), findsNothing);
        expect(find.byType(MonthCalendar), findsOneWidget);
      });

      testWidgets('photo album', (WidgetTester tester) async {
        genericResponse = () => [
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: StartView.photoAlbum.index,
                  identifier: FunctionsSettings.functionMenuStartViewKey,
                ),
              ),
            ];
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(find.byType(Config.isMP ? PhotoCalendarPage : CalendarPage),
            findsOneWidget);
      });
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
        MemoplannerSettings(
          addActivity: AddActivitySettings(
            general: GeneralAddActivitySettings(allowPassedStartTime: false),
          ),
        ),
      ));
      await tester.pumpWidget(wrapWithMaterialApp(
        const CalendarPage(),
      ));

      // Navigate to EditActivityPage
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addActivityButton));
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
        MemoplannerSettings(
          addActivity: AddActivitySettings(
            general: GeneralAddActivitySettings(allowPassedStartTime: false),
          ),
        ),
      ));
      await tester.pumpWidget(wrapWithMaterialApp(
        const CalendarPage(),
        memoplannerSettingBloc: memoplannerSettingBlocMock,
      ));

      // Navigate to EditActivityPage
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addActivityButton));
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
          of: find.text('${initialTime.subtract(1.days()).day}'),
          matching: find.byKey(TestKey.monthCalendarDay)));
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
      void expectCorrectColor(WidgetTester tester, Color color) {
        final at = find.byKey(TestKey.animatedTheme);
        expect(at, findsOneWidget);
        final theme = tester.firstWidget(at) as AnimatedTheme;
        expect(theme.data.appBarTheme.backgroundColor, color);
      }

      const noDayColor = AbiliaColors.black80,
          mondayColor = AbiliaColors.green,
          tuesdayColor = AbiliaColors.blue,
          wednesdayColor = AbiliaColors.white110,
          thursdayColor = AbiliaColors.thursdayBrown,
          fridayColor = AbiliaColors.yellow,
          saturdayColor = AbiliaColors.pink,
          sundayColor = AbiliaColors.sundayRed;

      testWidgets('Color settings with colors on all days',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state).thenReturn(
          const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              calendar: GeneralCalendarSettings(
                dayColor: DayColor.allDays,
              ),
            ),
          ),
        );
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        expectCorrectColor(tester, wednesdayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, thursdayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, fridayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, saturdayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, sundayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, mondayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, tuesdayColor);
      });

      testWidgets('Color settings with colors only on weekends',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state).thenReturn(
          const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              calendar: GeneralCalendarSettings(
                dayColor: DayColor.saturdayAndSunday,
              ),
            ),
          ),
        );
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, saturdayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, sundayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
      });

      testWidgets('Color settings with no colors', (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state).thenReturn(
          const MemoplannerSettingsLoaded(
            MemoplannerSettings(
              calendar: GeneralCalendarSettings(
                dayColor: DayColor.noColors,
              ),
            ),
          ),
        );
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        expectCorrectColor(tester, noDayColor);
      });
    });

    group('dayCaptionShowDayButtons settings', () {
      testWidgets('show next/previous day buttons',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            dayCalendar: DayCalendarSettings(
              appBar: AppBarSettings(showBrowseButtons: true),
            ),
          ),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();

        expect(nextDayButtonFinder, findsOneWidget);
        expect(previousDayButtonFinder, findsOneWidget);

        expect(nextDayButtonFinder, findsOneWidget);
        expect(previousDayButtonFinder, findsOneWidget);
      });

      testWidgets('do not show next/previous day buttons',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            dayCalendar: DayCalendarSettings(
              appBar: AppBarSettings(showBrowseButtons: false),
            ),
          ),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          const CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();

        expect(nextDayButtonFinder, findsNothing);
        expect(previousDayButtonFinder, findsNothing);

        expect(nextDayButtonFinder, findsNothing);
        expect(previousDayButtonFinder, findsNothing);
      });
    });

    group('calendarActivityTypeShowTypes setting', () {
      testWidgets('Timepillar is left when no categories',
          (WidgetTester tester) async {
        when(() => memoplannerSettingBlocMock.state)
            .thenReturn(const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            calendar: GeneralCalendarSettings(
              categories: CategoriesSettings(show: false),
            ),
            dayCalendar: DayCalendarSettings(
              viewOptions: DayCalendarViewOptionsSettings(
                calendarTypeIndex: 1,
              ),
            ),
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
            .thenReturn(const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            calendar: GeneralCalendarSettings(
              categories: CategoriesSettings(show: true),
            ),
            dayCalendar: DayCalendarSettings(
              viewOptions: DayCalendarViewOptionsSettings(
                calendarTypeIndex: 1,
              ),
            ),
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
    final date = initialTime.onlyDays();

    final day1Finder = find.text(title1);
    final day2Finder = find.text(title2);
    final day3Finder = find.text(title3);
    final cardFinder = find.byType(ActivityCard);
    final showAllFullDayButtonFinder = find.byType(FullDayActivitiesButton);
    final editPictureFinder = find.byKey(TestKey.addPicture);

    setUp(() {
      final fullDayActivities = [
        FakeActivity.fullday(date, title1),
        FakeActivity.fullday(date, title2),
        FakeActivity.fullday(date, title3),
      ];
      mockActivityDb.initWithActivities(fullDayActivities);
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
    final friday = initialTime.addDays(2);
    final nextWeek = initialTime.nextWeek();
    setUp(() {
      final activities = [
        FakeActivity.starts(initialTime, title: todaytitle),
        FakeActivity.starts(friday, title: fridayTitle),
        FakeActivity.starts(nextWeek, title: nextWeekTitle),
      ];
      mockActivityDb.initWithActivities(activities);
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

    testWidgets('SGC-1869 - Week calendar shows correct year',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.text(initialTime.year.toString()), findsOneWidget);

      for (int i = 0; i < 52; i++) {
        await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      }
      await tester.pumpAndSettle();
      expect(find.text((initialTime.year + 1).toString()), findsOneWidget);

      await tester.tap(find.byType(GoToCurrentActionButton));
      await tester.pumpAndSettle();
      expect(find.text(initialTime.year.toString()), findsOneWidget);

      for (int i = 0; i < 52; i++) {
        await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      }
      await tester.pumpAndSettle();
      expect(find.text((initialTime.year - 1).toString()), findsOneWidget);
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

      expect(selected.day, initialTime.onlyDays());
    });

    testWidgets(
        'BUG SGC-756 tapping day goes back to that day calendar, then go back to now goes back to now',
        (WidgetTester tester) async {
      final dayString =
          '${friday.day}\n${translate.shortWeekday(friday.weekday)}';
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      expect(find.byType(OneTimepillarCalendar), findsOneWidget);

      expect(find.text(todaytitle), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
      await tester.tap(find.text(dayString));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
      await tester.tap(find.text(dayString));
      await tester.pumpAndSettle();

      expect(find.byType(OneTimepillarCalendar), findsOneWidget);
      expect(find.text(fridayTitle), findsOneWidget);

      await tester.tap(find.byType(GoToNowButton));
      await tester.pumpAndSettle();
      expect(find.text(fridayTitle), findsNothing);
      expect(find.text(todaytitle), findsOneWidget);
    });

    testWidgets('Timer shown in week calendar', (WidgetTester tester) async {
      timerResponse = () => [
            AbiliaTimer(
                id: 'id', startTime: initialTime, duration: 20.minutes()),
          ];
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
      expect(find.byType(TimerCardWheel), findsOneWidget);
    });

    testWidgets('Clicking activity in week calendar navigates to activity view',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(OneTimepillarCalendar), findsOneWidget);

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

      final dateTime = initialTime.addDays(8);
      final d = dateTime.day;
      await tester
          .tap(find.text('$d\n${translate.shortWeekday(dateTime.weekday)}'));
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
        FakeActivity.starts(initialTime, title: 'one')
            .copyWith(startTime: initialTime.add(const Duration(hours: 1))),
        FakeActivity.starts(initialTime, title: 'two')
            .copyWith(startTime: initialTime.add(const Duration(hours: 2))),
        FakeActivity.starts(initialTime, title: 'three')
            .copyWith(startTime: initialTime.add(const Duration(hours: 3))),
        FakeActivity.starts(initialTime, title: 'four')
            .copyWith(startTime: initialTime.add(const Duration(hours: 4))),
        FakeActivity.starts(initialTime, title: 'five')
            .copyWith(startTime: initialTime.add(const Duration(hours: 5))),
        FakeActivity.starts(initialTime, title: 'six')
            .copyWith(startTime: initialTime.add(const Duration(hours: 6))),
        FakeActivity.starts(initialTime, title: 'seven')
            .copyWith(startTime: initialTime.add(const Duration(hours: 7))),
        FakeActivity.starts(initialTime, title: 'eight')
            .copyWith(startTime: initialTime.add(const Duration(hours: 8))),
        FakeActivity.starts(initialTime, title: 'nine')
            .copyWith(startTime: initialTime.add(const Duration(hours: 9))),
        FakeActivity.starts(initialTime, title: 'ten')
            .copyWith(startTime: initialTime.add(const Duration(hours: 10))),
        FakeActivity.starts(initialTime, title: 'eleven')
            .copyWith(startTime: initialTime.add(const Duration(hours: 11))),
        FakeActivity.starts(initialTime, title: 'twelve')
            .copyWith(startTime: initialTime.add(const Duration(hours: 12))),
      ];
      mockActivityDb.initWithActivities(activities);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.text('one'), findsOneWidget);
      expect(find.text('twelve'), findsOneWidget);
    });

    testWidgets('Divider between header and body on some past days',
        (WidgetTester tester) async {
      final mondayPreviousWeek = initialTime.addDays(-9);
      final dayString =
          '${mondayPreviousWeek.day}\n${translate.shortWeekday(mondayPreviousWeek.weekday)}';

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      // Nothing on current week
      expect(find.byKey(TestKey.whiteColumnDivider), findsNothing);

      // Past week, selected
      await tester.tap(find.byType(LeftNavButton));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.whiteColumnDivider), findsOneWidget);

      // Still there when clicking another day
      await tester.tap(find.text(dayString));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.whiteColumnDivider), findsOneWidget);
    });

    group('danish', () {
      setUp(() {
        when(() => mockSettingsDb.language).thenReturn('da');
      });
      testWidgets('Divider between header and body on Danish Sunday',
          (WidgetTester tester) async {
        final sundayPreviousWeek = initialTime.addDays(-3);
        final dayString =
            '${sundayPreviousWeek.day}\n${translate.shortWeekday(sundayPreviousWeek.weekday)}';

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.week));
        await tester.pumpAndSettle();

        // Nothing on current week
        expect(find.byKey(TestKey.whiteColumnDivider), findsNothing);

        // Past week, not selected
        await tester.tap(find.byType(LeftNavButton));
        await tester.pumpAndSettle();
        expect(find.byKey(TestKey.whiteColumnDivider), findsOneWidget);

        // Selected past sunday
        await tester.tap(find.text(dayString));
        await tester.pumpAndSettle();
        expect(find.byKey(TestKey.whiteColumnDivider), findsOneWidget);
      });
    });
  });

  testWidgets(
      'SGC-1748 FullDayListPage page is shown when clicking on a day with multiple full day activities in week calendar',
      (WidgetTester tester) async {
    final activities = [
      FakeActivity.fullday(initialTime.addDays(1), 'one'),
      FakeActivity.fullday(initialTime.addDays(1), 'two'),
    ];
    mockActivityDb.initWithActivities(activities);
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.week));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FullDayStack));
    await tester.pumpAndSettle();
    expect(find.byType(FullDayListPage), findsOneWidget);
    expect(find.text(activities[0].title), findsOneWidget);
    expect(find.text(activities[1].title), findsOneWidget);
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
      await tester.verifyTts(find.byType(ToggleAlarmButton),
          exact: translate.disableAlarms);
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

    testWidgets('eye button tts', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage()));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.byType(EyeButtonDay),
          exact: translate.display);
    });

    testWidgets('SGC-1129 alarm button toggleable',
        (WidgetTester tester) async {
      final expectedTime =
          initialTime.onlyDays().nextDay().millisecondsSinceEpoch;
      genericResponse = () => [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: AlarmSettings.showAlarmOnOffSwitchKey,
              ),
            )
          ];

      await tester.pumpWidget(wrapWithMaterialApp(const CalendarPage()));
      await tester.pumpAndSettle();
      expect(find.byType(ToggleAlarmButtonInactive), findsOneWidget);

      genericResponse = () => [
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
          ];

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
