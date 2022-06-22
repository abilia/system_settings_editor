import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/utils/all.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'package:seagull/background/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

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
  GenericResponse genericResponse = () => [];
  TimerResponse timerResponse = () => [];

  Generic startViewGeneric(StartView startView) =>
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: startView.index,
          identifier: MemoplannerSettings.functionMenuStartViewKey,
        ),
      );

  final initialTime = DateTime(2022, 03, 14, 13, 27);

  late StreamController<DateTime> clockStreamController;
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin
      mockAndroidFlutterLocalNotificationsPlugin;
  late StreamController<String> intentStreamController;

  setUp(() async {
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    when(() => mockFlutterLocalNotificationsPlugin.cancel(any()))
        .thenAnswer((_) => Future.value());
    mockAndroidFlutterLocalNotificationsPlugin =
        MockAndroidFlutterLocalNotificationsPlugin();
    when(() => mockFlutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidFlutterLocalNotificationsPlugin);
    when(
      () => mockAndroidFlutterLocalNotificationsPlugin.getActiveNotifications(),
    ).thenAnswer((invocation) => Future.value([]));

    notificationsPluginInstance = mockFlutterLocalNotificationsPlugin;
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;
    clockStreamController = StreamController<DateTime>();
    final mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(genericResponse()));

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

  group('inactivity', () {
    /// see test/listener/inactivity_listener_test.dart
  });

  group('home button', () {
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

    testWidgets('alarms are Poped and canceled', (tester) async {
      // Arrange
      final timer = AbiliaTimer.createNew(
          startTime: initialTime.subtract(30.seconds()), duration: 5.minutes());
      when(() => mockAndroidFlutterLocalNotificationsPlugin
          .getActiveNotifications()).thenAnswer(
        (invocation) => Future.value(
          [ActiveNotification(timer.hashCode, 'channelId', 'title', 'body')],
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

      expect(find.byType(DayCalendar), findsOneWidget);

      verify(() => mockFlutterLocalNotificationsPlugin.cancel(timer.hashCode))
          .called(1);
      verify(() => mockAndroidFlutterLocalNotificationsPlugin
          .getActiveNotifications()).called(1);
    });
  }, skip: !Config.isMP);
}
