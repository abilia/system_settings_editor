import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import 'mocks.dart';

void main() {
  StreamController<DateTime> mockTicker;
  final mockActivityDb = MockActivityDb();
  final getItInitializer = GetItInitializer();
  final translater = Locales.language.values.first;

  final activityWithAlarmTime = DateTime(2011, 11, 11, 11, 11);
  final initialTime = activityWithAlarmTime.subtract(1.minutes());
  final activityWithAlarmday = activityWithAlarmTime.onlyDays();
  final twoHoursAfter = activityWithAlarmTime.add(2.hours());
  final activity = Activity.createNew(
    startTime: activityWithAlarmTime,
    title: 'actity',
    checkable: true,
  );
  final payloadSerial = json.encode(StartAlarm(
    activity,
    activityWithAlarmday,
  ).toJson());

  setUp(() async {
    setupPermissions({Permission.systemAlertWindow: PermissionStatus.granted});
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    mockTicker = StreamController<DateTime>();
    await clearNotificationSubject();

    final mockFirebasePushService = MockFirebasePushService();
    when(mockFirebasePushService.initPushToken())
        .thenAnswer((_) => Future.value('fakeToken'));

    final response = [activity];

    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(response));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    final db = MockDatabase();
    final mockBatch = MockBatch();
    when(mockBatch.commit()).thenAnswer((realInvocation) => Future.value([]));
    when(db.batch()).thenReturn(mockBatch);

    final mockUserFileDb = MockUserFileDb();
    when(
      mockUserFileDb.getMissingFiles(limit: anyNamed('limit')),
    ).thenAnswer(
      (value) => Future.value([]),
    );

    getItInitializer
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker(stream: mockTicker.stream, initialTime: initialTime)
      ..fireBasePushService = mockFirebasePushService
      ..client = Fakes.client(activityResponse: () => response)
      ..fileStorage = MockFileStorage()
      ..userFileDb = mockUserFileDb
      ..syncDelay = SyncDelays.zero
      ..alarmScheduler = noAlarmScheduler
      ..database = db
      ..alarmNavigator = AlarmNavigator()
      ..sortableDb = MockSortableDb()
      ..genericDb = MockGenericDb()
      ..init();
  });

  tearDown(() async {
    await GetIt.I.reset();
    notificationsPluginInstance = null;
    setupPermissions();
  });

  group('alarms and reminder test', () {
    testWidgets('Alarms shows', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(NavigatableAlarmPage), findsOneWidget);
    });

    testWidgets('Reminder shows', (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
            Activity.createNew(
              title: 'Reminder',
              startTime: activityWithAlarmTime.add(reminder),
              reminderBefore: [reminder.inMilliseconds],
            )
          ]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(NavigatableReminderPage), findsOneWidget);
      expect(find.text(translater.inTime('15 ${translater.minutes}')),
          findsOneWidget);
    });

    testWidgets('Reminder for unchecked activity shows',
        (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
            Activity.createNew(
              title: 'unchecked reminder',
              startTime: activityWithAlarmTime.subtract(reminder),
              checkable: true,
            )
          ]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(NavigatableReminderPage), findsOneWidget);
      expect(find.text(translater.timeAgo('15 ${translater.minutes}')),
          findsOneWidget);
    });

    testWidgets('Reminder for checked activity does not show if signed off',
        (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
            Activity.createNew(
              title: 'Reminder',
              startTime: activityWithAlarmTime.subtract(reminder),
              checkable: true,
              signedOffDates: [activityWithAlarmTime.onlyDays()],
            )
          ]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(NavigatableReminderPage), findsNothing);
    });

    testWidgets('Reminder for checked activity show from endtime',
        (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      final duration = 1.hours();
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
            Activity.createNew(
              title: 'Reminder',
              startTime: activityWithAlarmTime.subtract(reminder + duration),
              duration: duration,
              checkable: true,
            )
          ]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(NavigatableReminderPage), findsOneWidget);
      expect(find.text(translater.timeAgo('15 ${translater.minutes}')),
          findsOneWidget);
    });

    testWidgets('Alarms shows when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(NavigatableAlarmPage), findsNothing);
      // Act
      selectNotificationSubject.add(payloadSerial);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NavigatableAlarmPage), findsOneWidget);
    });

    testWidgets('Alarms shows when notification selected before app start',
        (WidgetTester tester) async {
      // Act
      mockTicker.add(twoHoursAfter);
      selectNotificationSubject.add(payloadSerial);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NavigatableAlarmPage), findsOneWidget);
    });

    testWidgets('BUG SGC-380 NotificationSubject is cleared on logout',
        (WidgetTester tester) async {
      // Act
      mockTicker.add(twoHoursAfter);
      selectNotificationSubject.add(payloadSerial);
      await tester.pumpApp();
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(NavigatableAlarmPage), findsOneWidget);
      expect(selectNotificationSubject, emits(payloadSerial));

      // Act logout
      await tester.tap(find.byIcon(AbiliaIcons.close_program));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      if (Config.isMP) {
        await tester.tap(find.byIcon(AbiliaIcons.settings));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.technical_settings));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byIcon(AbiliaIcons.power_off_on));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(LogoutButton));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);

      expect(selectNotificationSubject.values, isEmpty);

      // Act Login
      await tester.enterText_(find.byType(PasswordInput), 'secretPassword');
      await tester.enterText_(find.byType(UsernameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      // Assert no NavigatableAlarmPage
      expect(find.byType(NavigatableAlarmPage), findsNothing);
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('Alarms can be checked when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      selectNotificationSubject.add(payloadSerial);
      await tester.pumpAndSettle();

      // Assert -- Alarm is on screen and alarm is checkable
      expect(find.byType(NavigatableAlarmPage), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.uncheckButton), findsNothing);

      // Act -- Tap the check button
      await tester.tap(find.byKey(TestKey.activityCheckButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();

      // Assert -- Alarm is checked
      expect(find.byKey(TestKey.uncheckButton),
          findsNothing); // Uncheck button only in bottom bar (not present in alarm view)
      expect(find.byKey(TestKey.activityCheckButton), findsNothing);
      expect(find.byType(NavigatableAlarmPage), findsNothing);
    });

    testWidgets('Popup Alarms can be signed off', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Act -- alarm time happend
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();

      // Assert -- On screen alarm showing and check button showing
      expect(find.byType(NavigatableAlarmPage), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.uncheckButton), findsNothing);

      // Act -- Tap the check button
      await tester.tap(find.byKey(TestKey.activityCheckButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();

      // Assert -- Check button not showing and uncheck button still not showing (only shown in activity bottom bar)
      expect(find.byType(NavigatableAlarmPage), findsNothing);
    });

    testWidgets('Checkable Popup Alarm with checklist',
        (WidgetTester tester) async {
      // Arrange
      final startTime = DateTime(2021, 02, 16, 12, 00);
      final startDay = startTime.onlyDays();
      final unchecked = 'unchecked';
      final checkableActivityWithChecklist = Activity.createNew(
        title: 'checkableActivityWithChecklist',
        startTime: startTime,
        checkable: true,
        infoItem: Checklist(
          questions: [
            Question(id: 0, name: 'checked'),
            Question(id: 1, name: unchecked),
          ],
          checked: {
            Checklist.dayKey(startDay): {0}
          },
        ),
      );
      final checkableActivityPayloadSerial = json.encode(StartAlarm(
        checkableActivityWithChecklist,
        startDay,
      ).toJson());

      selectNotificationSubject.add(checkableActivityPayloadSerial);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Act -- alarm time happend
      mockTicker.add(startTime);
      await tester.pumpAndSettle();

      // Assert -- On screen alarm showing, check button and checklist showing
      expect(find.byType(NavigatableAlarmPage), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.uncheckButton), findsNothing);
      expect(find.byType(ChecklistView), findsOneWidget);
      expect(find.byType(QuestionView), findsNWidgets(2));

      // Act -- Check all questions
      await tester.tap(find.text(unchecked));
      await tester.pumpAndSettle();

      // Assert -- Shows All items checked popup
      expect(find.byType(CheckActivityConfirmDialog), findsOneWidget);

      // Act -- Press affermative on check popup
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();

      // Assert -- Check button gone and AlarmPage gone
      expect(find.byType(NavigatableAlarmPage), findsNothing);
    });
  });

  group('Multiple alarms tests', () {
    final activity1StartTime = DateTime(2011, 11, 11, 11, 11);
    final day = activity1StartTime.onlyDays();
    final activity1 = Activity.createNew(
        title: '111111', startTime: activity1StartTime, duration: 2.minutes());
    final startTimeActivity1NotificationPayload = json.encode(StartAlarm(
      activity1,
      day,
    ).toJson());

    final activity2StartTime = activity1StartTime.add(1.minutes());
    final activity2 = Activity.createNew(
        title: '2222222', startTime: activity2StartTime, duration: 2.minutes());

    testWidgets('Start and end time alarm for same activity',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byType(NavigatableAlarmPage);

      // Act - time goes which should display start alarm
      mockTicker.add(activity1StartTime);
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

      // Act - time goes which should display end alarm
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byIcon(AbiliaIcons.close_program));
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Start alarm is displayed on top if tapped on notification',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byType(NavigatableAlarmPage);

      // Act - time goes which should display alarm
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      selectNotificationSubject.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byIcon(AbiliaIcons.close_program));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown since the start time alarm should have been moved to top
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Overlapping activities', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1, activity2]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byType(NavigatableAlarmPage);

      // Act - time goes which should display alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 1)));
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      mockTicker.add(activity1StartTime.add(Duration(minutes: 3)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      selectNotificationSubject.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm for activity1
      expect(alarmScreenFinder, findsOneWidget);
      expect(
          tester
              .widget<NavigatableAlarmPage>(alarmScreenFinder)
              .alarm
              .activityDay
              .activity
              .id,
          equals(activity1.id));

      // Act - tap the ok button of the alarm
      await tester.tap(find.byIcon(AbiliaIcons.close_program));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm for activity 2
      expect(alarmScreenFinder, findsOneWidget);

      expect(
          tester
              .widget<NavigatableAlarmPage>(alarmScreenFinder)
              .alarm
              .activityDay
              .activity
              .id,
          equals(activity2.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byIcon(AbiliaIcons.close_program));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Start alarm can show twice after close (BUG SGC-244)',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1]));
      final pushBloc = PushBloc();
      await tester.pumpWidget(App(pushBloc: pushBloc));
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byType(NavigatableAlarmPage);

      // Act - time goes which should display alarm
      mockTicker.add(activity1StartTime);
      await tester.pumpAndSettle();

      // Expect - the alarm should now be the start time alarm for activity1
      expect(alarmScreenFinder, findsOneWidget);
      expect(
          tester
              .widget<NavigatableAlarmPage>(alarmScreenFinder)
              .alarm
              .activityDay
              .activity
              .id,
          equals(activity1.id));

      // Act - tap the ok button of the alarm, no more alarm
      await tester.tap(find.byIcon(AbiliaIcons.close_program));
      await tester.pumpAndSettle();
      expect(alarmScreenFinder, findsNothing);

      // Activity change forward one minute from backend and is pushed
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value([
            activity1.copyWith(startTime: activity1StartTime.add(1.minutes()))
          ]));
      pushBloc.add(PushEvent('calendar'));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      selectNotificationSubject.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      // Expect - the alarm should be the start time alarm for activity 1
      expect(alarmScreenFinder, findsOneWidget);

      expect(
          (tester.widget(alarmScreenFinder) as NavigatableAlarmPage)
              .alarm
              .activityDay
              .activity
              .id,
          equals(activity1.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byIcon(AbiliaIcons.close_program));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Alarm only shows latest', (WidgetTester tester) async {
      // Arrange
      final start = activity1StartTime;

      final activities = [
        Activity.createNew(
            startTime: start.add(2.minutes()),
            alarmType: ALARM_SILENT,
            checkable: true,
            duration: 1.minutes(),
            title: 'ALARM_SILENT'),
        Activity.createNew(
            startTime: start.add(4.minutes()),
            duration: 1.minutes(),
            checkable: true,
            alarmType: ALARM_VIBRATION,
            title: 'ALARM_VIBRATION'),
        Activity.createNew(
            startTime: start.add(6.minutes()),
            checkable: true,
            duration: 1.minutes(),
            alarmType: ALARM_SOUND_ONLY_ON_START,
            title: 'ALARM_SOUND_ONLY_ON_START'),
        Activity.createNew(
            startTime: start.add(8.minutes()),
            duration: 1.minutes(),
            checkable: true,
            alarmType: ALARM_SOUND_AND_VIBRATION,
            title: 'ALARM_SOUND_AND_VIBRATION'),
        Activity.createNew(
            startTime: start.add(10.minutes()),
            duration: 1.minutes(),
            reminderBefore: [1.minutes().inMilliseconds],
            alarmType: NO_ALARM,
            checkable: true,
            title: 'NO_ALARM'),
        Activity.createNew(
            startTime: start.add(11.minutes()),
            reminderBefore: [10.minutes().inMilliseconds],
            checkable: true,
            alarmType: ALARM_SILENT,
            title: 'ALARM_SILENT reminder 10 min before'),
      ];

      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(activities));

      final reminderFinder =
          find.byType(NavigatableReminderPage, skipOffstage: false);
      final alarmScreenFinder =
          find.byType(NavigatableAlarmPage, skipOffstage: false);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Act - time goes for two hours
      for (var i = 0; i < 60 * 2; i++) {
        mockTicker.add(activity1StartTime.add(i.minutes()));
      }
      await tester.pumpAndSettle();

      // Expect - the alarm screens should be removed and only the latest reminders should show
      expect(reminderFinder, findsNWidgets(activities.length));
      expect(alarmScreenFinder, findsNothing);
    });

    group('fullscreen alarms', () {
      testWidgets('Full screen shows', (WidgetTester tester) async {
        // Arrange
        final reminder = ReminderBefore(
            Activity.createNew(
                title: 'one reminder title', startTime: activity1StartTime),
            activity1StartTime.onlyDays(),
            reminder: 15.minutes());

        // Act
        await tester.pumpWidget(
          App(
            payload: reminder,
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(FullScreenAlarm), findsOneWidget);
        expect(find.text(reminder.activity.title), findsOneWidget);
      });

      testWidgets('Fullscreen alarms ignores same alarm ',
          (WidgetTester tester) async {
        // Arrange
        final mockAlarmNavigator = MockAlarmNavigator();
        final alarmNavigator = AlarmNavigator();
        when(mockAlarmNavigator.alarmRouteObserver)
            .thenReturn(alarmNavigator.alarmRouteObserver);

        await GetIt.I.reset();
        getItInitializer
          ..alarmNavigator = mockAlarmNavigator
          ..init();
        final reminder = ReminderBefore(
            Activity.createNew(
              title: 'one reminder title',
              startTime: activity1StartTime,
            ),
            activity1StartTime.onlyDays(),
            reminder: 15.minutes());

        final reminderJson = reminder.toJson();
        final payload = json.encode(reminderJson);

        await tester.pumpWidget(
          App(
            payload: reminder,
          ),
        );
        await tester.pumpAndSettle();

        // Act
        selectNotificationSubject.add(payload);
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(FullScreenAlarm), findsOneWidget);
        expect(find.text(reminder.activity.title), findsOneWidget);
        verifyNever(mockAlarmNavigator.pushAlarm(any, any));
      });

      testWidgets('Fullscreen alarms stack ', (WidgetTester tester) async {
        // Arrange
        final reminder = ReminderBefore(
            Activity.createNew(
              title: 'one reminder title',
              startTime: activity1StartTime,
            ),
            activity1StartTime.onlyDays(),
            reminder: 15.minutes());
        final alarm = StartAlarm(
          Activity.createNew(
            title: 'one alarm title',
            startTime: activity1StartTime,
          ),
          activity1StartTime.onlyDays(),
        );
        final alarmPayload = json.encode(alarm.toJson());

        // Act
        await tester.pumpWidget(
          App(
            payload: reminder,
          ),
        );
        await tester.pumpAndSettle();

        // Assert -- Fullscreen alarm shows
        expect(find.byType(FullScreenAlarm), findsOneWidget);
        expect(find.text(reminder.activity.title), findsOneWidget);

        // Act -- notification tapped
        selectNotificationSubject.add(alarmPayload);
        await tester.pumpAndSettle();

        // Assert -- new alarm page
        expect(find.byType(FullScreenAlarm), findsNothing);
        expect(find.text(reminder.activity.title), findsNothing);
        expect(find.byType(NavigatableAlarmPage), findsOneWidget);
        expect(find.text(alarm.activity.title), findsOneWidget);

        // Act -- Close alarm page
        await tester.tap(find.byIcon(AbiliaIcons.close_program));
        await tester.pumpAndSettle();

        // Assert -- first alarm page
        expect(find.byType(FullScreenAlarm), findsOneWidget);
        expect(find.text(reminder.activity.title), findsOneWidget);
      });

      testWidgets('multiple notifications at the same time ',
          (WidgetTester tester) async {
        final alarm1 = StartAlarm(
          Activity.createNew(
            title: 'one alarm title',
            startTime: activity1StartTime,
          ),
          activity1StartTime.onlyDays(),
        );
        final alarm2 = StartAlarm(
          Activity.createNew(
            title: 'two alarm title',
            startTime: activity1StartTime,
          ),
          activity1StartTime.onlyDays(),
        );
        final alarm3 = StartAlarm(
          Activity.createNew(
            title: 'three alarm title',
            startTime: activity1StartTime,
          ),
          activity1StartTime.onlyDays(),
        );
        final alarm4 = StartAlarm(
          Activity.createNew(
            title: 'four alarm title',
            startTime: activity1StartTime,
          ),
          activity1StartTime.onlyDays(),
        );
        final alarm2Json = alarm2.toJson();
        final alarm3Json = alarm3.toJson();
        final alarm4Json = alarm4.toJson();
        final payload2 = json.encode(alarm2Json);
        final payload3 = json.encode(alarm3Json);
        final payload4 = json.encode(alarm4Json);

        // Arrange
        selectNotificationSubject.add(payload2);
        selectNotificationSubject.add(payload3);
        selectNotificationSubject.add(payload4);

        await tester.pumpWidget(
          App(
            payload: alarm1,
          ),
        );
        await tester.pumpAndSettle();

        // Assert -- Fullscreen alarm shows
        expect(
          find.byType(FullScreenAlarm, skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.byType(AlarmPage, skipOffstage: false),
          findsNWidgets(4),
        );
        expect(
          find.byType(NavigatableAlarmPage, skipOffstage: false),
          findsNWidgets(3),
        );
        expect(
          find.text(alarm1.activity.title, skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text(alarm2.activity.title, skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text(alarm3.activity.title, skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text(alarm4.activity.title, skipOffstage: false),
          findsOneWidget,
        );
      });
    });
  });
}
