import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  MockActivityDb mockActivityDb;
  StreamController<DateTime> mockTicker;

  final locale = Locale('en');
  final translate = Translator(locale).translate;
  final startTime = DateTime(2111, 11, 11, 11, 11);
  final tenDaysAgo = DateTime(2111, 11, 01, 11, 11);

  final activityBackButtonFinder = find.byKey(TestKey.activityBackButton);
  final selectReminderDialogFinder = find.byType(SelectReminderDialog);
  final activityCardFinder = find.byType(ActivityCard);
  final activityPageFinder = find.byType(ActivityPage);
  final agendaFinder = find.byType(Agenda);

  final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
  final finishActivityFinder = find.byKey(TestKey.finishEditActivityButton);

  final alarmButtonFinder = find.byKey(TestKey.editAlarm);
  final alarmAtStartSwichFinder = find.byKey(TestKey.alarmAtStartSwitch);
  final reminderButtonFinder = find.byKey(TestKey.editReminder);
  final reminderSwitchFinder = find.byType(ReminderSwitch);

  final okInkWellFinder = find.byKey(ObjectKey(TestKey.okDialog));
  final closeButtonFinder = find.byKey(TestKey.closeDialog);

  final deleteButtonFinder = find.byIcon(AbiliaIcons.delete_all_clear);
  final deleteViewDialogFinder = find.byType(DeleteActivityDialog);

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
    when(mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value(<DbActivity>[]));
    GetItInitializer()
      ..activityDb = mockActivityDb
      ..userDb = MockUserDb()
      ..ticker = Ticker(initialTime: startTime, stream: mockTicker.stream)
      ..baseUrlDb = MockBaseUrlDb()
      ..fireBasePushService = mockFirebasePushService
      ..tokenDb = mockTokenDb
      ..httpClient = Fakes.client(activityResponse)
      ..fileStorage = MockFileStorage()
      ..settingsDb = MockSettingsDb()
      ..syncDelay = SyncDelays.zero
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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
      await navigateToActivityPage(tester);
      expect(activityBackButtonFinder, findsOneWidget);
      await tester.tap(activityBackButtonFinder);
      await tester.pumpAndSettle();
      expect(activityCardFinder, findsOneWidget);
    });

    testWidgets('Full day activity page does not show edit alarm or reminders',
        (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.fullday(startTime)]));
      await navigateToActivityPage(tester);
      expect(alarmButtonFinder, findsNothing);
      expect(reminderButtonFinder, findsNothing);
    });
  });

  group('Edit activity', () {
    final editActivityPageFinder = find.byType(EditActivityPage);
    final titleTextFormFieldFinder = find.byKey(TestKey.editTitleTextFormField);
    testWidgets('Edit activity button shows', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
      // Act
      await navigateToActivityPage(tester);
      // Assert -- Find the edit activity button
      expect(editActivityButtonFinder, findsOneWidget);
    });

    testWidgets('Can open edit activity page', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
          <Activity>[FakeActivity.starts(startTime).copyWith(title: title)]));
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
          <Activity>[FakeActivity.starts(startTime).copyWith(title: title)]));
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
    final alarmDialogFinder = find.byType(SelectAlarmDialog);
    final vibrationRadioButtonFinder = find.byKey(TestKey.vibrationAlarm);
    final noAlarmIconFinder = find.byIcon(AbiliaIcons.handi_no_alarm_vibration);
    final vibrateAlarmIconFinder = find.byIcon(AbiliaIcons.handi_vibration);
    final soundVibrateAlarmIconFinder =
        find.byIcon(AbiliaIcons.handi_alarm_vibration);

    testWidgets('Alarm view dialog shows', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
            FakeActivity.starts(startTime).copyWith(alarmType: ALARM_VIBRATION)
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
                FakeActivity.starts(startTime).copyWith(
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
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
          Future.value(<Activity>[
            FakeActivity.starts(startTime).copyWith(alarmType: NO_ALARM)
          ]));
      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(noAlarmIconFinder, findsOneWidget);
    });

    testWidgets('Alarm button changes alarm correct icon',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
          Future.value(<Activity>[
            FakeActivity.starts(startTime).copyWith(alarmType: NO_ALARM)
          ]));
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
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
          Future.value(<Activity>[
            FakeActivity.starts(startTime).copyWith(alarmType: NO_ALARM)
          ]));

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
                FakeActivity.starts(startTime).copyWith(
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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
      // Act
      await navigateToActivityPage(tester);
      // Assert
      expect(reminderButtonFinder, findsOneWidget);
    });

    testWidgets('Reminder alarm shows', (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
                FakeActivity.starts(startTime).copyWith(reminderBefore: [
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
                FakeActivity.starts(startTime).copyWith(reminderBefore: [
                  5.minutes().inMilliseconds,
                  15.minutes().inMilliseconds,
                  1.hours().inMilliseconds,
                  1.days().inMilliseconds,
                ])
              ]));

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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));

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
  group('Delete activity', () {
    testWidgets('Finds delete button and no delete app bar',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
      // Act
      await navigateToActivityPage(tester);

      // Assert
      expect(deleteButtonFinder, findsOneWidget);
      expect(deleteViewDialogFinder, findsNothing);
      expect(okInkWellFinder, findsNothing);
    });

    testWidgets('When delete button pressed Delete Activity Dialog is showing',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
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
  group('Edit recurring', () {
    final editRecurrentFinder = find.byType(EditRecurrentDialog);
    final onlyThisDayRadioFinder = find.byKey(ObjectKey(TestKey.onlyThisDay));
    final allDaysRadioFinder = find.byKey(ObjectKey(TestKey.allDays));
    final thisDayAndForwardRadioFinder =
        find.byKey(ObjectKey(TestKey.thisDayAndForward));

    group('Delete recurring', () {
      testWidgets('Deleting recurring should show apply to dialog',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(editRecurrentFinder, findsOneWidget);
      });

      testWidgets(
          'Does not delete activity when not pressing confirm on recurring delete dialog',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();
        await tester.tap(closeButtonFinder);
        await tester.pumpAndSettle();

        // Assert -- Still on activity page
        expect(activityPageFinder, findsOneWidget);
      });

      testWidgets(
          'When delete recurring activity then show three alternativs for deletion',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(onlyThisDayRadioFinder, findsOneWidget);
        expect(allDaysRadioFinder, findsOneWidget);
        expect(thisDayAndForwardRadioFinder, findsOneWidget);
      });

      testWidgets('When delete recurring the choosen alternativ is onlyThisDay',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 = tester.widget<Radio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<Radio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<Radio>(thisDayAndForwardRadioFinder);

        // Assert
        expect(onlyThisDayRadio1.value, ApplyTo.onlyThisDay);
        expect(allDaysRadio1.value, ApplyTo.allDays);
        expect(thisDayAndForwardRadio1.value, ApplyTo.thisDayAndForward);

        expect(onlyThisDayRadio1.groupValue, ApplyTo.onlyThisDay);
        expect(allDaysRadio1.groupValue, ApplyTo.onlyThisDay);
        expect(thisDayAndForwardRadio1.groupValue, ApplyTo.onlyThisDay);
      });

      testWidgets('When delete recurring tapping All days',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();
        await tester.tap(allDaysRadioFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 = tester.widget<Radio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<Radio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<Radio>(thisDayAndForwardRadioFinder);

        // Assert
        expect(onlyThisDayRadio1.groupValue, ApplyTo.allDays);
        expect(allDaysRadio1.groupValue, ApplyTo.allDays);
        expect(thisDayAndForwardRadio1.groupValue, ApplyTo.allDays);
      });

      testWidgets('When delete recurring tapping This day and forward',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();
        await tester.tap(thisDayAndForwardRadioFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 = tester.widget<Radio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<Radio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<Radio>(thisDayAndForwardRadioFinder);

        // Assert
        expect(onlyThisDayRadio1.groupValue, ApplyTo.thisDayAndForward);
        expect(allDaysRadio1.groupValue, ApplyTo.thisDayAndForward);
        expect(thisDayAndForwardRadio1.groupValue, ApplyTo.thisDayAndForward);
      });

      testWidgets(
          'When delete recurring and confirm Only this day, navigate back and do not show origial widget',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
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

      final goToNextPageFinder = find.byIcon(AbiliaIcons.go_to_next_page);
      final goToPreviusPageFinder =
          find.byIcon(AbiliaIcons.return_to_previous_page);
      testWidgets(
          'When delete recurring and confirm Only this day, go to next day and previus day shows activity card',
          (WidgetTester tester) async {
        // Arrange
        final title = 'Unique title to search for';
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[
              FakeActivity.reocurrsEveryDay(tenDaysAgo).copyWith(title: title)
            ]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityCardFinder, findsOneWidget);
        expect(find.text(title), findsOneWidget);

        // Act -- to to yesterday
        await tester.tap(goToPreviusPageFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToPreviusPageFinder);
        await tester.pumpAndSettle();

        expect(activityCardFinder, findsOneWidget);
        expect(find.text(title), findsOneWidget);
      });

      testWidgets(
          'When delete recurring a confirm all days, go to previus day and next day shows no activity card',
          (WidgetTester tester) async {
        // Arrange
        final title = 'Unique title to search for';
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[
              FakeActivity.reocurrsEveryDay(startTime).copyWith(title: title)
            ]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();
        await tester.tap(allDaysRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToPreviusPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityCardFinder, findsNothing);
        expect(find.text(title), findsNothing);

        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityCardFinder, findsNothing);
        expect(find.text(title), findsNothing);
      });

      testWidgets(
          'When delete recurring and confirming This day and forward, this day and next day does not shows activity card but previus day does',
          (WidgetTester tester) async {
        // Arrange
        final title = 'Unique title to search for';
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[
              FakeActivity.reocurrsEveryDay(tenDaysAgo).copyWith(title: title)
            ]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(deleteButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();
        await tester.tap(thisDayAndForwardRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityCardFinder, findsNothing);
        expect(find.text(title), findsNothing);

        // Act -- go to yesterday
        await tester.tap(goToPreviusPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityCardFinder, findsOneWidget);
        expect(find.text(title), findsOneWidget);

        // Act -- go to tomorrow
        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();
        await tester.tap(goToNextPageFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(activityCardFinder, findsNothing);
        expect(find.text(title), findsNothing);
      });
    });

    group('Edit recurring alarm', () {
      testWidgets('Changing alarm on recurring should show apply to dialog',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(alarmButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(alarmAtStartSwichFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(editRecurrentFinder, findsOneWidget);
      });
    });

    group('Edit recurring reminder', () {
      testWidgets('Changing reminder on recurring should show apply to dialog',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(reminderButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(reminderSwitchFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(editRecurrentFinder, findsOneWidget);
      });
    });
    group('Edit recurring Activity', () {
      final titleTextFormFieldFinder =
          find.byKey(TestKey.editTitleTextFormField);
      testWidgets('Edit an recurring should show Apply to dialog',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(editRecurrentFinder, findsOneWidget);
      });

      testWidgets('Edit an recurring Only this days shows changes',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);
        final newTitle = 'newTitle';

        // Act
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.enterText(titleTextFormFieldFinder, newTitle);
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();
        await tester.tap(okInkWellFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(newTitle), findsOneWidget);
      });
    });
  });

  testWidgets('Checklist attachment can be signed off',
      (WidgetTester tester) async {
    final tag = 'tag';
    final activity = Activity.createNew(
        title: 'title',
        startTime: startTime,
        infoItem: Checklist(questions: [
          Question(id: 0, name: tag),
          Question(id: 1, name: 'another'),
        ]));

    // Arrange
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(<Activity>[activity]));
    await navigateToActivityPage(tester);

    // Assert no checklist item is checked
    tester.widgetList(find.byType(QuestionView)).forEach((element) {
      if (element is QuestionView) {
        expect(element.signedOff, isFalse);
      }
    });

    // Act tap question "tag"
    await tester.tap(find.text(tag));
    await tester.pumpAndSettle();

    // Assert "tag" is checked
    final allQuestionViews = tester.widgetList(find.byType(QuestionView));
    expect(allQuestionViews, hasLength(2));
    allQuestionViews.forEach((element) {
      if (element is QuestionView) {
        if (element.question.name == tag) {
          expect(element.signedOff, isTrue);
        } else {
          expect(element.signedOff, isFalse);
        }
      }
    });
  });
}
