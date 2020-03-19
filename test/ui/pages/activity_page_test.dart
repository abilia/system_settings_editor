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
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  MockActivityDb mockActivityDb;
  StreamController<DateTime> mockTicker;

  final locale = Locale('en');
  final translate = Translator(locale).translate;

  final activityBackButtonFinder = find.byKey(TestKey.activityBackButton);
  final selectReminderDialogFinder = find.byType(SelectReminderDialog);
  final activityCardFinder = find.byType(ActivityCard);
  final activityPageFinder = find.byType(ActivityPage);
  final agendaFinder = find.byType(Agenda);

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
    await tester.tap(activityCardFinder);
    await tester.pumpAndSettle();
  }

  group('Activity page', () {
    testWidgets('Navigate to activity page and back',
        (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);
      expect(activityBackButtonFinder, findsOneWidget);
      await tester.tap(activityBackButtonFinder);
      await tester.pumpAndSettle();
      expect(activityCardFinder, findsOneWidget);
    });
  });

  group('Edit activity', () {
    final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
    final editActivityPageFinder = find.byType(EditActivityPage);
    final titleTextFormFieldFinder = find.byKey(TestKey.editTitleTextFormField);
    final finishActivityFinder = find.byKey(TestKey.finishEditActivityButton);
    testWidgets('Edit activity button shows', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      // Act
      await navigateToActivityPage(tester);
      // Assert -- Find the edit activity button
      expect(editActivityButtonFinder, findsOneWidget);
    });

    testWidgets('Can open edit activity page', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);
      // Act -- tap the edit activity button
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();
      // Assert -- edit activity shows
      expect(editActivityPageFinder, findsOneWidget);
    });

    testWidgets('Correct activity shows in edit activity',
        (WidgetTester tester) async {
      // Arrange
      final title = 'an interesting title';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value(
          <Activity>[FakeActivity.startsNow().copyWith(title: title)]));
      await navigateToActivityPage(tester);

      // Act -- tap the edit activity button
      expect(find.text(title), findsOneWidget);
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- edit activity title is same as aticity title
      expect(editActivityPageFinder, findsOneWidget);
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('Changes in edit activity shows in activity page',
        (WidgetTester tester) async {
      // Arrange
      final title = 'an interesting title';
      final newTitle = 'an new super interesting title';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value(
          <Activity>[FakeActivity.startsNow().copyWith(title: title)]));
      await navigateToActivityPage(tester);

      // Assert -- original title
      expect(find.text(title), findsOneWidget);

      // Act -- tap edit acvtivity button
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- that the old title is there
      expect(titleTextFormFieldFinder, findsOneWidget);
      expect(find.text(title), findsOneWidget);

      // Act -- Enter new title and save
      await tester.enterText(titleTextFormFieldFinder, newTitle);
      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      // Assert -- we are at activity page, the old title is not there, the new title is
      expect(find.text(title), findsNothing);
      expect(activityPageFinder, findsOneWidget);
      expect(find.text(newTitle), findsOneWidget);
    });
  });

  group('Change alarm', () {
    final alarmButtonFinder = find.byKey(TestKey.editAlarm);
    final alarmDialogFinder = find.byType(SelectAlarmDialog);
    final vibrationRadioButtonFinder = find.byKey(TestKey.vibrationAlarm);
    final noAlarmIconFinder = find.byIcon(AbiliaIcons.handi_no_alarm_vibration);
    final vibrateAlarmIconFinder = find.byIcon(AbiliaIcons.handi_vibration);
    final soundVibrateAlarmIconFinder =
        find.byIcon(AbiliaIcons.handi_alarm_vibration);
    final alarmAtStartSwichFinder = find.byKey(TestKey.alarmAtStartSwitch);

    testWidgets('Alarm view dialog shows', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      await navigateToActivityPage(tester);
      // Act
      await tester.tap(alarmButtonFinder);
      await tester.pump();
      // Assert
      expect(alarmDialogFinder, findsOneWidget);
    });

    testWidgets('Alarm button shows correct icon vibration',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
          Future.value(<Activity>[
            FakeActivity.startsNow().copyWith(alarmType: ALARM_VIBRATION)
          ]));
      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(vibrateAlarmIconFinder, findsOneWidget);
    });
    testWidgets('Alarm button shows correct icon sound and vibratio',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(<Activity>[
                FakeActivity.startsNow().copyWith(
                    alarmType: ALARM_SOUND_AND_VIBRATION_ONLY_ON_START)
              ]));
      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(soundVibrateAlarmIconFinder, findsOneWidget);
    });
    testWidgets('Alarm button shows correct icon no alarm',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value(
          <Activity>[FakeActivity.startsNow().copyWith(alarmType: NO_ALARM)]));
      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(noAlarmIconFinder, findsOneWidget);
    });

    testWidgets('Alarm button changes alarm correct icon',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value(
          <Activity>[FakeActivity.startsNow().copyWith(alarmType: NO_ALARM)]));
      // Act
      await navigateToActivityPage(tester);
      await tester.tap(alarmButtonFinder);
      await tester.pump();
      await tester.tap(vibrationRadioButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(okInkWellFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(noAlarmIconFinder, findsNothing);
      expect(vibrateAlarmIconFinder, findsOneWidget);
    });

    testWidgets('Alarm on start time is disabled when no alarm',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value(
          <Activity>[FakeActivity.startsNow().copyWith(alarmType: NO_ALARM)]));

      // Act
      await navigateToActivityPage(tester);
      await tester.tap(alarmButtonFinder);
      await tester.pump();

      // Assert -- alarm At Start Switch and ok button is disabled
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.alarmAtStartSwitch)))
              .onChanged,
          isNull);
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNull);
    });

    testWidgets('Alarm on start time changes', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(<Activity>[
                FakeActivity.startsNow().copyWith(
                    alarmType: ALARM_SOUND_AND_VIBRATION_ONLY_ON_START)
              ]));

      // Act
      await navigateToActivityPage(tester);
      await tester.tap(alarmButtonFinder);
      await tester.pump();
      await tester.tap(alarmAtStartSwichFinder);
      await tester.pumpAndSettle();

      // Assert -- ok button is enabled
      expect(tester.widget<InkWell>(okInkWellFinder).onTap, isNotNull);
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
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(reminderButtonFinder, findsOneWidget);
    });

    testWidgets('Reminder alarm shows', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
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
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
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
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
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
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
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
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
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
      when(mockActivityDb.getAllNonDeleted())
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
      when(mockActivityDb.getAllNonDeleted())
          .thenAnswer((_) => Future.value(<Activity>[
                FakeActivity.startsNow().copyWith(reminderBefore: [
                  5.minutes().inMilliseconds,
                  15.minutes().inMilliseconds,
                  1.hours().inMilliseconds,
                  1.days().inMilliseconds,
                ])
              ]));
      when(mockActivityDb.getAllDirty())
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
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
      when(mockActivityDb.getAllDirty())
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

    group('Delete', () {
      final deleteButtonFinder = find.byIcon(AbiliaIcons.delete_all_clear);
      final deleteViewDialogFinder = find.byType(DeleteActivityDialog);

      testWidgets('Finds delete button and no delete app bar',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer(
            (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
        // Act
        await navigateToActivityPage(tester);

        // Assert
        expect(deleteButtonFinder, findsOneWidget);
        expect(deleteViewDialogFinder, findsNothing);
        expect(okInkWellFinder, findsNothing);
      });

      testWidgets(
          'When delete button pressed Delete Activity Dialog is showing',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer(
            (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(deleteViewDialogFinder, findsOneWidget);
        expect(okInkWellFinder, findsOneWidget);
        expect(find.byType(ActivityCard), findsOneWidget);
      });

      testWidgets('When cancel pressed, nothing happens',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer(
            (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(closeButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(deleteButtonFinder, findsOneWidget);
        expect(deleteViewDialogFinder, findsNothing);
        expect(okInkWellFinder, findsNothing);
      });

      testWidgets(
          'When delete then confirm delete pressed, navigate back and do not show origial widget',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer(
            (_) => Future.value(<Activity>[FakeActivity.startsNow()]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(deleteButtonFinder, findsNothing);
        expect(deleteViewDialogFinder, findsNothing);
        expect(okInkWellFinder, findsNothing);
        expect(activityCardFinder, findsNothing);
        expect(activityPageFinder, findsNothing);
        expect(agendaFinder, findsOneWidget);
      });
    });
  });
}
