import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';

import 'package:memoplanner/utils/all.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../fakes/all.dart';

import '../mocks/mock_bloc.dart';
import '../mocks/mocks.dart';
import '../test_helpers/app_pumper.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    setupPermissions();
    registerFallbackValues();
  });

  group('Home screen inactivity', () {
    final DateTime initialTime = DateTime(2122, 06, 06, 06, 00);
    final Ticker fakeTicker = Ticker.fake(initialTime: initialTime);
    late MockMemoplannerSettingBloc mockSettingBloc;
    late InactivityCubit inactivityCubit;

    setUp(() async {
      mockSettingBloc = MockMemoplannerSettingBloc();
      when(() => mockSettingBloc.state).thenReturn(
        MemoplannerSettingsLoaded(const MemoplannerSettings()),
      );
      when(() => mockSettingBloc.stream)
          .thenAnswer((invocation) => const Stream.empty());
      inactivityCubit = InactivityCubit(
        fakeTicker,
        mockSettingBloc,
        DayPartCubit(mockSettingBloc, ClockBloc.withTicker(fakeTicker)),
        TouchDetectionCubit().stream,
        const Stream.empty(),
        const Stream.empty(),
      );
      final mockFirebasePushService = MockFirebasePushService();
      when(() => mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = fakeTicker
        ..client = Fakes.client(
          activityResponse: () => [],
        )
        ..battery = FakeBattery()
        ..database = FakeDatabase()
        ..deviceDb = FakeDeviceDb()
        ..init();
    });

    tearDown(() {
      GetIt.I.reset();
    });

    Widget wrapWithMaterialApp({Widget? child}) => TopLevelProvider(
          child: AuthenticationBlocProvider(
            child: AuthenticatedBlocsProvider(
              memoplannerSettingBloc: mockSettingBloc,
              authenticatedState: const Authenticated(user: Fakes.user),
              child: BlocProvider<InactivityCubit>(
                create: (context) => inactivityCubit,
                child: MaterialApp(
                  theme: abiliaTheme,
                  home: MultiBlocListener(
                    listeners: [
                      CalendarInactivityListener(),
                      ScreensaverListener(),
                    ],
                    child: ReturnToHomeScreenListener(
                      child: child ?? const CalendarPage(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

    testWidgets('switches to WeekCalendar', (tester) async {
      when(() => mockSettingBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            functions: FunctionsSettings(
              startView: StartView.weekCalendar,
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(child: const CalendarPage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsNothing);
      inactivityCubit.emit(HomeScreenThresholdReached(initialTime));
      await tester.pumpAndSettle();
      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('switches to Menu', (tester) async {
      when(() => mockSettingBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            functions: FunctionsSettings(
              startView: StartView.menu,
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(child: const CalendarPage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsNothing);
      inactivityCubit.emit(HomeScreenThresholdReached(initialTime));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
    });

    testWidgets('switches to WeekCalendar', (tester) async {
      when(() => mockSettingBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            functions: FunctionsSettings(
              startView: StartView.photoAlbum,
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(child: const CalendarPage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PhotoCalendarPage), findsOneWidget);
      await tester.tap(
        find.widgetWithIcon(IconActionButton, AbiliaIcons.day),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PhotoCalendarPage), findsNothing);
      inactivityCubit.emit(HomeScreenThresholdReached(initialTime));
      await tester.pumpAndSettle();
      expect(find.byType(PhotoCalendarPage), findsOneWidget);
    });

    testWidgets(
        'When timeout is reached, screensaver is true, app switches to Screensaver',
        (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(child: const CalendarPage()));
      inactivityCubit.emit(const ScreensaverState());
      await tester.pumpAndSettle();
      expect(find.byType(ScreensaverPage), findsOneWidget);
      expect(find.byType(ScreensaverPage), findsOneWidget);
    });

    testWidgets(
        'When timeout is reached, screensaver is false, '
        'app switches to DayCalendar from Menu', (tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(child: const CalendarPage()));
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SettingsButton));
      await tester.pumpAndSettle();
      inactivityCubit.emit(
        const HomeScreenFinalState(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DayCalendar), findsOneWidget);
    });

    group('Calendar inactivity', () {
      final local = Intl.getCurrentLocale();
      testWidgets(
          'When timeout is reached, day calendar switches to current day',
          (tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(child: const DayCalendar()));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
        await tester.pumpAndSettle();
        expect(find.text(DateFormat.EEEE(local).format(initialTime)),
            findsNothing);
        inactivityCubit.emit(
          ReturnToTodayThresholdReached(initialTime),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DayCalendar), findsOneWidget);
        expect(find.text(DateFormat.EEEE(local).format(initialTime)),
            findsOneWidget);
      });

      testWidgets('When timeout is reached, if not in calendar, do nothing',
          (tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(child: const SettingsPage()));
        await tester.pumpAndSettle();
        inactivityCubit.emit(
          ReturnToTodayThresholdReached(initialTime),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DayCalendar), findsNothing);
      });
    });
  }, skip: !Config.isMP);

  group('home button', () {
    GenericResponse genericResponse = () => [];
    TimerResponse timerResponse = () => [];

    Generic startViewGeneric(StartView startView) =>
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: startView.index,
            identifier: FunctionsSettings.functionMenuStartViewKey,
          ),
        );

    final initialTime = DateTime(2022, 03, 14, 13, 27);

    late StreamController<DateTime> clockStreamController;
    late MockFlutterLocalNotificationsPlugin
        mockFlutterLocalNotificationsPlugin;
    late MockAndroidFlutterLocalNotificationsPlugin
        mockAndroidFlutterLocalNotificationsPlugin;
    late StreamController<String> intentStreamController;

    setUp(() async {
      mockFlutterLocalNotificationsPlugin =
          MockFlutterLocalNotificationsPlugin();
      when(() => mockFlutterLocalNotificationsPlugin.cancel(any()))
          .thenAnswer((_) => Future.value());
      mockAndroidFlutterLocalNotificationsPlugin =
          MockAndroidFlutterLocalNotificationsPlugin();
      when(() => mockFlutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>())
          .thenReturn(mockAndroidFlutterLocalNotificationsPlugin);
      when(
        () =>
            mockAndroidFlutterLocalNotificationsPlugin.getActiveNotifications(),
      ).thenAnswer((invocation) => Future.value([]));

      notificationsPluginInstance = mockFlutterLocalNotificationsPlugin;
      scheduleAlarmNotificationsIsolated = noAlarmScheduler;
      clockStreamController = StreamController<DateTime>();
      final mockGenericDb = MockGenericDb();
      when(() => mockGenericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(genericResponse()));
      when(() => mockGenericDb.getAllDirty())
          .thenAnswer((_) => Future.value([]));

      final mockTimerDb = MockTimerDb();
      when(() => mockTimerDb.getAllTimers())
          .thenAnswer((_) => Future.value(timerResponse()));
      when(() => mockTimerDb.getRunningTimersFrom(any()))
          .thenAnswer((_) => Future.value(timerResponse()));

      intentStreamController = StreamController<String>();

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..database = FakeDatabase()
        ..genericDb = mockGenericDb
        ..timerDb = mockTimerDb
        ..client = Fakes.client()
        ..ticker = Ticker.fake(
          initialTime: initialTime,
          stream: clockStreamController.stream,
        )
        ..battery = FakeBattery()
        ..deviceDb = FakeDeviceDb()
        ..actionIntentStream = intentStreamController.stream.asBroadcastStream()
        ..init();
    });

    tearDown(() {
      GetIt.I.reset();
      genericResponse = () => [];
      timerResponse = () => [];
      clearNotificationSubject();
      clockStreamController.close();
      intentStreamController.close();
    });

    testWidgets('Goes from day calendar to Menu page when pressing home button',
        (tester) async {
      // Arrange
      genericResponse = () => [
            startViewGeneric(StartView.menu),
          ];

      // Act
      await tester.pumpApp();
      expect(find.byType(MenuPage), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsNothing);
      expect(find.byType(WeekCalendar), findsOneWidget);
      // Act press home button
      intentStreamController.add(AndroidIntentAction.homeButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WeekCalendar), findsNothing);
      expect(find.byType(MenuPage), findsOneWidget);
    });

    testWidgets('Pops screens on top', (tester) async {
      // Arrange
      genericResponse = () => [
            startViewGeneric(StartView.weekCalendar),
          ];

      // Act
      await tester.pumpApp();
      expect(find.byType(WeekCalendar), findsOneWidget);
      // Act go to settings
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SettingsButton));
      await tester.pumpAndSettle();

      expect(find.byType(WeekCalendar), findsNothing);
      expect(find.byType(SettingsPage), findsOneWidget);
      // Act press home button
      intentStreamController.add(AndroidIntentAction.homeButton);
      await tester.pumpAndSettle();

      // Assert at week calendar
      expect(find.byType(MenuPage), findsNothing);
      expect(find.byType(SettingsPage), findsNothing);
      expect(find.byType(WeekCalendar), findsOneWidget);
    });

    testWidgets('alarms are not closed but canceled', (tester) async {
      // Arrange
      final timer = AbiliaTimer.createNew(
          startTime: initialTime.subtract(30.seconds()), duration: 5.minutes());
      when(() => mockAndroidFlutterLocalNotificationsPlugin
          .getActiveNotifications()).thenAnswer(
        (invocation) => Future.value(
          [
            ActiveNotification(
              id: timer.hashCode,
              channelId: 'channelId',
              title: 'title',
              body: 'body',
            )
          ],
        ),
      );

      timerResponse = () => [timer];

      // Act
      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(5.minutes()));
      await tester.pumpAndSettle();

      // Assert -- Timer alarm
      expect(find.byType(TimerAlarmPage), findsOneWidget);

      // Act press home button
      intentStreamController.add(AndroidIntentAction.homeButton);
      await tester.pumpAndSettle();

      expect(find.byType(DayCalendar), findsNothing);
      expect(find.byType(TimerAlarmPage), findsOneWidget);

      verify(() => mockFlutterLocalNotificationsPlugin.cancel(timer.hashCode))
          .called(1);
      verify(() => mockAndroidFlutterLocalNotificationsPlugin
          .getActiveNotifications()).called(1);
    });
  }, skip: !Config.isMP);
}
