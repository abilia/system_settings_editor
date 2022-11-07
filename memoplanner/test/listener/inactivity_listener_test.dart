import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

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

  group('app', () {
    GenericResponse genericResponse = () => [];
    TimerResponse timerResponse = () => [];

    Generic activityTimeoutGeneric([int minutes = 1]) =>
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: minutes.minutes().inMilliseconds,
            identifier: TimeoutSettings.activityTimeoutKey,
          ),
        );
    Generic startViewGeneric(StartView startView) =>
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: startView.index,
            identifier: FunctionsSettings.functionMenuStartViewKey,
          ),
        );

    final useScreensaverGeneric = Generic.createNew<MemoplannerSettingData>(
      data: MemoplannerSettingData.fromData(
        data: true,
        identifier: TimeoutSettings.useScreensaverKey,
      ),
    );

    final initialTime = DateTime(2022, 03, 14, 13, 27);

    late StreamController<DateTime> clockStreamController;
    late MockFlutterLocalNotificationsPlugin
        mockFlutterLocalNotificationsPlugin;

    setUp(() async {
      mockFlutterLocalNotificationsPlugin =
          MockFlutterLocalNotificationsPlugin();
      when(() => mockFlutterLocalNotificationsPlugin.cancel(any()))
          .thenAnswer((_) => Future.value());
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
        ..init();
    });

    tearDown(() {
      GetIt.I.reset();
      genericResponse = () => [];
      timerResponse = () => [];
      clearNotificationSubject();
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
      expect(find.byType(MenuPage), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsNothing);
      expect(find.byType(WeekCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DayCalendar), findsNothing);
      expect(find.byType(MenuPage), findsOneWidget);
    });

    testWidgets('Goes from day calendar to screensaver and menu under',
        (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(),
            startViewGeneric(StartView.menu),
            useScreensaverGeneric,
          ];

      // Act
      await tester.pumpApp();
      expect(find.byType(MenuPage), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.day));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsNothing);
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DayCalendar), findsNothing);
      expect(find.byType(ScreensaverPage), findsOneWidget);

      // Act
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ScreensaverPage), findsNothing);
      expect(find.byType(MenuPage), findsOneWidget);
    });

    testWidgets('Stacks PhotoCalendarPage then screensaver under',
        (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(),
            startViewGeneric(StartView.photoAlbum),
            useScreensaverGeneric,
          ];

      // Act
      await tester.pumpApp();
      expect(find.byType(PhotoCalendarPage), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PhotoCalendarPage), findsNothing);
      expect(find.byType(ScreensaverPage), findsOneWidget);

      // Act
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ScreensaverPage), findsNothing);
      expect(find.byType(PhotoCalendarPage), findsOneWidget);
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
      expect(find.byType(ScreensaverPage), findsOneWidget);
    });

    testWidgets('Timer alarm fire screen does not time out', (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(10),
            useScreensaverGeneric,
          ];

      final timer = AbiliaTimer.createNew(
          startTime: initialTime.subtract(30.seconds()), duration: 5.minutes());

      timerResponse = () => [timer];

      // Act -- Tick 5 min
      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(5.minutes()));
      await tester.pumpAndSettle();

      // Assert -- Timer alarm
      expect(find.byType(TimerAlarmPage), findsOneWidget);

      // Act -- Tick 6 min
      await tester.pumpAndSettle();
      clockStreamController.add(initialTime.add(11.minutes()));
      await tester.pumpAndSettle();

      // Assert -- still at day calendar
      expect(find.byType(TimerAlarmPage), findsOneWidget);

      // Act -- tick 5 min since alarm
      clockStreamController.add(initialTime.add(15.minutes()));
      await tester.pumpAndSettle();
      expect(find.byType(TimerAlarmPage), findsNothing);
      expect(find.byType(ScreensaverPage), findsOneWidget);
    });

    testWidgets('Activity alarm fire screen does not time out', (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(10),
            useScreensaverGeneric,
          ];

      final activityTime = initialTime.add(5.minutes());
      final startAlarm = StartAlarm(
        ActivityDay(Activity.createNew(startTime: activityTime),
            initialTime.onlyDays()),
      );

      // Act -- tick 5 min, alarm fires
      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(activityTime);
      selectNotificationSubject.add(startAlarm);
      await tester.pumpAndSettle();

      // Assert -- Timer alarm
      expect(find.byType(AlarmPage), findsOneWidget);

      // Act -- Tick 5 min
      await tester.pumpAndSettle();
      clockStreamController.add(activityTime.add(5.minutes()));
      await tester.pumpAndSettle();

      // Assert -- still at day calendar
      expect(find.byType(AlarmPage), findsOneWidget);

      // Act -- tick 5 min since alarm
      clockStreamController.add(activityTime.add(10.minutes()));
      await tester.pumpAndSettle();
      expect(find.byType(AlarmPage), findsNothing);
      expect(find.byType(ScreensaverPage), findsOneWidget);
    });

    testWidgets('Alarm removes screensaver', (tester) async {
      // Arrange
      genericResponse = () => [
            activityTimeoutGeneric(1),
            useScreensaverGeneric,
          ];
      final timer = AbiliaTimer.createNew(
        startTime: initialTime.subtract(30.seconds()),
        duration: 5.minutes(),
      );

      timerResponse = () => [timer];

      // Act -- tick 1 min
      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert -- ScreensaverPage
      expect(find.byType(ScreensaverPage), findsOneWidget);
      expect(find.byType(DayCalendar), findsNothing);

      // Act -- tick 4 min
      clockStreamController.add(initialTime.add(5.minutes()));
      await tester.pumpAndSettle();

      // Assert -- TimerAlarm Fired, on timer alarm
      expect(find.byType(TimerAlarmPage), findsOneWidget);
      expect(find.byType(ScreensaverPage), findsNothing);

      // Act -- close TimerAlarmPage
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();

      // Assert -- no screensaver,
      expect(find.byType(DayCalendar), findsOneWidget);
      expect(find.byType(TimerAlarmPage), findsNothing);
      expect(find.byType(ScreensaverPage), findsNothing);

      // Assert -- alarm is canceled

      final verification = verify(
          () => mockFlutterLocalNotificationsPlugin.cancel(captureAny()));
      expect(verification.callCount, 1);
      final id = TimerAlarm(timer).hashCode;
      expect(verification.captured.single, id);
    });

    testWidgets('Screensaver only during night', (tester) async {
      // Arrange
      const dayParts = DayParts();
      final night = dayParts.night;
      final morning = dayParts.morning;
      genericResponse = () => [
            activityTimeoutGeneric(1),
            useScreensaverGeneric,
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: true,
                identifier: TimeoutSettings.screensaverOnlyDuringNightKey,
              ),
            ),
          ];

      await tester.pumpApp();
      expect(find.byType(DayCalendar), findsOneWidget);
      // Act -- go to menu page
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      expect(find.byType(DayCalendar), findsNothing);

      // Act -- tick 1 min
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();
      // Assert -- no screensaver page but returned to DayCalendar
      expect(find.byType(ScreensaverPage), findsNothing);
      expect(find.byType(DayCalendar), findsOneWidget);

      // Act -- Tick until one minute before night
      clockStreamController.add(
        initialTime.onlyDays().add(night).subtract(1.minutes()),
      );
      await tester.pumpAndSettle();

      // Assert -- still no screensaver
      expect(find.byType(ScreensaverPage), findsNothing);

      // Act -- Tick until to night
      clockStreamController.add(initialTime.onlyDays().add(night));
      await tester.pumpAndSettle();

      // Assert -- now shows screensaver
      expect(find.byType(ScreensaverPage), findsOneWidget);
      expect(find.byType(DayCalendar), findsNothing);

      // Act -- one hour into night
      clockStreamController.add(
        initialTime.onlyDays().add(night).add(1.hours()),
      );
      await tester.pumpAndSettle();

      // Assert -- still screensaver
      expect(find.byType(ScreensaverPage), findsOneWidget);
      expect(find.byType(DayCalendar), findsNothing);

      // Act -- Tick until to morning
      clockStreamController.add(
        initialTime.nextDay().onlyDays().add(morning),
      );
      await tester.pumpAndSettle();

      // Assert -- woke up, no more screensaver
      expect(find.byType(ScreensaverPage), findsNothing);
      expect(find.byType(DayCalendar), findsOneWidget);
    });
  }, skip: !Config.isMP);
}
