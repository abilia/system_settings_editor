import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
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

import '../../mocks.dart';
import '../../utils/types.dart';

void main() {
  final nextDayButtonFinder = find.byIcon(AbiliaIcons.go_to_next_page),
      previousDayButtonFinder =
          find.byIcon(AbiliaIcons.return_to_previous_page);

  Future goToTimePillar(WidgetTester tester) async {
    await tester.tap(find.byKey(TestKey.changeView));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.timePillarButton));
    await tester.pumpAndSettle();
  }

  final userRepository = UserRepository(
    httpClient: Fakes.client(),
    tokenDb: MockTokenDb(),
    userDb: MockUserDb(),
    licenseDb: MockLicenseDb(),
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

  group('calendar page', () {
    MockActivityDb mockActivityDb;
    StreamController<DateTime> mockTicker;
    ActivityResponse activityResponse = () => [];
    final initialDay = DateTime(2020, 08, 05);

    setUp(() async {
      tz.initializeTimeZones();
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      mockTicker = StreamController<DateTime>();
      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      mockActivityDb = MockActivityDb();
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(<Activity>[]));
      when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = Ticker(stream: mockTicker.stream, initialTime: initialDay)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(activityResponse: activityResponse)
        ..fileStorage = MockFileStorage()
        ..userFileDb = MockUserFileDb()
        ..settingsDb = MockSettingsDb()
        ..syncDelay = SyncDelays.zero
        ..alarmScheduler = noAlarmScheduler
        ..database = MockDatabase()
        ..flutterTts = MockFlutterTts()
        ..init();
    });

    testWidgets('New activity', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addActivity));
      await tester.pumpAndSettle();
      expect(find.byType(CreateActivityDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.newActivityButton));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
    });

    testWidgets('New activity from basic activity gets correct title',
        (WidgetTester tester) async {
      await initializeDateFormatting();
      final sortableBlocMock = MockSortableBloc();
      final title = 'testtitle';
      when(sortableBlocMock.state).thenReturn(SortablesLoaded(sortables: [
        Sortable.createNew<BasicActivityData>(
          data: BasicActivityDataItem.createNew(title: title),
        ),
      ]));
      await tester.pumpWidget(
          wrapWithMaterialApp(CalendarPage(), sortableBloc: sortableBlocMock));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addActivity));
      await tester.pumpAndSettle();
      expect(find.byType(CreateActivityDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.selectBasicActivityButton));
      await tester.pumpAndSettle();
      expect(find.byType(typeOf<SortableLibrary<BasicActivityData>>()),
          findsOneWidget);
      expect(find.text(title), findsOneWidget);
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
      final nameAndPicture = find.byType(NameAndPictureWidget);
      expect(nameAndPicture, findsOneWidget);
      final nameAndPictureWidget =
          tester.firstWidget(nameAndPicture) as NameAndPictureWidget;
      expect(nameAndPictureWidget.text, title);
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
        final compound = translate.allowNotificationsDescription1 +
            translate.allowNotificationsDescriptionSettingsLink +
            translate.allowNotificationsDescription2;
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
                  tapTextSpan(widget,
                      translate.allowNotificationsDescriptionSettingsLink),
            ),
            findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byType(PermissionsPage), findsOneWidget);
      });
    });
  });

  group('MemoPlanner settings', () {
    MemoplannerSettingBloc memoplannerSettingBlocMock;

    MockActivityDb mockActivityDb;

    StreamController<DateTime> mockTicker;
    ActivityResponse activityResponse = () => [];
    final initialDay = DateTime(2020, 08, 05);

    setUp(() {
      initializeDateFormatting();
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      mockTicker = StreamController<DateTime>();
      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      mockActivityDb = MockActivityDb();
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(<Activity>[]));
      when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      memoplannerSettingBlocMock = MockMemoplannerSettingsBloc();
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = Ticker(stream: mockTicker.stream, initialTime: initialDay)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(activityResponse: activityResponse)
        ..fileStorage = MockFileStorage()
        ..userFileDb = MockUserFileDb()
        ..settingsDb = MockSettingsDb()
        ..genericDb = MockGenericDb()
        ..syncDelay = SyncDelays.zero
        ..alarmScheduler = noAlarmScheduler
        ..database = MockDatabase()
        ..init();
    });

    group('Color settings', () {
      void _expectCorrectColor(WidgetTester tester, Color color) {
        final at = find.byKey(TestKey.animatedTheme);
        expect(at, findsOneWidget);
        final theme = tester.firstWidget(at) as AnimatedTheme;
        expect(theme.data.appBarTheme.color, color);
      }

      testWidgets('Color settings with colors on all days',
          (WidgetTester tester) async {
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarDayColor: DayColors.ALL_DAYS),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.wednesday]);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.thursday]);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.friday]);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.saturday]);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.sunday]);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.monday]);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.tuesday]);
      });

      testWidgets('Color settings with colors only on weekends',
          (WidgetTester tester) async {
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarDayColor: DayColors.SATURDAY_AND_SUNDAY),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.saturday]);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, weekDayColor[DateTime.sunday]);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
      });

      testWidgets('Color settings with no colors', (WidgetTester tester) async {
        when(memoplannerSettingBlocMock.state)
            .thenReturn(MemoplannerSettingsLoaded(
          MemoplannerSettings(calendarDayColor: DayColors.NO_COLORS),
        ));
        await tester.pumpWidget(wrapWithMaterialApp(
          CalendarPage(),
          memoplannerSettingBloc: memoplannerSettingBlocMock,
        ));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
        await tester.tap(nextDayButtonFinder);
        await tester.pumpAndSettle();
        _expectCorrectColor(tester, neutralThemeData.appBarTheme.color);
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
  });

  group('edit all day', () {
    final title1 = 'fulldaytitle1';
    final title2 = 'fullday title 2';
    final title3 = 'full day title 3';
    final date = DateTime(1994, 04, 04, 04, 04);

    final day1Finder = find.text(title1);
    final day2Finder = find.text(title2);
    final day3Finder = find.text(title3);
    final cardFinder = find.byType(ActivityCard);
    final infoFinder = find.byType(ActivityInfo);
    final showAllFullDayButtonFinder =
        find.byType(ShowAllFullDayActivitiesButton);
    final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
    final editActivityPageFinder = find.byType(EditActivityPage);
    final editTitleFieldFinder = find.byKey(TestKey.editTitleTextFormField);
    final saveEditActivityButtonFinder =
        find.byKey(TestKey.finishEditActivityButton);
    final activityBackButtonFinder = find.byKey(TestKey.activityBackButton);

    final editPictureFinder = find.byKey(TestKey.addPicture);
    final selectPictureDialogFinder = find.byType(SelectPictureDialog);
    final selectImageArchiveFinder = find.byIcon(AbiliaIcons.folder);
    final imageArchiveFinder = find.byType(ImageArchive);

    setUp(() {
      final fullDayActivities = [
        FakeActivity.fullday(date, title1),
        FakeActivity.fullday(date, title2),
        FakeActivity.fullday(date, title3),
      ];
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));
      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(fullDayActivities));
      when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = Ticker(
          initialTime: date,
          stream: StreamController<DateTime>().stream,
        )
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(activityResponse: () => fullDayActivities)
        ..fileStorage = MockFileStorage()
        ..userFileDb = MockUserFileDb()
        ..settingsDb = MockSettingsDb()
        ..syncDelay = SyncDelays.zero
        ..alarmScheduler = noAlarmScheduler
        ..database = MockDatabase()
        ..init();
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
      expect(infoFinder, findsOneWidget);
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
      expect(editActivityPageFinder, findsOneWidget);
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
      await tester.tap(activityBackButtonFinder);
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
      expect(selectPictureDialogFinder, findsOneWidget);
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
      await tester.tap(selectImageArchiveFinder);
      await tester.pumpAndSettle();
      expect(imageArchiveFinder, findsOneWidget);
    });
  });
}
