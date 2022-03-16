import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/listener/inactivity_listener.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../fakes/all.dart';
import '../mocks/mocks.dart';
import '../test_helpers/app_pumper.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    setupPermissions();
    registerFallbackValues();
  });

  group('minimum', () {
    final DateTime initialTime = DateTime(2122, 06, 06, 06, 00);
    final Ticker fakeTicker = Ticker.fake(initialTime: initialTime);
    final MemoplannerSettingBloc settingBloc = FakeMemoplannerSettingsBloc();
    late InactivityCubit inactivityCubit;

    setUp(() async {
      inactivityCubit = InactivityCubit(const Duration(minutes: 1), fakeTicker,
          settingBloc, TouchDetectionCubit().stream);
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
        ..init();
    });

    tearDown(() {
      inactivityCubit.close();
      GetIt.I.reset();
    });

    Widget _wrapWithMaterialApp({Widget? child}) => TopLevelBlocsProvider(
          runStartGuide: false,
          child: AuthenticatedBlocsProvider(
            memoplannerSettingBloc: settingBloc,
            authenticatedState: const Authenticated(token: '', userId: 1),
            child: BlocProvider<InactivityCubit>(
              create: (context) => inactivityCubit,
              child: MaterialApp(
                theme: abiliaTheme,
                home: MultiBlocListener(listeners: [
                  CalendarInactivityListener(),
                  ScreenSaverListener(),
                ], child: child ?? const CalendarPage()),
              ),
            ),
          ),
        );

    group('Home screen inactivity', () {
      testWidgets(
          'When timeout is reached, screen saver is false, app switches to WeekCalendar',
          (tester) async {
        await tester
            .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
        inactivityCubit.emit(
          const HomeScreenInactivityThresholdReached(
            startView: StartView.weekCalendar,
            showScreensaver: false,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(WeekCalendar), findsOneWidget);
      });

      testWidgets(
          'When timeout is reached, screen saver is false, app switches to MonthCalendar',
          (tester) async {
        await tester
            .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
        inactivityCubit.emit(
          const HomeScreenInactivityThresholdReached(
            startView: StartView.monthCalendar,
            showScreensaver: false,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MonthCalendar), findsOneWidget);
      });

      testWidgets(
          'When timeout is reached, screen saver is false, app switches to Menu',
          (tester) async {
        await tester
            .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
        inactivityCubit.emit(
          const HomeScreenInactivityThresholdReached(
            startView: StartView.menu,
            showScreensaver: false,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(MenuPage), findsOneWidget);
      });

      testWidgets(
          'When timeout is reached, screen saver is false, app switches to PhotoCalendar',
          (tester) async {
        await tester
            .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
        inactivityCubit.emit(
          const HomeScreenInactivityThresholdReached(
            startView: StartView.photoAlbum,
            showScreensaver: false,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(PhotoCalendarPage), findsOneWidget);
      });

      testWidgets(
          'When timeout is reached, screen saver is true, app switches to ScreenSaver',
          (tester) async {
        await tester
            .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
        inactivityCubit.emit(
          const HomeScreenInactivityThresholdReached(
            startView: StartView.menu,
            showScreensaver: true,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(ScreenSaverPage), findsOneWidget);
      });

      testWidgets(
          'When timeout is reached, screen saver is false, '
          'app switches to DayCalendar from Menu', (tester) async {
        await tester
            .pumpWidget(_wrapWithMaterialApp(child: const CalendarPage()));
        await tester.tap(find.byType(MenuButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(SettingsButton));
        await tester.pumpAndSettle();
        inactivityCubit.emit(
          const HomeScreenInactivityThresholdReached(
            startView: StartView.dayCalendar,
            showScreensaver: false,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DayCalendar), findsOneWidget);
      });
    }, skip: !Config.isMP);

    group('Calendar inactivity', () {
      final local = Intl.getCurrentLocale();
      testWidgets(
          'When timeout is reached, day calendar switches to current day',
          (tester) async {
        await tester
            .pumpWidget(_wrapWithMaterialApp(child: const DayCalendar()));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
        await tester.pumpAndSettle();
        expect(find.text(DateFormat.EEEE(local).format(initialTime)),
            findsNothing);
        inactivityCubit.emit(
          CalendarInactivityThresholdReached(initialTime),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DayCalendar), findsOneWidget);
        expect(find.text(DateFormat.EEEE(local).format(initialTime)),
            findsOneWidget);
      });

      testWidgets('When timeout is reached, if not in calendar, do nothing',
          (tester) async {
        await tester
            .pumpWidget(_wrapWithMaterialApp(child: const SettingsPage()));
        await tester.pumpAndSettle();
        inactivityCubit.emit(
          CalendarInactivityThresholdReached(initialTime),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DayCalendar), findsNothing);
      });
    });
  });

  group('app', () {
    GenericResponse genericResponse = () => [];

    Generic activityTimeoutGeneric([int minutes = 1]) =>
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: minutes.minutes().inMilliseconds,
            identifier: MemoplannerSettings.activityTimeoutKey,
          ),
        );
    Generic startViewGeneric(StartView startView) =>
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: startView.index,
            identifier: MemoplannerSettings.functionMenuStartViewKey,
          ),
        );

    final useScreensaverGeneric = Generic.createNew<MemoplannerSettingData>(
      data: MemoplannerSettingData.fromData(
        data: true,
        identifier: MemoplannerSettings.useScreensaverKey,
      ),
    );

    final initialTime = DateTime(2022, 03, 14, 13, 27);

    late StreamController<DateTime> clockStreamController;

    setUp(() async {
      clockStreamController = StreamController<DateTime>();
      final mockGenericDb = MockGenericDb();
      when(() => mockGenericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(genericResponse()));
      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..database = FakeDatabase()
        ..genericDb = mockGenericDb
        ..client = Fakes.client()
        ..ticker = Ticker.fake(
          initialTime: initialTime,
          stream: clockStreamController.stream,
        )
        ..battery = FakeBattery()
        ..init();
    });

    tearDown(() {
      GetIt.I.reset();
      genericResponse = () => [];
      clockStreamController.close();
    });

    testWidgets('Goes from day calendar to Menu page when activity timeout',
        (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(),
            startViewGeneric(StartView.menu),
          ];

      // Act
      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DayCalendar), findsNothing);
      expect(find.byType(MenuPage), findsOneWidget);
    });

    testWidgets('Goes from ay calendar to screen saver and menu under',
        (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(),
            startViewGeneric(StartView.menu),
            useScreensaverGeneric,
          ];

      // Act
      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DayCalendar), findsNothing);
      expect(find.byType(ScreenSaverPage), findsOneWidget);

      // Act
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ScreenSaverPage), findsNothing);
      expect(find.byType(MenuPage), findsOneWidget);
    });

    testWidgets('Stacks photopage then screen saver under', (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(),
            startViewGeneric(StartView.photoAlbum),
            useScreensaverGeneric,
          ];

      // Act
      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DayCalendar), findsNothing);
      expect(find.byType(ScreenSaverPage), findsOneWidget);

      // Act
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ScreenSaverPage), findsNothing);
      expect(
        find.byType(PhotoPage),
        findsOneWidget,
        skip: 'For some reason both ScreenSaverPage and PhotoPage'
            ' pops in test',
      );
    });

    testWidgets('Touched screen does not time out', (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(10),
            useScreensaverGeneric,
          ];

      // Act -- tick 5 min
      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(5.minutes()));
      await tester.pumpAndSettle();

      // Assert -- still at day calendar
      expect(find.byType(DayCalendar), findsOneWidget);

      // Act -- touch at 5 min, tick 5 min
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      clockStreamController.add(initialTime.add(10.minutes()));
      await tester.pumpAndSettle();

      // Assert -- still at day calendar
      expect(find.byType(DayCalendar), findsOneWidget);

      // Act -- tick 5 min since touch
      clockStreamController.add(initialTime.add(15.minutes()));
      await tester.pumpAndSettle();
      expect(find.byType(DayCalendar), findsNothing);
      expect(find.byType(ScreenSaverPage), findsOneWidget);
    });
  }, skip: !Config.isMP);
}