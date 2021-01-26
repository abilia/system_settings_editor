import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:seagull/background/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';
import '../../utils/types.dart';

void main() {
  final nextDayButtonFinder = find.byIcon(AbiliaIcons.go_to_next_page),
      previousDayButtonFinder =
          find.byIcon(AbiliaIcons.return_to_previous_page);

  final translate = Locales.language.values.first;

  Future goToTimePillar(WidgetTester tester) async {
    await tester.tap(find.byType(EyeButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.timeline));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.ok));
    await tester.pumpAndSettle();
  }

  final licenseDb = MockLicenseDb();
  final userRepository = UserRepository(
    client: Fakes.client(),
    tokenDb: MockTokenDb(),
    userDb: MockUserDb(),
    licenseDb: licenseDb,
  );

  final defaultMemoSettingsBloc = MockMemoplannerSettingsBloc();
  when(defaultMemoSettingsBloc.state)
      .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings()));

  Widget wrapWithMaterialApp(
    Widget widget, {
    MemoplannerSettingBloc memoplannerSettingBloc,
    SortableBloc sortableBloc,
  }) =>
      TopLevelBlocsProvider(
        baseUrl: 'test',
        child: AuthenticatedBlocsProvider(
          memoplannerSettingBloc:
              memoplannerSettingBloc ?? defaultMemoSettingsBloc,
          sortableBloc: sortableBloc,
          authenticatedState: Authenticated(
            token: '',
            userId: 1,
            userRepository: userRepository,
          ),
          child: MaterialApp(
            key: authedStateKey,
            supportedLocales: Translator.supportedLocals,
            localizationsDelegates: [Translator.delegate],
            localeResolutionCallback: (locale, supportedLocales) =>
                supportedLocales.firstWhere(
                    (l) => l.languageCode == locale?.languageCode,
                    orElse: () => supportedLocales.first),
            home: Material(child: widget),
          ),
        ),
      );

  MockActivityDb mockActivityDb;
  SettingsDb mockSettingsDb;
  StreamController<DateTime> mockTicker;
  ActivityResponse activityResponse = () => [];
  final initialDay = DateTime(2020, 08, 05);

  setUp(() async {
    setupPermissions();
    tz.initializeTimeZones();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    mockTicker = StreamController<DateTime>();
    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));
    mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activityResponse()));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    mockSettingsDb = MockSettingsDb();

    when(licenseDb.getLicenses()).thenReturn([
      License(
          id: 1,
          product: MEMOPLANNER_LICENSE_NAME,
          endTime: initialDay.add(100.days()))
    ]);

    final db = MockDatabase();
    when(db.rawQuery(any)).thenAnswer((realInvocation) => Future.value([]));
    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker(stream: mockTicker.stream, initialTime: initialDay)
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client(activityResponse: activityResponse)
      ..fileStorage = MockFileStorage()
      ..userFileDb = MockUserFileDb()
      ..settingsDb = mockSettingsDb
      ..syncDelay = SyncDelays.zero
      ..alarmScheduler = noAlarmScheduler
      ..database = db
      ..flutterTts = MockFlutterTts()
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('calendar page', () {
    group('create new activity', () {
      testWidgets('New activity', (WidgetTester tester) async {
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addActivity));
        await tester.pumpAndSettle();
        expect(find.byType(CreateActivityPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditActivityPage), findsOneWidget);
      });

      testWidgets('Empty message when no basic activities',
          (WidgetTester tester) async {
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addActivity));
        await tester.pumpAndSettle();
        expect(find.byType(CreateActivityPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.basicActivityChoice));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();
        expect(find.text(translate.noBasicActivities), findsOneWidget);
      });

      testWidgets('New activity from basic activity gets correct title',
          (WidgetTester tester) async {
        await initializeDateFormatting();
        final sortableBlocMock = MockSortableBloc();
        final title = 'testtitle';
        when(sortableBlocMock.state).thenReturn(SortablesLoaded(sortables: [
          Sortable.createNew<BasicActivityDataItem>(
            data: BasicActivityDataItem.createNew(title: title),
          ),
        ]));
        await tester.pumpWidget(wrapWithMaterialApp(CalendarPage(),
            sortableBloc: sortableBlocMock));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addActivity));
        await tester.pumpAndSettle();
        expect(find.byType(CreateActivityPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.basicActivityChoice));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();
        expect(find.byType(typeOf<SortableLibrary<BasicActivityData>>()),
            findsOneWidget);
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

      testWidgets('basic activity library navigation',
          (WidgetTester tester) async {
        await initializeDateFormatting();
        final sortableBlocMock = MockSortableBloc();
        final title = 'testtitle', folderTitle = 'folderTitle';

        final folder = Sortable.createNew<BasicActivityDataFolder>(
          isGroup: true,
          data: BasicActivityDataFolder.createNew(name: folderTitle),
        );
        when(sortableBlocMock.state).thenReturn(SortablesLoaded(sortables: [
          Sortable.createNew<BasicActivityDataItem>(
              data: BasicActivityDataItem.createNew(title: title),
              groupId: folder.id),
          folder,
        ]));

        //Act
        await tester.pumpWidget(wrapWithMaterialApp(CalendarPage(),
            sortableBloc: sortableBlocMock));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addActivity));
        await tester.pumpAndSettle();

        // Act Go to basic activity archive
        await tester.tap(find.byKey(TestKey.basicActivityChoice));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
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
        await tester.tap(find.byType(GreyButton));
        await tester.pumpAndSettle();

        // Assert - Next button disabled, no folder
        expect(
          tester.widget<NextButton>(find.byType(NextButton)).onPressed,
          isNull,
        );
        expect(find.byType(LibraryFolder), findsOneWidget);

        // Act - Go back
        await tester.tap(find.byType(GreyButton));
        await tester.pumpAndSettle();

        // Assert back at create acitivy page
        expect(find.byType(CreateActivityPage), findsOneWidget);
        expect(
          find.byType(typeOf<SortableLibrary<BasicActivityData>>()),
          findsNothing,
        );

        // Act - Go back
        await tester.tap(find.byType(GreyButton));
        await tester.pumpAndSettle();

        // Assert - Back at calendar page
        expect(find.byType(CreateActivityPage), findsNothing);
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      testWidgets('basic activity library navigation SAVE from edit page',
          (WidgetTester tester) async {
        await initializeDateFormatting();
        final sortableBlocMock = MockSortableBloc();
        final title = 'testtitle';
        when(sortableBlocMock.state).thenReturn(SortablesLoaded(sortables: [
          Sortable.createNew<BasicActivityDataItem>(
            data: BasicActivityDataItem.createNew(title: title),
          ),
        ]));

        //Act
        await tester.pumpWidget(wrapWithMaterialApp(CalendarPage(),
            sortableBloc: sortableBlocMock));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addActivity));
        await tester.pumpAndSettle();

        // Act Go to basic activity archive
        await tester.tap(find.byKey(TestKey.basicActivityChoice));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(BasicActivityPickerPage), findsOneWidget);
        // Act - choose basic activity
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(EditActivityPage), findsOneWidget);

        // Act - save
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();

        // Assert - Back at picker page
        expect(find.byType(CreateActivityPage), findsNothing);
        expect(find.byType(BasicActivityPickerPage), findsNothing);
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      testWidgets('basic activity library navigation back from edit page',
          (WidgetTester tester) async {
        await initializeDateFormatting();
        final sortableBlocMock = MockSortableBloc();
        final title = 'testtitle';
        when(sortableBlocMock.state).thenReturn(SortablesLoaded(sortables: [
          Sortable.createNew<BasicActivityDataItem>(
            data: BasicActivityDataItem.createNew(title: title),
          ),
        ]));

        //Act
        await tester.pumpWidget(wrapWithMaterialApp(CalendarPage(),
            sortableBloc: sortableBlocMock));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addActivity));
        await tester.pumpAndSettle();

        // Act Go to basic activity archive
        await tester.tap(find.byKey(TestKey.basicActivityChoice));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(BasicActivityPickerPage), findsOneWidget);
        // Act - Select item
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(NextButton));
        await tester.pumpAndSettle();

        expect(find.byType(EditActivityPage), findsOneWidget);

        // Act - Go back
        await tester.tap(find.byType(GreyButton));
        await tester.pumpAndSettle();

        // Assert - Back at picker page
        expect(find.byType(CreateActivityPage), findsOneWidget);
        expect(find.byType(BasicActivityPickerPage), findsNothing);
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
        await tester.tap(find.byKey(TestKey.closeDialog));
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
        await tester.tap(find.byKey(TestKey.closeDialog));
        await tester.pumpAndSettle();
        await tester.verifyTts(find.byType(ErrorMessage),
            exact: translate.notificationsWarningText);
      });

      testWidgets('Denied notifications link to permission settings',
          (WidgetTester tester) async {
        bool tapTextSpan(RichText richText, String text) {
          return !richText.text.visitChildren(
            (InlineSpan visitor) {
              if (visitor is TextSpan && visitor.text == text) {
                (visitor.recognizer as TapGestureRecognizer).onTap();
                return false;
              }
              return true;
            },
          );
        }

        setupPermissions({Permission.notification: PermissionStatus.denied});
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is RichText &&
                  tapTextSpan(widget, translate.settingsLink),
            ),
            findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(PermissionsPage), findsOneWidget);
      });
    });
  });

  group('Choosen calendar setting', () {
    testWidgets('no settings shows agenda', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(TimePillarCalendar), findsNothing);
      expect(find.byType(Agenda), findsOneWidget);
    });

    testWidgets(
        'timepillar is choosen in settings settings shows timepillar view',
        (WidgetTester tester) async {
      when(mockSettingsDb.preferedCalender).thenReturn(CalendarType.TIMEPILLAR);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(Agenda), findsNothing);
      expect(find.byType(TimePillarCalendar), findsOneWidget);
    });

    testWidgets('when calendar is changed, settings i saved',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await goToTimePillar(tester);
      verify(mockSettingsDb.setPreferredCalendar(CalendarType.TIMEPILLAR));
    });
  });

  group('MemoPlanner settings', () {
    MemoplannerSettingBloc memoplannerSettingBlocMock;

    setUp(() {
      initializeDateFormatting();
      memoplannerSettingBlocMock = MockMemoplannerSettingsBloc();
    });

    testWidgets(
        'SGC-533 Can save full day on current day when activityTimeBeforeCurrent is false',
        (WidgetTester tester) async {
      final testActivityTitle = 'fulldayactivity';
      when(memoplannerSettingBlocMock.state)
          .thenReturn(MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ));
      await tester.pumpWidget(wrapWithMaterialApp(
        CalendarPage(),
        memoplannerSettingBloc: memoplannerSettingBlocMock,
      ));

      // Navigate to EditActivityPage
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addActivity));
      await tester.pumpAndSettle();
      expect(find.byType(CreateActivityPage), findsOneWidget);
      await tester.tap(find.byKey(TestKey.newActivityChoice));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
      expect(find.byType(CalendarPage), findsNothing);

      await tester.enterText_(
          find.byKey(TestKey.editTitleTextFormField), testActivityTitle);
      await tester.pumpAndSettle();
      await tester.dragFrom(
          tester.getCenter(find.byType(EditActivityPage)), Offset(0.0, -200));
      await tester.pump();
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.finishEditActivityButton));
      await tester.pumpAndSettle();
      expect(find.text(translate.startTimeBeforeNow), findsNothing);
      expect(find.byType(EditActivityPage), findsNothing);
      expect(find.byType(CalendarPage), findsOneWidget);
      expect(find.text(testActivityTitle), findsOneWidget);
    });

    testWidgets(
        'SGC-533 Cannot save full day activity on yesterday when activityTimeBeforeCurrent is false',
        (WidgetTester tester) async {
      final testActivityTitle = 'fulldayactivity';
      when(memoplannerSettingBlocMock.state)
          .thenReturn(MemoplannerSettingsLoaded(
        MemoplannerSettings(activityTimeBeforeCurrent: false),
      ));
      await tester.pumpWidget(wrapWithMaterialApp(
        CalendarPage(),
        memoplannerSettingBloc: memoplannerSettingBlocMock,
      ));

      // Navigate to EditActivityPage
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addActivity));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.newActivityChoice));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
      expect(find.byType(CalendarPage), findsNothing);

      // Enter activity information
      await tester.enterText_(
          find.byKey(TestKey.editTitleTextFormField), testActivityTitle);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.datePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('${initialDay.subtract(1.days()).day}'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.dragFrom(
          tester.getCenter(find.byType(EditActivityPage)), Offset(0.0, -200));
      await tester.pump();
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.finishEditActivityButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text(translate.startTimeBeforeNow), findsOneWidget);
      expect(find.byType(EditActivityPage), findsOneWidget);
      expect(find.byType(CalendarPage), findsNothing);
    });

    group('Color settings', () {
      void _expectCorrectColor(WidgetTester tester, Color color) {
        final at = find.byKey(TestKey.animatedTheme);
        expect(at, findsOneWidget);
        final theme = tester.firstWidget(at) as AnimatedTheme;
        expect(theme.data.appBarTheme.color, color);
      }

      final noDayColor = AbiliaColors.black80,
          mondayColor = AbiliaColors.green,
          tuesdayColor = AbiliaColors.blue,
          wednesdayColor = AbiliaColors.white,
          thursdayColor = AbiliaColors.thursdayBrown,
          fridayColor = AbiliaColors.yellow,
          saturdayColor = AbiliaColors.pink,
          sundayColor = AbiliaColors.sundayRed;

      testWidgets('Color settings with colors on all days',
          (WidgetTester tester) async {
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarDayColor: DayColor.allDays.index),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
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
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(
              calendarDayColor: DayColor.saturdayAndSunday.index),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
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
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarDayColor: DayColor.noColors.index),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
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
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(dayCaptionShowDayButtons: true),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
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
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(dayCaptionShowDayButtons: false),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
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
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarActivityTypeShowTypes: false),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        await goToTimePillar(tester);

        final w = find.byType(TimePillar);
        final topLeft = tester.getTopLeft(w);
        expect(topLeft.dx, 0);
      });

      testWidgets(
          'Center of timepillar is center of page when categories are on',
          (WidgetTester tester) async {
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarActivityTypeShowTypes: true),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        await goToTimePillar(tester);

        final timepillarCenter = tester.getCenter(find.byType(TimePillar));
        final calendarCenter = tester.getCenter(find.byType(CalendarPage));
        expect(timepillarCenter.dx, calendarCenter.dx);
      });
    });
  });

  group('edit all day', () {
    final title1 = 'fulldaytitle1';
    final title2 = 'fullday title 2';
    final title3 = 'full day title 3';
    final date = initialDay.onlyDays();

    final day1Finder = find.text(title1);
    final day2Finder = find.text(title2);
    final day3Finder = find.text(title3);
    final cardFinder = find.byType(ActivityCard);
    final showAllFullDayButtonFinder =
        find.byType(ShowAllFullDayActivitiesButton);
    final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
    final editTitleFieldFinder = find.byKey(TestKey.editTitleTextFormField);
    final saveEditActivityButtonFinder =
        find.byKey(TestKey.finishEditActivityButton);
    final editPictureFinder = find.byKey(TestKey.addPicture);

    setUp(() {
      final fullDayActivities = [
        FakeActivity.fullday(date, title1),
        FakeActivity.fullday(date, title2),
        FakeActivity.fullday(date, title3),
      ];
      activityResponse = () => fullDayActivities;
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(fullDayActivities));
      when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
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
      final newTitle = 'A brand new title!';
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(day3Finder);
      await tester.pumpAndSettle();
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.enterText_(editTitleFieldFinder, newTitle);
      await tester.tap(saveEditActivityButtonFinder);
      await tester.pumpAndSettle();

      expect(find.text(newTitle), findsOneWidget);
    });

    testWidgets('Can edit from full day list shows on full day list',
        (WidgetTester tester) async {
      final newTitle = 'A brand new title!';
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(showAllFullDayButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(day3Finder);
      await tester.pumpAndSettle();
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.enterText_(editTitleFieldFinder, newTitle);
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
      await tester.tap(find.byIcon(AbiliaIcons.folder));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchive), findsOneWidget);
    });
  });
}
