import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  MockActivityDb mockActivityDb;
  StreamController<DateTime> mockTicker;

  final locale = Locale('en');
  final translate = Translator(locale).translate;

  final activityBackButtonFinder = find.byKey(TestKey.activityBackButton);
  final selectReminderDialogFinder = find.byType(SelectReminderDialog);

  final okInkWellFinder = find.byKey(ObjectKey(TestKey.okDialog));
  final closeButtonFinder = find.byKey(TestKey.closeDialog);
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
  Future<void> navigateToActivityPage(WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(ActivityCard));
    await tester.pumpAndSettle();
  }

  group('Activity page test', () {
    testWidgets('Navigate to activity page and back',
        (WidgetTester tester) async {
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);
      expect(activityBackButtonFinder, findsOneWidget);
      await tester.tap(activityBackButtonFinder);
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });
  });

  group('Change reminder', () {
    final reminderButtonFinder = find.byKey(TestKey.editReminder);
    final reminderSwitchFinder = find.byType(ReminderSwitch);

    final reminder5MinFinder =
        find.text(5.minutes().toReminderString(translate));
    final reminderDayFinder = find.text(1.days().toReminderString(translate));
    final remindersAllSelected =
        find.byIcon(AbiliaIcons.radiocheckbox_selected);
    final reminderField = find.byType(Reminders);
    final remindersAll = find.byType(SelectableField);
    testWidgets('Reminder button shows', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(reminderButtonFinder, findsOneWidget);
    });

    testWidgets('Reminder alarm shows', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);

      // Act -- tap reminder button
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- finds reminder dialog
      expect(selectReminderDialogFinder, findsOneWidget);
      //  reminder switch shows
      expect(reminderSwitchFinder, findsOneWidget);
      // reminder field show
      expect(reminderField, findsOneWidget);
      // no reminders selected
      expect(remindersAllSelected, findsNothing);
      // 6 reminders shows
      expect(remindersAll, findsNWidgets(6));
      // close button shows
      expect(closeButtonFinder, findsOneWidget);
      // ok button is disabled
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNull);
    });
    testWidgets('Tapping reminder switch adds 15 min alarm',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Act
      await tester.tap(reminderSwitchFinder);
      await tester.pumpAndSettle();

      // Assert
      // one reminders selected
      expect(remindersAllSelected, findsOneWidget);
      // ok button is enabled
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNotNull);
    });

    testWidgets(
        'Tapping reminder switch adds 15 min alarm, tapping it again deselects',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Act -- tap reminders switch
      await tester.tap(reminderSwitchFinder);
      await tester.pumpAndSettle();

      // Assert -- one reminder selected
      expect(remindersAllSelected, findsOneWidget);
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNotNull);

      // Act -- tap reminders switch
      await tester.tap(reminderSwitchFinder);
      await tester.pumpAndSettle();

      // Assert -- no reminders selected
      expect(remindersAllSelected, findsNothing);
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNull);
    });

    testWidgets('Tapping reminder switch and two alarms shows three alarms',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();
      // Act
      await tester.tap(reminderSwitchFinder);
      await tester.tap(reminder5MinFinder);
      await tester.tap(reminderDayFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(remindersAllSelected, findsNWidgets(3));
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNotNull);
    });

    testWidgets('Alarms are not saved if close is pressed',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Act -- select three reminders, then tap close, then tap reminder button
      await tester.tap(reminderSwitchFinder);
      await tester.tap(reminder5MinFinder);
      await tester.tap(reminderDayFinder);
      await tester.pumpAndSettle();
      await tester.tap(closeButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(selectReminderDialogFinder, findsOneWidget);
      expect(remindersAllSelected, findsNothing);
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
      expect(reminderSwitchFinder, findsOneWidget);
      expect(closeButtonFinder, findsOneWidget);
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNull);
    });

    testWidgets('Activity that already has reminders shows',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[
                FakeActivity.startsNow().copyWith(reminderBefore: [
                  5.minutes().inMilliseconds,
                  15.minutes().inMilliseconds,
                  1.hours().inMilliseconds,
                  1.days().inMilliseconds,
                ])
              ]));
      await navigateToActivityPage(tester);
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Act -- select three reminders, then tap close, then tap reminder button
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(selectReminderDialogFinder, findsOneWidget);
      expect(remindersAllSelected, findsNWidgets(4));
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
      expect(reminderSwitchFinder, findsOneWidget);
      expect(closeButtonFinder, findsOneWidget);
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNull);
    });
    testWidgets(
        'Activity that already has reminders where deselected are saved shows',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb())
          .thenAnswer((_) => Future.value(<Activity>[
                FakeActivity.startsNow().copyWith(reminderBefore: [
                  5.minutes().inMilliseconds,
                  15.minutes().inMilliseconds,
                  1.hours().inMilliseconds,
                  1.days().inMilliseconds,
                ])
              ]));
      when(mockActivityDb.getDirtyActivities())
          .thenAnswer((_) => Future.value(<DbActivity>[]));
      await navigateToActivityPage(tester);
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Act -- deselect one reminder, then tap ok, then tap reminder button
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(reminder5MinFinder);
      await tester.pumpAndSettle();
      await tester.tap(okInkWellFinder);
      await tester.pumpAndSettle();
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- three reminders are selected
      expect(selectReminderDialogFinder, findsOneWidget);
      expect(remindersAllSelected, findsNWidgets(3));
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
      expect(reminderSwitchFinder, findsOneWidget);
      expect(closeButtonFinder, findsOneWidget);
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNull);
    });
    testWidgets('Reminders can be saved', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getActivitiesFromDb()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      when(mockActivityDb.getDirtyActivities())
          .thenAnswer((_) => Future.value(<DbActivity>[]));
      await navigateToActivityPage(tester);
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Act -- select one reminder, then tap ok, then tap reminder button
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(reminder5MinFinder);
      await tester.pumpAndSettle();
      await tester.tap(okInkWellFinder);
      await tester.pumpAndSettle();
      await tester.tap(reminderButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- one reminder is selected
      expect(selectReminderDialogFinder, findsOneWidget);
      expect(remindersAllSelected, findsOneWidget);
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
      expect(reminderSwitchFinder, findsOneWidget);
      expect(closeButtonFinder, findsOneWidget);
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNull);
    });
  });
}
