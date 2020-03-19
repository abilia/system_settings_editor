import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  group('calendar page widget test', () {
    MockActivityDb mockActivityDb;
    StreamController<DateTime> mockTicker;
    ActivityResponse activityResponse = () => [];

    setUp(() {
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
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = (() => mockTicker.stream)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(activityResponse)
        ..init();
    });

    testWidgets('Application starts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(CalendarPage), findsOneWidget);
    });

    testWidgets('Should show up empty', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);
    });

    testWidgets('Should show one activity', (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));

      activityResponse = () => [FakeActivity.startsIn(1.hours())];

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });

    testWidgets('Empty agenda should not show Go to now-button',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets('Agenda with one activity should not show Go to now-button',
        (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));

      activityResponse = () => [FakeActivity.startsNow()];

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });

    testWidgets(
        'Agenda with one activity and a lot of passed activities should show the activity',
        (WidgetTester tester) async {
      final key = 'KEYKEYKEYKEYKEY';
      final activities = FakeActivities.allPast
        ..add(FakeActivity.startsNow().copyWith(title: key));
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(activities));

      activityResponse = () => activities;

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
      expect(find.text(key), findsOneWidget);
    });
  });

  group('calendar page alarms test', () {
    StreamController<DateTime> mockTicker;
    StreamController<String> mockNotificationSelected;
    final DateTime activityWithAlarmTime = DateTime(2011, 11, 11, 11, 11);
    final DateTime activityWithAlarmday = activityWithAlarmTime.onlyDays();
    final DateTime twoHoursAfter = activityWithAlarmTime.add(2.hours());
    final Activity activity =
        FakeActivity.starts(activityWithAlarmTime).copyWith(checkable: true);
    final String payloadSerial = json.encode(NotificationPayload(
      activityId: activity.id,
      day: activityWithAlarmday,
      onStart: true,
    ).toJson());

    setUp(() {
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      mockTicker = StreamController<DateTime>();
      mockNotificationSelected = StreamController<String>();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));

      final response = [activity];
      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(response));

      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = (() => mockTicker.stream)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(() => response)
        ..notificationStreamGetter = (() => mockNotificationSelected.stream)
        ..init();
    });

    testWidgets('Alarms shows', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    });

    testWidgets('Alarms shows when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Assert
      expect(find.byKey(TestKey.onScreenAlarm), findsNothing);
      // Act
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    });

    testWidgets('Alarms shows when notification selected before app start',
        (WidgetTester tester) async {
      // Act
      mockTicker.add(twoHoursAfter);
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
    });

    testWidgets('Alarms can be checked when notification selected',
        (WidgetTester tester) async {
      // Arrange
      mockTicker.add(twoHoursAfter);
      await tester.pumpWidget(App());
      mockNotificationSelected.add(payloadSerial);
      await tester.pumpAndSettle();

      // Assert -- Alarm is on screen and alarm is checkable
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityUncheckButton), findsNothing);

      // Act -- Tap the check button
      await tester.tap(find.byKey(TestKey.activityCheckButton));
      await tester.pumpAndSettle();

      // Assert -- Alarm is checked
      expect(find.byKey(TestKey.activityUncheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsNothing);

      // Act -- Tap the uncheck button
      await tester.tap(find.byKey(TestKey.activityUncheckButton));
      await tester.pumpAndSettle();

      // Assert -- Alarm is unchecked again
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityUncheckButton), findsNothing);
    });

    testWidgets('Popup Alarms can be signed off', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      // Act -- alarm time happend
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();

      // Assert -- On screen alarm showing and check button showing
      expect(find.byKey(TestKey.onScreenAlarm), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityUncheckButton), findsNothing);

      // Act -- Tap the check button
      await tester.tap(find.byKey(TestKey.activityCheckButton));
      await tester.pumpAndSettle();

      // Assert -- Check button not showing and uncheck button showing
      expect(find.byKey(TestKey.activityUncheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityCheckButton), findsNothing);

      // Act -- Tap the uncheck button
      await tester.tap(find.byKey(TestKey.activityUncheckButton));
      await tester.pumpAndSettle();

      // Assert -- Check button showing and uncheck not showing
      expect(find.byKey(TestKey.activityCheckButton), findsOneWidget);
      expect(find.byKey(TestKey.activityUncheckButton), findsNothing);
    });
  });

  group('calendar page reminder test', () {
    StreamController<DateTime> mockTicker;
    StreamController<String> mockNotificationSelected;
    final activityWithAlarmTime = DateTime(2011, 11, 11, 11, 11);
    final reminderTime = 5.minutes();
    final activity =
        FakeActivity.starts(activityWithAlarmTime.add(reminderTime))
            .copyWith(reminderBefore: [reminderTime.inMilliseconds]);

    setUp(() {
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      mockTicker = StreamController<DateTime>();
      mockNotificationSelected = StreamController<String>();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));

      final response = [activity];
      final mockActivityDb = MockActivityDb();
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(response));

      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = (() => mockTicker.stream)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(() => response)
        ..notificationStreamGetter = (() => mockNotificationSelected.stream)
        ..init();
    });

    testWidgets('Reminder shows', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      // Act
      mockTicker.add(activityWithAlarmTime);
      await tester.pumpAndSettle();
      // Assert
      expect(find.byKey(TestKey.onScreenReminder), findsOneWidget);
    });
  });

  group('Multiple alarms tests', () {
    final mockActivityDb = MockActivityDb();
    StreamController<DateTime> mockTicker;
    StreamController<String> mockNotificationSelected;
    final DateTime activity1StartTime = DateTime(2011, 11, 11, 11, 11);
    final DateTime day = DateTime(2011, 11, 11);
    final Activity activity1 =
        FakeActivity.starts(activity1StartTime, duration: 2.minutes());
    final String startTimeActivity1NotificationPayload =
        json.encode(NotificationPayload(
      activityId: activity1.id,
      day: day,
      onStart: true,
    ).toJson());

    final DateTime activity2StartTime = DateTime(2011, 11, 11, 11, 12);
    final Activity activity2 =
        FakeActivity.starts(activity2StartTime, duration: 2.minutes());

    setUp(() {
      mockTicker = StreamController<DateTime>();
      mockNotificationSelected = StreamController<String>();
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

      final mockTokenDb = MockTokenDb();
      when(mockTokenDb.getToken()).thenAnswer((_) => Future.value(Fakes.token));
      final mockFirebasePushService = MockFirebasePushService();
      when(mockFirebasePushService.initPushToken())
          .thenAnswer((_) => Future.value('fakeToken'));

      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = (() => mockTicker.stream)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(() => [])
        ..notificationStreamGetter = (() => mockNotificationSelected.stream)
        ..init();
    });

    testWidgets('Start and end time alarm for same activity',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final Finder alarmScreenFinder = find.byKey(TestKey.onScreenAlarm);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - no more alarms is displayed
      expect(alarmScreenFinder, findsNothing);
    });

    testWidgets('Start alarm is displayed on top if tapped on notification',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value([activity1]));
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      final Finder alarmScreenFinder = find.byKey(TestKey.onScreenAlarm);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      mockNotificationSelected.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
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
      final Finder alarmScreenFinder = find.byKey(TestKey.onScreenAlarm);

      // Act - time goes which should display two alarms (start and end time)
      mockTicker.add(activity1StartTime);
      mockTicker.add(activity1StartTime.add(Duration(minutes: 1)));
      mockTicker.add(activity1StartTime.add(Duration(minutes: 2)));
      mockTicker.add(activity1StartTime.add(Duration(minutes: 3)));
      await tester.pumpAndSettle();

      // Act - the user taps notification of start time alarm
      mockNotificationSelected.add(startTimeActivity1NotificationPayload);
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should now be the start time alarm for activity1
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);
      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity1.id));

      // Act - tap the ok button of the alarm
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm for activity 2
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);
      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity2.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the end time alarm for activity 1
      expect((tester.widget(alarmScreenFinder) as AlarmPage).atEndTime, isTrue);
      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity1.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - the top/latest alarm should be the start time alarm for activity 2
      expect(
          (tester.widget(alarmScreenFinder) as AlarmPage).atStartTime, isTrue);
      expect((tester.widget(alarmScreenFinder) as AlarmPage).activity.id,
          equals(activity2.id));

      // Act - tap the alarm ok button
      await tester.tap(find.byKey(TestKey.appBarCloseButton));
      await tester.pumpAndSettle();

      // Expect - no more alarms should be shown
      expect(alarmScreenFinder, findsNothing);
    });
  });
  group('calendar page add new activity widget test', () {
    MockActivityDb mockActivityDb;
    StreamController<DateTime> mockTicker;
    ActivityResponse activityResponse = () => [];

    setUp(() {
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
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = (() => mockTicker.stream)
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(activityResponse)
        ..init();
    });
    testWidgets('New activity', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addActivity));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
    });
  });

  group('edit all day', () {
    final title1 = 'fulldaytitle1';
    final title2 = 'fullday title 2';
    final title3 = 'full day title 3';
    DateTime date = DateTime(1994, 04, 04, 04, 04);

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
      MockActivityDb mockActivityDb = MockActivityDb();
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(fullDayActivities));
      GetItInitializer()
        ..activityDb = mockActivityDb
        ..userDb = MockUserDb()
        ..ticker = (() => StreamController<DateTime>().stream)
        ..startTime = date
        ..baseUrlDb = MockBaseUrlDb()
        ..fireBasePushService = mockFirebasePushService
        ..tokenDb = mockTokenDb
        ..httpClient = Fakes.client(() => fullDayActivities)
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
      await tester.enterText(editTitleFieldFinder, newTitle);
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
      await tester.enterText(editTitleFieldFinder, newTitle);
      await tester.tap(saveEditActivityButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(activityBackButtonFinder);
      await tester.pumpAndSettle();

      expect(day1Finder, findsOneWidget);
      expect(day2Finder, findsOneWidget);
      expect(cardFinder, findsNWidgets(3));
      expect(day3Finder, findsNothing, skip: 'bug SGC-18');
      expect(find.text(newTitle), findsOneWidget, skip: 'bug SGC-18');
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
