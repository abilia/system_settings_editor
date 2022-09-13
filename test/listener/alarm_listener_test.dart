import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:timezone/timezone.dart' as tz;

import '../fakes/all.dart';
import '../mocks/mocks.dart';
import '../test_helpers/enter_text.dart';
import '../test_helpers/app_pumper.dart';

void main() {
  late StreamController<DateTime> mockTicker;
  final mockActivityDb = MockActivityDb();
  final mockGenericDb = MockGenericDb();
  final mockTimerDb = MockTimerDb();
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

  final payload = StartAlarm(
    ActivityDay(
      activity,
      activityWithAlarmday,
    ),
  );

  setUp(() async {
    tz.setLocalLocation(tz.UTC);
    setupPermissions({Permission.systemAlertWindow: PermissionStatus.granted});
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    mockTicker = StreamController<DateTime>();

    final response = [activity];

    when(() =>
            notificationsPluginInstance!.cancel(any(), tag: any(named: 'tag')))
        .thenAnswer((_) => Future.value());
    when(() => mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(response));
    when(() => mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value([]));
    when(() => mockActivityDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));
    when(() => mockActivityDb.getAllAfter(any()))
        .thenAnswer((_) => Future.value(response));
    when(() => mockActivityDb.getAllBetween(any(), any()))
        .thenAnswer((_) => Future.value(response));
    when(() => mockActivityDb.getById(any())).thenAnswer((_) => Future.value());

    when(() => mockTimerDb.getAllTimers()).thenAnswer((_) => Future.value([]));
    when(() => mockTimerDb.getRunningTimersFrom(any()))
        .thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((realInvocation) => Future.value([]));
    when(() => mockGenericDb.getAllDirty())
        .thenAnswer((realInvocation) => Future.value([]));

    getItInitializer
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..timerDb = mockTimerDb
      ..ticker = Ticker.fake(
        stream: mockTicker.stream,
        initialTime: initialTime,
      )
      ..fireBasePushService = FakeFirebasePushService()
      ..client = Fakes.client(activityResponse: () => response)
      ..fileStorage = MockFileStorage()
      ..userFileDb = FakeUserFileDb()
      ..database = FakeDatabase()
      ..alarmNavigator = AlarmNavigator()
      ..sortableDb = FakeSortableDb()
      ..genericDb = mockGenericDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() async {
    await GetIt.I.reset();
    await clearNotificationSubject();
    notificationsPluginInstance = null;
    mockTicker.close();
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
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
      expect(find.byType(AlarmPage), findsOneWidget);
    });

    testWidgets('SGC-1874 alarm with end time at midnight will show',
        (WidgetTester tester) async {
      // Arrange
      final startTime = DateTime(2011, 11, 11, 23, 00);
      final activity = Activity.createNew(
        startTime: startTime,
        duration: 1.hours(),
        title: 'activity',
        checkable: true,
      );
      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value([activity]));

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(startTime.add(1.hours()));
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
    });

    testWidgets('SGC-1710 Alarms does not show when disable for 24h is set',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: activityWithAlarmTime
                    .onlyDays()
                    .nextDay()
                    .millisecondsSinceEpoch,
                identifier: AlarmSettings.alarmsDisabledUntilKey,
              ),
            ),
          ],
        ),
      );

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(PopAwareAlarmPage), findsNothing);
      expect(find.byType(AlarmPage), findsNothing);
    });

    testWidgets('Reminder shows', (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value([
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
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
      expect(find.byType(ReminderPage), findsOneWidget);
      expect(find.text(translater.inTime('15 ${translater.minutes}')),
          findsOneWidget);
    });

    testWidgets('Reminder for unchecked activity shows',
        (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value([
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
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
      expect(find.byType(ReminderPage), findsOneWidget);
      expect(find.text(translater.timeAgo('15 ${translater.minutes}')),
          findsOneWidget);
    });

    testWidgets('Reminder for checked activity does not show if signed off',
        (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      when(() => mockActivityDb.getAllBetween(any(), any())).thenAnswer(
        (_) => Future.value(
          [
            Activity.createNew(
              title: 'Reminder',
              startTime: activityWithAlarmTime.subtract(reminder),
              checkable: true,
              signedOffDates: [activityWithAlarmTime].map(whaleDateFormat),
            )
          ],
        ),
      );
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(PopAwareAlarmPage), findsNothing);
      expect(find.byType(ReminderPage), findsNothing);
    });

    testWidgets('Reminder for checked activity show from endtime',
        (WidgetTester tester) async {
      // Arrange
      final reminder = 15.minutes();
      final duration = 1.hours();
      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value([
                Activity.createNew(
                  title: 'Reminder',
                  startTime:
                      activityWithAlarmTime.subtract(reminder + duration),
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
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
      expect(find.byType(ReminderPage), findsOneWidget);
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
      expect(find.byType(PopAwareAlarmPage), findsNothing);
      // Act
      selectNotificationSubject.add(payload);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
      expect(find.byType(AlarmPage), findsOneWidget);
    });

    testWidgets('Alarms shows when notification selected before app start',
        (WidgetTester tester) async {
      // Act
      mockTicker.add(twoHoursAfter);
      selectNotificationSubject.add(payload);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
    });

    testWidgets('SGC-841 notications not rescheduled on app alarm start',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(App(payload: payload));
      await tester.pumpAndSettle();
      // Assert
      expect(alarmScheduleCalls, 0);
    });

    testWidgets('SGC-843 Alarm page Close button cancels alarm',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(App(payload: payload));
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
      expect(find.byType(AlarmPage), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      verify(() => notificationPlugin.cancel(payload.hashCode));
    });

    testWidgets('SGC-844 alarm does not open when app is paused',
        (WidgetTester tester) async {
      addTearDown(() => tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
      // Act
      await tester.pumpApp();
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      selectNotificationSubject.add(payload);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(PopAwareAlarmPage), findsNothing);
    });

    testWidgets('BUG SGC-380 NotificationSubject is cleared on logout',
        (WidgetTester tester) async {
      // Act
      mockTicker.add(twoHoursAfter);
      selectNotificationSubject.add(payload);
      await tester.pumpApp();
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
      expect(selectNotificationSubject, emits(payload));

      // Act logout
      await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(MenuButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.settings));
      await tester.pumpAndSettle();
      if (Config.isMP) {
        await tester.tap(find.byIcon(AbiliaIcons.technicalSettings));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byIcon(AbiliaIcons.powerOffOn));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(LogoutButton));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPage), findsOneWidget);

      expect(selectNotificationSubject.values, isEmpty);

      // Act Login
      await tester.ourEnterText(find.byType(PasswordInput), 'secretPassword');
      await tester.ourEnterText(find.byType(UsernameInput), Fakes.username);
      await tester.pump();
      await tester.tap(find.byType(LoginButton));
      await tester.pumpAndSettle();

      // Assert no NavigatableAlarmPage
      expect(find.byType(PopAwareAlarmPage), findsNothing);
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('Alarms can be checked when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      selectNotificationSubject.add(payload);
      await tester.pumpAndSettle();

      // Assert -- Alarm is on screen and alarm is checkable
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
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
      expect(find.byType(PopAwareAlarmPage), findsNothing);
    });

    testWidgets('Popup Alarms can be signed off', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Act -- alarm time happend
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();

      // Assert -- On screen alarm showing and check button showing
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.uncheckButton), findsNothing);

      // Act -- Tap the check button
      await tester.tap(find.byKey(TestKey.activityCheckButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();

      // Assert -- Check button not showing and uncheck button still not showing (only shown in activity bottom bar)
      expect(find.byType(PopAwareAlarmPage), findsNothing);
    });

    testWidgets(
        'SGC-1125 Signing off checkable activity cancels Unchecked reminders alarm',
        (WidgetTester tester) async {
      // Arrange -- alarm time happend
      final reminderUnchecked = uncheckedReminders(
        ActivityDay(activity, activityWithAlarmday),
      );
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();

      // Act -- Tap the check button
      await tester.tap(find.byKey(TestKey.activityCheckButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();

      // Assert -- All reminders canceled
      for (var reminder in reminderUnchecked) {
        verify(() => notificationPlugin.cancel(reminder.hashCode));
      }
    });

    testWidgets('Checkable Popup Alarm with checklist',
        (WidgetTester tester) async {
      // Arrange
      final startTime = DateTime(2021, 02, 16, 12, 00);
      final startDay = startTime.onlyDays();
      const unchecked = 'unchecked';
      final checkableActivityWithChecklist = Activity.createNew(
        title: 'checkableActivityWithChecklist',
        startTime: startTime,
        checkable: true,
        infoItem: Checklist(
          questions: const [
            Question(id: 0, name: 'checked'),
            Question(id: 1, name: unchecked),
          ],
          checked: {
            Checklist.dayKey(startDay): const {0}
          },
        ),
      );
      final checkableActivityPayload = StartAlarm(
        ActivityDay(
          checkableActivityWithChecklist,
          startDay,
        ),
      );

      selectNotificationSubject.add(checkableActivityPayload);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Act -- alarm time happend
      mockTicker.add(startTime);
      await tester.pumpAndSettle();

      // Assert -- On screen alarm showing, check button and checklist showing
      expect(find.byType(PopAwareAlarmPage), findsOneWidget);
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
      expect(find.byType(PopAwareAlarmPage), findsNothing);
    });
  });

  group('Multiple alarms tests', () {
    final activity1StartTime = DateTime(2011, 11, 11, 11, 11);
    final day = activity1StartTime.onlyDays();
    final activity1 = Activity.createNew(
        title: '111111', startTime: activity1StartTime, duration: 2.minutes());
    final startTimeActivity1NotificationPayload = StartAlarm(
      ActivityDay(
        activity1,
        day,
      ),
    );

    final activity2StartTime = activity1StartTime.add(1.minutes());
    final activity2 = Activity.createNew(
        title: '2222222', startTime: activity2StartTime, duration: 2.minutes());

    testWidgets('Start and end time alarm for same activity',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byType(PopAwareAlarmPage);

      // Act - time goes which should display start alarm
      mockTicker.add(activity1StartTime);
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

      // Act - time goes which should display end alarm
      mockTicker.add(activity1StartTime.add(const Duration(minutes: 2)));
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Start alarm is displayed on top if tapped on notification',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value([activity1]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byType(PopAwareAlarmPage);

      // Act - time goes which should display alarm
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(const Duration(minutes: 2)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      selectNotificationSubject.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      expect(alarmScreenFinder, findsOneWidget);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown since the start time alarm should have been moved to top
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Overlapping activities', (WidgetTester tester) async {
      // Arrange
      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value([activity1, activity2]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byType(PopAwareAlarmPage);

      // Act - time goes which should display alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(const Duration(minutes: 1)));
      mockTicker.add(activity1StartTime.add(const Duration(minutes: 2)));
      mockTicker.add(activity1StartTime.add(const Duration(minutes: 3)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      selectNotificationSubject.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm for activity1
      expect(alarmScreenFinder, findsOneWidget);
      final alarm = tester.widget<PopAwareAlarmPage>(alarmScreenFinder).alarm;
      expect(alarm, isA<ActivityAlarm>());
      expect(
        (alarm as ActivityAlarm).activityDay.activity.id,
        equals(activity1.id),
      );

      // Act - tap the ok button of the alarm
      await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm for activity 2
      expect(alarmScreenFinder, findsOneWidget);
      final alarm2 = tester.widget<PopAwareAlarmPage>(alarmScreenFinder).alarm;
      expect(alarm2, isA<ActivityAlarm>());
      expect(
        (alarm2 as ActivityAlarm).activityDay.activity.id,
        equals(activity2.id),
      );

      // Act - tap the alarm ok button
      await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Start alarm can show twice after close (BUG SGC-244)',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value([activity1]));
      final activity1Updated =
          activity1.copyWith(startTime: activity1StartTime.add(1.minutes()));
      final activity1UpdatedNotificationPayload = StartAlarm(
        ActivityDay(activity1Updated, day),
      );
      final pushCubit = PushCubit();
      await tester.pumpWidget(App(pushCubit: pushCubit));
      await tester.pumpAndSettle();
      final alarmScreenFinder = find.byType(PopAwareAlarmPage);

      // Act - time goes which should display alarm
      mockTicker.add(activity1StartTime);
      await tester.pumpAndSettle();

      // Expect - the alarm should now be the start time alarm for activity1
      expect(alarmScreenFinder, findsOneWidget);
      final alarm = tester.widget<PopAwareAlarmPage>(alarmScreenFinder).alarm;
      expect(alarm, isA<ActivityAlarm>());
      expect((alarm as ActivityAlarm).activityDay.activity.id,
          equals(activity1.id));

      // Act - tap the ok button of the alarm, no more alarm
      await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
      await tester.pumpAndSettle();
      expect(alarmScreenFinder, findsNothing);

      // Activity change forward one minute from backend and is pushed
      when(() => mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1Updated]));
      pushCubit.update('calendar');
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      selectNotificationSubject.add(
        activity1UpdatedNotificationPayload,
      );
      await tester.pumpAndSettle();

      // Expect - the alarm should be the start time alarm for activity 1
      expect(alarmScreenFinder, findsOneWidget);

      final alarm2 = tester.widget<PopAwareAlarmPage>(alarmScreenFinder).alarm;
      expect(alarm2, isA<ActivityAlarm>());
      expect(
        (alarm2 as ActivityAlarm).activityDay.activity.id,
        equals(activity1.id),
      );

      // Act - tap the alarm ok button
      await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
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
            alarmType: alarmSilent,
            checkable: true,
            duration: 1.minutes(),
            title: 'ALARM_SILENT'),
        Activity.createNew(
            startTime: start.add(4.minutes()),
            duration: 1.minutes(),
            checkable: true,
            alarmType: alarmVibration,
            title: 'ALARM_VIBRATION'),
        Activity.createNew(
            startTime: start.add(6.minutes()),
            checkable: true,
            duration: 1.minutes(),
            alarmType: alarmSoundOnlyOnStart,
            title: 'ALARM_SOUND_ONLY_ON_START'),
        Activity.createNew(
            startTime: start.add(8.minutes()),
            duration: 1.minutes(),
            checkable: true,
            alarmType: alarmSoundAndVibration,
            title: 'ALARM_SOUND_AND_VIBRATION'),
        Activity.createNew(
            startTime: start.add(10.minutes()),
            duration: 1.minutes(),
            reminderBefore: [1.minutes().inMilliseconds],
            alarmType: noAlarm,
            checkable: true,
            title: 'NO_ALARM'),
        Activity.createNew(
            startTime: start.add(11.minutes()),
            reminderBefore: [10.minutes().inMilliseconds],
            checkable: true,
            alarmType: alarmSilent,
            title: 'ALARM_SILENT reminder 10 min before'),
      ];

      when(() => mockActivityDb.getAllBetween(any(), any()))
          .thenAnswer((_) => Future.value(activities));

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Act - time goes for two hours
      for (var i = 0; i < 60 * 2; i++) {
        mockTicker.add(activity1StartTime.add(i.minutes()));
      }
      await tester.pumpAndSettle();

      // Expect - the alarm screens should be removed and only the latest reminders should show
      expect(find.byType(ReminderPage, skipOffstage: false),
          findsNWidgets(activities.length));
      expect(find.byType(AlarmPage, skipOffstage: false), findsNothing);
    });

    group('fullscreen alarms', () {
      testWidgets('Full screen shows', (WidgetTester tester) async {
        // Arrange
        final reminder = ReminderBefore(
            ActivityDay(
              Activity.createNew(
                  title: 'one reminder title', startTime: activity1StartTime),
              activity1StartTime.onlyDays(),
            ),
            reminder: 15.minutes());

        // Act
        await tester.pumpWidget(
          App(
            payload: reminder,
          ),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(PopAwareAlarmPage), findsOneWidget);
        expect(find.byType(ReminderPage), findsOneWidget);
        expect(find.text(reminder.activity.title), findsOneWidget);
      });

      testWidgets('Fullscreen alarms ignores same alarm ',
          (WidgetTester tester) async {
        final payload = ReminderBefore(
            ActivityDay(
              Activity.createNew(
                title: 'one reminder title',
                startTime: activity1StartTime,
              ),
              activity1StartTime.onlyDays(),
            ),
            reminder: 15.minutes());

        await tester.pumpWidget(
          App(
            payload: payload,
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(PopAwareAlarmPage, skipOffstage: false),
          findsOneWidget,
        );

        // Act
        selectNotificationSubject.add(payload);
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.byType(PopAwareAlarmPage, skipOffstage: false),
          findsOneWidget,
        );
        expect(
          find.text(payload.activity.title, skipOffstage: false),
          findsOneWidget,
        );
      });

      testWidgets('Fullscreen alarms stack ', (WidgetTester tester) async {
        // Arrange
        final reminder = ReminderBefore(
            ActivityDay(
              Activity.createNew(
                title: 'one reminder title',
                startTime: activity1StartTime,
              ),
              activity1StartTime.onlyDays(),
            ),
            reminder: 15.minutes());
        final alarm = StartAlarm(
          ActivityDay(
            Activity.createNew(
              title: 'one alarm title',
              startTime: activity1StartTime,
            ),
            activity1StartTime.onlyDays(),
          ),
        );

        // Act
        await tester.pumpWidget(
          App(
            payload: reminder,
          ),
        );
        await tester.pumpAndSettle();

        // Assert -- Fullscreen alarm shows
        expect(find.byType(PopAwareAlarmPage), findsOneWidget);
        expect(find.text(reminder.activity.title), findsOneWidget);

        // Act -- notification tapped
        selectNotificationSubject.add(alarm);
        await tester.pumpAndSettle();

        // Assert -- new alarm page
        expect(find.text(reminder.activity.title), findsNothing);
        expect(find.byType(PopAwareAlarmPage), findsOneWidget);
        expect(find.text(alarm.activity.title), findsOneWidget);

        // Act -- Close alarm page
        await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
        await tester.pumpAndSettle();

        // Assert -- first alarm page
        expect(find.byType(PopAwareAlarmPage), findsOneWidget);
        expect(find.text(reminder.activity.title), findsOneWidget);
      });

      testWidgets('multiple notifications at the same time ',
          (WidgetTester tester) async {
        final alarm1 = StartAlarm(
          ActivityDay(
            Activity.createNew(
              title: 'one alarm title',
              startTime: activity1StartTime,
            ),
            activity1StartTime.onlyDays(),
          ),
        );
        final alarm2 = StartAlarm(
          ActivityDay(
            Activity.createNew(
              title: 'two alarm title',
              startTime: activity1StartTime,
            ),
            activity1StartTime.onlyDays(),
          ),
        );
        final alarm3 = StartAlarm(
          ActivityDay(
            Activity.createNew(
              title: 'three alarm title',
              startTime: activity1StartTime,
            ),
            activity1StartTime.onlyDays(),
          ),
        );
        final alarm4 = StartAlarm(
          ActivityDay(
            Activity.createNew(
              title: 'four alarm title',
              startTime: activity1StartTime,
            ),
            activity1StartTime.onlyDays(),
          ),
        );

        // Arrange
        selectNotificationSubject.add(alarm2);
        selectNotificationSubject.add(alarm3);
        selectNotificationSubject.add(alarm4);

        await tester.pumpWidget(
          App(
            payload: alarm1,
          ),
        );
        await tester.pumpAndSettle();

        // Assert -- Fullscreen alarm shows
        expect(
          find.byType(AlarmPage, skipOffstage: false),
          findsNWidgets(4),
        );
        expect(
          find.byType(PopAwareAlarmPage, skipOffstage: false),
          findsNWidgets(4),
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

      testWidgets('fullscreen mixed with reminder and timer',
          (WidgetTester tester) async {
        final activity = Activity.createNew(
          title: 'Activity 1',
          startTime: activity1StartTime,
          duration: 2.minutes(),
        );
        final activity2 = Activity.createNew(
          startTime: activity1StartTime.add(5.minutes()).add(1.minutes()),
          reminderBefore: [5.minutes().inMilliseconds],
        );
        when(() => mockActivityDb.getAllNonDeleted())
            .thenAnswer((_) => Future.value([activity, activity2]));
        when(() => mockActivityDb.getAllBetween(any(), any()))
            .thenAnswer((_) => Future.value([activity, activity2]));

        when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
          (_) => Future.value(
            [
              Generic.createNew<MemoplannerSettingData>(
                data: MemoplannerSettingData.fromData(
                  data: true,
                  identifier: AlarmSettings.showOngoingActivityInFullScreenKey,
                ),
              ),
            ],
          ),
        );

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();

        mockTicker.add(activity1StartTime);
        await tester.pumpAndSettle();
        expect(find.byType(FullScreenActivityPage), findsOneWidget);

        mockTicker.add(activity1StartTime.add(1.minutes()));
        await tester.pumpAndSettle();
        expect(find.byType(ReminderPage), findsOneWidget);

        mockTicker.add(activity1StartTime.add(2.minutes()));
        await tester.pumpAndSettle();
        expect(find.byType(FullScreenActivityPage), findsOneWidget);

        selectNotificationSubject.add(TimerAlarm(AbiliaTimer.createNew(
            startTime: DateTime(2011, 11, 11, 11, 11), duration: 1.minutes())));
        await tester.pumpAndSettle();
        expect(find.byType(TimerAlarmPage), findsOneWidget);

        mockTicker.add(activity1StartTime.add(3.minutes()));
        await tester.pumpAndSettle();
        expect(find.byType(TimerAlarmPage), findsOneWidget);

        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        expect(find.byType(ReminderPage), findsOneWidget);

        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
      });
    });

    group('timer alarms', () {
      final timerStart = DateTime(2011, 11, 11, 11, 11);
      testWidgets('timer alarm is shown', (WidgetTester tester) async {
        final t =
            AbiliaTimer.createNew(startTime: timerStart, duration: 1.minutes());
        when(() => mockTimerDb.getAllTimers())
            .thenAnswer((_) => Future.value([t]));
        when(() => mockTimerDb.getRunningTimersFrom(any()))
            .thenAnswer((_) => Future.value([t]));

        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        selectNotificationSubject.add(TimerAlarm(t));
        await tester.pumpAndSettle();

        expect(find.byType(TimerAlarmPage), findsOneWidget);
      });
    });
  });
}
