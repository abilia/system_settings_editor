import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_clock/ticker.dart';

import 'package:timezone/data/latest.dart' as tz;

import '../fakes/all.dart';
import '../mocks/mocks.dart';
import '../test_helpers/app_pumper.dart';
import '../test_helpers/register_fallback_values.dart';

void main() {
  setUpAll(() async {
    await Lokalise.initMock();
    tz.initializeTimeZones();
    setupPermissions();
    registerFallbackValues();
  });

  group('inactivity', () {
    GenericResponse genericResponse = () => [];
    TimerResponse timerResponse = () => [];
    ActivityResponse activityResponse = () => [];

    Generic activityTimeoutGeneric([int minutes = 1]) =>
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: minutes.minutes().inMilliseconds,
            identifier: TimeoutSettings.activityTimeoutKey,
          ),
        );
    Generic startViewGeneric(StartView startView) =>
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: startView.index,
            identifier: FunctionsSettings.functionMenuStartViewKey,
          ),
        );

    final useScreensaverGeneric = Generic.createNew<GenericSettingData>(
      data: GenericSettingData.fromData(
        data: true,
        identifier: TimeoutSettings.useScreensaverKey,
      ),
    );

    final initialTime = DateTime(2022, 03, 14, 13, 27);

    late StreamController<DateTime> clockStreamController;
    late MockSupportPersonsDb mockSupportPersonsDb;
    late MockFlutterLocalNotificationsPlugin
        mockFlutterLocalNotificationsPlugin;

    setUp(() async {
      mockFlutterLocalNotificationsPlugin =
          MockFlutterLocalNotificationsPlugin();
      when(() => mockFlutterLocalNotificationsPlugin.cancel(any()))
          .thenAnswer((_) => Future.value());
      notificationsPluginInstance = mockFlutterLocalNotificationsPlugin;
      scheduleNotificationsIsolated = noAlarmScheduler;
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

      final mockActivityDb = MockActivityDb();
      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value(activityResponse()));
      when(() => mockActivityDb.getAllAfter(any()))
          .thenAnswer((_) => Future.value([]));
      when(() => mockActivityDb.getAllDirty())
          .thenAnswer((_) => Future.value([]));

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

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..database = FakeDatabase()
        ..genericDb = mockGenericDb
        ..timerDb = mockTimerDb
        ..activityDb = mockActivityDb
        ..sortableDb = FakeSortableDb()
        ..client = fakeClient()
        ..ticker = Ticker.fake(
          initialTime: initialTime,
          stream: clockStreamController.stream,
        )
        ..battery = FakeBattery()
        ..deviceDb = FakeDeviceDb()
        ..supportPersonsDb = mockSupportPersonsDb
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
      expect(find.byType(DayCalendarTab), findsNothing);
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
      expect(find.byType(DayCalendarTab), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DayCalendarTab), findsNothing);
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
      expect(find.byType(DayCalendarTab), findsOneWidget);
      clockStreamController.add(initialTime.add(5.minutes()));
      await tester.pumpAndSettle();

      // Assert -- still at day calendar
      expect(find.byType(DayCalendarTab), findsOneWidget);

      // Act -- touch at 5 min, tick 5 min
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      clockStreamController.add(initialTime.add(10.minutes()));
      await tester.pumpAndSettle();

      // Assert -- still at day calendar
      expect(find.byType(DayCalendarTab), findsOneWidget);

      // Act -- tick 5 min since touch
      clockStreamController.add(initialTime.add(15.minutes()));
      await tester.pumpAndSettle();
      expect(find.byType(DayCalendarTab), findsNothing);
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
      expect(find.byType(DayCalendarTab), findsOneWidget);
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
      expect(find.byType(DayCalendarTab), findsOneWidget);
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
      expect(find.byType(DayCalendarTab), findsOneWidget);
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();

      // Assert -- ScreensaverPage
      expect(find.byType(ScreensaverPage), findsOneWidget);
      expect(find.byType(DayCalendarTab), findsNothing);

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
      expect(find.byType(DayCalendarTab), findsOneWidget);
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
            Generic.createNew<GenericSettingData>(
              data: GenericSettingData.fromData(
                data: true,
                identifier: TimeoutSettings.screensaverOnlyDuringNightKey,
              ),
            ),
          ];

      await tester.pumpApp();
      expect(find.byType(DayCalendarTab), findsOneWidget);
      // Act -- go to menu page
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      expect(find.byType(DayCalendarTab), findsNothing);

      // Act -- tick 1 min
      clockStreamController.add(initialTime.add(1.minutes()));
      await tester.pumpAndSettle();
      // Assert -- no screensaver page but returned to DayCalendar
      expect(find.byType(ScreensaverPage), findsNothing);
      expect(find.byType(DayCalendarTab), findsOneWidget);

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
      expect(find.byType(DayCalendarTab), findsNothing);

      // Act -- one hour into night
      clockStreamController.add(
        initialTime.onlyDays().add(night).add(1.hours()),
      );
      await tester.pumpAndSettle();

      // Assert -- still screensaver
      expect(find.byType(ScreensaverPage), findsOneWidget);
      expect(find.byType(DayCalendarTab), findsNothing);

      // Act -- Tick until to morning
      clockStreamController.add(
        initialTime.nextDay().onlyDays().add(morning),
      );
      await tester.pumpAndSettle();

      // Assert -- woke up, no more screensaver
      expect(find.byType(ScreensaverPage), findsNothing);
      expect(find.byType(DayCalendarTab), findsOneWidget);
    });

    group('exception to time out', () {
      setUp(() {
        genericResponse = () => [
              activityTimeoutGeneric(),
            ];
      });

      Future goToNewActivity(WidgetTester tester) async {
        await tester.pumpApp();
        expect(find.byType(DayCalendarTab), findsOneWidget);
        await tester.tap(find.byKey(TestKey.addActivityButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();
      }

      group('create activity', () {
        testWidgets('page', (tester) async {
          // Act
          await goToNewActivity(tester);
          expect(find.byType(EditActivityPage), findsOneWidget);
          clockStreamController.add(initialTime.add(2.minutes()));
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(EditActivityPage), findsOneWidget);
        });

        testWidgets('add recording page', (tester) async {
          // Act
          await goToNewActivity(tester);
          await tester.tap(
            find.descendant(
              of: find.byType(TabItem),
              matching: find.byIcon(AbiliaIcons.attention),
            ),
          );
          await tester.pumpAndSettle();

          final center = tester.getCenter(find.byType(EditActivityPage));
          await tester.dragFrom(center, const Offset(0.0, -100));
          await tester.pump();
          await tester.tap(find.byType(RecordSoundWidget).first);
          await tester.pumpAndSettle();
          expect(find.byType(RecordSoundPage), findsOneWidget);
          clockStreamController.add(initialTime.add(2.minutes()));
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(RecordSoundPage), findsOneWidget);
        });

        testWidgets('alarm page', (tester) async {
          // Act
          await goToNewActivity(tester);
          await tester.tap(
            find.descendant(
              of: find.byType(TabItem),
              matching: find.byIcon(AbiliaIcons.attention),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byType(AlarmWidget));
          await tester.pumpAndSettle();
          expect(find.byType(SelectAlarmTypePage), findsOneWidget);
          clockStreamController.add(initialTime.add(2.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(SelectAlarmTypePage), findsOneWidget);
        });

        testWidgets('Available For Page', (tester) async {
          // Act
          await goToNewActivity(tester);
          final center = tester.getCenter(find.byType(EditActivityPage));
          await tester.dragFrom(center, const Offset(0.0, -500));
          await tester.pump();
          await tester.tap(find.byType(AvailableForWidget));
          await tester.pumpAndSettle();
          expect(find.byType(AvailableForPage), findsOneWidget);
          clockStreamController.add(initialTime.add(2.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(AvailableForPage), findsOneWidget);
        });

        testWidgets('note page', (tester) async {
          // Act
          await goToNewActivity(tester);
          await tester.tap(
            find.descendant(
              of: find.byType(TabItem),
              matching: find.byIcon(AbiliaIcons.attachment),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ChangeInfoItemPicker));
          await tester.pumpAndSettle();
          clockStreamController.add(initialTime.add(2.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(SelectInfoTypePage), findsOneWidget);
          await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(EditNoteWidget));
          await tester.pumpAndSettle();
          expect(find.byType(EditNotePage), findsOneWidget);
          clockStreamController.add(initialTime.add(5.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(EditNotePage), findsOneWidget);
        });

        testWidgets('Note Library Page', (tester) async {
          // Act
          await goToNewActivity(tester);
          await tester.tap(
            find.descendant(
              of: find.byType(TabItem),
              matching: find.byIcon(AbiliaIcons.attachment),
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ChangeInfoItemPicker));
          await tester.pumpAndSettle();
          clockStreamController.add(initialTime.add(2.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(SelectInfoTypePage), findsOneWidget);
          await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(LibraryButton));
          await tester.pumpAndSettle();
          expect(find.byType(NoteLibraryPage), findsOneWidget);
          clockStreamController.add(initialTime.add(5.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(NoteLibraryPage), findsOneWidget);
        });

        testWidgets('Select Picture - Image archive', (tester) async {
          await goToNewActivity(tester);
          await tester.tap(find.byType(SelectPictureWidget));
          await tester.pumpAndSettle();
          expect(find.byType(SelectPicturePage), findsOneWidget);
          clockStreamController.add(initialTime.add(2.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(SelectPicturePage), findsOneWidget);
          await tester.tap(find.byKey(TestKey.imageArchiveButton));
          await tester.pumpAndSettle();
          expect(find.byType(ImageArchivePage), findsOneWidget);
          clockStreamController.add(initialTime.add(5.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(ImageArchivePage), findsOneWidget);
        });

        testWidgets('Time Interval Picker', (tester) async {
          // Act
          await goToNewActivity(tester);
          await tester.tap(find.byType(TimeIntervalPicker));
          await tester.pumpAndSettle();
          expect(find.byType(TimeInputPage), findsOneWidget);
          clockStreamController.add(initialTime.add(5.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(TimeInputPage), findsOneWidget);
        });

        testWidgets('date picker', (tester) async {
          // Act
          await goToNewActivity(tester);
          await tester.tap(find.byType(DatePicker));
          await tester.pumpAndSettle();
          expect(find.byType(DatePickerPage), findsOneWidget);
          clockStreamController.add(initialTime.add(5.minutes()));
          await tester.pumpAndSettle();
          expect(find.byType(DatePickerPage), findsOneWidget);
        });

        testWidgets('Create activity step by step', (tester) async {
          // Arrange
          genericResponse = () => [
                activityTimeoutGeneric(),
                Generic.createNew<GenericSettingData>(
                  data: GenericSettingData.fromData(
                    data: false,
                    identifier: AddActivitySettings.addActivityTypeAdvancedKey,
                  ),
                )
              ];

          // Act
          await tester.pumpApp();
          expect(find.byType(DayCalendarTab), findsOneWidget);
          await tester.tap(find.byKey(TestKey.addActivityButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.newActivityChoice));
          await tester.pumpAndSettle();
          expect(find.byType(TitleWiz), findsOneWidget);
          clockStreamController.add(initialTime.add(2.minutes()));
          await tester.pumpAndSettle();

          // Assert
          expect(find.byType(TitleWiz), findsOneWidget);
        });
      });

      testWidgets('Edit activity page', (tester) async {
        const activityTitle = 'activity title';
        activityResponse = () => [
              Activity.createNew(
                title: activityTitle,
                startTime: initialTime.add(1.hours()),
              )
            ];
        // Act
        await tester.pumpApp();
        await tester.tap(find.text(activityTitle));
        await tester.pumpAndSettle();
        expect(find.byType(ActivityPage), findsOneWidget);
        await tester.tap(find.byType(EditActivityButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditActivityPage), findsOneWidget);
        clockStreamController.add(initialTime.add(2.minutes()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(EditActivityPage), findsOneWidget);
      });

      testWidgets('Select Alarm Page', (tester) async {
        const activityTitle = 'activity title';
        activityResponse = () => [
              Activity.createNew(
                title: activityTitle,
                startTime: initialTime.add(1.hours()),
              )
            ];
        // Act
        await tester.pumpApp();
        await tester.tap(find.text(activityTitle));
        await tester.pumpAndSettle();
        expect(find.byType(ActivityPage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.editAlarm));
        await tester.pumpAndSettle();
        expect(find.byType(SelectAlarmPage), findsOneWidget);
        clockStreamController.add(initialTime.add(2.minutes()));
        await tester.pumpAndSettle();
        // Assert
        expect(find.byType(SelectAlarmPage), findsOneWidget);
      });

      testWidgets('Create timer page', (tester) async {
        // Act
        await tester.pumpApp();
        expect(find.byType(DayCalendarTab), findsOneWidget);
        await tester.tap(find.byKey(TestKey.addTimerButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.newTimerChoice));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerPage), findsOneWidget);
        clockStreamController.add(initialTime.add(2.minutes()));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerPage), findsOneWidget);
        await tester.tap(find.byIcon(AbiliaIcons.clock));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerDurationPage), findsOneWidget);
        clockStreamController.add(initialTime.add(5.minutes()));
        await tester.pumpAndSettle();
        expect(find.byType(EditTimerDurationPage), findsOneWidget);
      });

      testWidgets('Create activity template', (tester) async {
        genericResponse = () => [
              activityTimeoutGeneric(),
              startViewGeneric(StartView.menu),
            ];

        // Act
        await tester.pumpApp();
        expect(find.byType(MenuPage), findsOneWidget);
        await tester.tap(find.byType(BasicTemplatesButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AddTemplateButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditActivityPage), findsOneWidget);
        clockStreamController.add(initialTime.add(2.minutes()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(EditActivityPage), findsOneWidget);
      });

      testWidgets('Create timer template', (tester) async {
        genericResponse = () => [
              activityTimeoutGeneric(),
              startViewGeneric(StartView.menu),
            ];

        // Act
        await tester.pumpApp();
        expect(find.byType(MenuPage), findsOneWidget);
        await tester.tap(find.byType(BasicTemplatesButton));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
              of: find.byType(TabItem),
              matching: find.byIcon(AbiliaIcons.stopWatch)),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AddTemplateButton));
        await tester.pumpAndSettle();
        expect(find.byType(EditBasicTimerPage), findsOneWidget);
        clockStreamController.add(initialTime.add(2.minutes()));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(EditBasicTimerPage), findsOneWidget);
      });
    });
  }, skip: !Config.isMP);
}
