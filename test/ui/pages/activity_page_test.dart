import 'dart:async';

import 'package:flutter/material.dart';
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

import '../../fakes/all.dart';
import '../../mocks/shared.mocks.dart';

import '../../test_helpers/enter_text.dart';
import '../../test_helpers/tts.dart';
import '../../test_helpers/verify_generic.dart';

void main() {
  late MockActivityDb mockActivityDb;
  late MockGenericDb mockGenericDb;

  final translate = Locales.language.values.first;
  final startTime = DateTime(2111, 11, 11, 11, 11);
  final tenDaysAgo = DateTime(2111, 11, 01, 11, 11);

  final activityBackButtonFinder = find.byKey(TestKey.activityBackButton);
  final activityCardFinder = find.byType(ActivityCard);
  final activityPageFinder = find.byType(ActivityPage);
  final agendaFinder = find.byType(Agenda);

  final editActivityButtonFinder = find.byIcon(AbiliaIcons.edit);
  final finishActivityFinder = find.byKey(TestKey.finishEditActivityButton);

  final alarmButtonFinder = find.byKey(TestKey.editAlarm);
  final alarmAtStartSwichFinder = find.byKey(TestKey.alarmAtStartSwitch);

  final okInkWellFinder = find.byKey(ObjectKey(TestKey.okDialog));
  final okButtonFinder = find.byType(OkButton);
  final cancelButtonFinder = find.byType(CancelButton);

  final deleteButtonFinder = find.byIcon(AbiliaIcons.delete_all_clear);
  final yesNoDialogFinder = find.byType(YesNoDialog);

  final checkButtonFinder = find.byKey(TestKey.activityCheckButton);
  final uncheckButtonFinder = find.byKey(TestKey.uncheckButton);
  final yesButtonFinder = find.byType(YesButton);
  final noButtonFinder = find.byType(NoButton);

  final activityInfoSideDotsFinder = find.byType(ActivityInfoSideDots);

  ActivityResponse activityResponse = () => [];

  setUp(() async {
    setupPermissions();
    setupFakeTts();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value(<DbActivity>[]));
    when(mockActivityDb.insertAndAddDirty(any))
        .thenAnswer((_) => Future.value(true));
    mockGenericDb = MockGenericDb();

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker(
          initialTime: startTime, stream: StreamController<DateTime>().stream)
      ..fireBasePushService = FakeFirebasePushService()
      ..client = Fakes.client(
        activityResponse: activityResponse,
        licenseResponse: () =>
            Fakes.licenseResponseExpires(startTime.add(5.days())),
      )
      ..fileStorage = FakeFileStorage()
      ..genericDb = mockGenericDb
      ..userFileDb = FakeUserFileDb()
      ..sortableDb = FakeSortableDb()
      ..syncDelay = SyncDelays.zero
      ..database = FakeDatabase()
      ..init();
  });

  tearDown(GetIt.I.reset);

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

    testWidgets('Full day activity page does not show edit alarm',
        (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.fullday(startTime)]));
      await navigateToActivityPage(tester);
      expect(alarmButtonFinder, findsNothing);
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
      await tester.enterText_(titleTextFormFieldFinder, newTitle);
      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      // Assert -- we are at activity page, the old title is not there, the new title is
      expect(find.text(title), findsNothing);
      expect(activityPageFinder, findsOneWidget);
      expect(find.text(newTitle), findsOneWidget);
    });

    testWidgets(
        'Change date in edit activity shows in activity page for non recurring activities',
        (WidgetTester tester) async {
      // Arrange
      final day = 14;
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
      await navigateToActivityPage(tester);

      expect(find.textContaining('11 November 2111'), findsOneWidget);
      final appBar = find.byType(CalendarAppBar);
      final theme = tester.widget<AnimatedTheme>(
          find.descendant(of: appBar, matching: find.byType(AnimatedTheme)));
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
          of: find.text('$day'), matching: find.byType(MonthDayView)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      final newTheme = tester.widget<AnimatedTheme>(
          find.descendant(of: appBar, matching: find.byType(AnimatedTheme)));

      expect(find.text('$day November 2111'), findsOneWidget);
      expect(
          theme.data.scaffoldBackgroundColor ==
              newTheme.data.scaffoldBackgroundColor,
          false);
    });

    testWidgets(
        'Change date in edit activity does not show in activity page for recurring activities',
        (WidgetTester tester) async {
      // Arrange
      final day = 14;
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
          Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
      await navigateToActivityPage(tester);

      expect(find.textContaining('11 November 2111'), findsOneWidget);
      await tester.tap(editActivityButtonFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
          of: find.text('$day'), matching: find.byType(MonthDayView)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      // original text still stands
      expect(find.textContaining('11 November 2111'), findsOneWidget);
      expect(find.text('$day November 2111'), findsNothing);
    });
  });

  group('Change alarm', () {
    final alarmDialogFinder = find.byType(SelectAlarmPage);
    final vibrationRadioButtonFinder =
        find.byKey(ObjectKey(AlarmType.Vibration));
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
      await tester.pumpAndSettle();
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

    testWidgets('Alarm button shows correct icon sound and vibration',
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
      await tester.pumpAndSettle();
      await tester.tap(vibrationRadioButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(noAlarmIconFinder, findsNothing);
      expect(vibrateAlarmIconFinder, findsOneWidget);
    });

    testWidgets('SGC-359 Alarm type maps Only alarm to SoundAndVibration',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
              title: 'null',
              startTime: startTime,
              alarmType: ALARM_SOUND,
            )
          ],
        ),
      );
      await navigateToActivityPage(tester);
      // Act
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      // Assert
      expect(alarmDialogFinder, findsOneWidget);

      final alarm = tester.widget<RadioField>(
        find.byKey(
          ObjectKey(AlarmType.SoundAndVibration),
        ),
      );

      expect(alarm.groupValue, AlarmType.SoundAndVibration);
    });

    testWidgets('SGC-359 Alarm type maps ALARM_SILENT to Silent',
        (WidgetTester tester) async {
      // Arrange
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
              title: 'null',
              startTime: startTime,
              alarmType: ALARM_SILENT,
            )
          ],
        ),
      );
      await navigateToActivityPage(tester);
      // Act
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();
      // Assert
      expect(alarmDialogFinder, findsOneWidget);

      final alarm = tester.widget<RadioField>(
        find.byKey(
          ObjectKey(AlarmType.Silent),
        ),
      );

      expect(alarm.groupValue, AlarmType.Silent);
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
      await tester.pumpAndSettle();

      // Assert -- alarm At Start Switch and ok button is disabled
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.alarmAtStartSwitch)))
              .onChanged,
          isNull);
      expect(tester.widget<OkButton>(okButtonFinder).onPressed, isNull);
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
      await tester.pumpAndSettle();
      await tester.tap(alarmAtStartSwichFinder);
      await tester.pumpAndSettle();

      // Assert -- ok button is enabled
      expect(tester.widget<OkButton>(okButtonFinder).onPressed, isNotNull);
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
      expect(yesNoDialogFinder, findsNothing);
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
      expect(yesNoDialogFinder, findsOneWidget);
      expect(yesButtonFinder, findsOneWidget);
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
      await tester.tap(noButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(deleteButtonFinder, findsOneWidget);
      expect(yesNoDialogFinder, findsNothing);
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
      await tester.tap(yesButtonFinder);
      await tester.pumpAndSettle();

      // Assert
      expect(deleteButtonFinder, findsNothing);
      expect(yesNoDialogFinder, findsNothing);
      expect(yesButtonFinder, findsNothing);
      expect(activityCardFinder, findsNothing);
      expect(activityPageFinder, findsNothing);
      expect(agendaFinder, findsOneWidget);
    });
  });
  group('Edit recurring', () {
    final editRecurrentFinder = find.byType(SelectRecurrentTypePage);
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
        await tester.tap(yesButtonFinder);
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
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(cancelButtonFinder);
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
        await tester.tap(yesButtonFinder);
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
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 =
            tester.widget<AbiliaRadio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<AbiliaRadio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<AbiliaRadio>(thisDayAndForwardRadioFinder);

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
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(allDaysRadioFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 =
            tester.widget<AbiliaRadio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<AbiliaRadio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<AbiliaRadio>(thisDayAndForwardRadioFinder);

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
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(thisDayAndForwardRadioFinder);
        await tester.pumpAndSettle();

        final onlyThisDayRadio1 =
            tester.widget<AbiliaRadio>(onlyThisDayRadioFinder);
        final allDaysRadio1 = tester.widget<AbiliaRadio>(allDaysRadioFinder);
        final thisDayAndForwardRadio1 =
            tester.widget<AbiliaRadio>(thisDayAndForwardRadioFinder);

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
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(deleteButtonFinder, findsNothing);
        expect(yesNoDialogFinder, findsNothing);
        expect(okButtonFinder, findsNothing);
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
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
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
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(allDaysRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
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
        await tester.tap(yesButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(thisDayAndForwardRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
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
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(editRecurrentFinder, findsOneWidget);
      });
    });

    group('Edit recurring Activity', () {
      final titleTextFormFieldFinder =
          find.byKey(TestKey.editTitleTextFormField);
      testWidgets('Edit an recurring should show Apply to dialog when edited',
          (WidgetTester tester) async {
        // Arrange
        when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
            Future.value(<Activity>[FakeActivity.reocurrsEveryDay(startTime)]));
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.enterText_(
            find.byKey(TestKey.editTitleTextFormField), 'new title');
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
        await tester.enterText_(titleTextFormFieldFinder, newTitle);
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(newTitle), findsOneWidget);
      });

      testWidgets(
          'Correct day in datepicker shows in edit activity when edit recurring activity',
          (WidgetTester tester) async {
        // Arrange
        final activity = Activity.createNew(
          title: 'title',
          startTime: startTime.subtract(100.days()),
          recurs: Recurs.weeklyOnDays([1, 2, 3, 4, 5, 6, 7]),
        );
        when(mockActivityDb.getAllNonDeleted())
            .thenAnswer((_) => Future.value(<Activity>[activity]));
        await navigateToActivityPage(tester);

        // Act -- tap the edit activity button
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();

        // Assert -- edit activity date is same as picked day
        expect(find.byType(EditActivityPage), findsOneWidget);
        final datePickerDate =
            tester.widget<DatePicker>(find.byType(DatePicker)).date;
        expect(datePickerDate.onlyDays(), startTime.onlyDays());
      });

      testWidgets('No edit on recurring activity does not show apply to pop up',
          (WidgetTester tester) async {
        // Arrange
        final activity = Activity.createNew(
          title: 'title',
          startTime: startTime.subtract(100.days()),
          recurs: Recurs.weeklyOnDays([1, 2, 3, 4, 5, 6, 7]),
        );
        when(mockActivityDb.getAllNonDeleted())
            .thenAnswer((_) => Future.value(<Activity>[activity]));
        await navigateToActivityPage(tester);

        // Act -- tap the edit activity button
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();

        // Assert -- we are back on activity page
        expect(activityPageFinder, findsOneWidget);
      });

      testWidgets('Edit an recurring This day and forward shows changes',
          (WidgetTester tester) async {
        // Arrange
        final newTitle = 'new Title', oldTitle = 'old title';
        when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(
            <Activity>[
              Activity.createNew(
                title: oldTitle,
                startTime: startTime.subtract(100.days()),
                recurs: Recurs.weeklyOnDays([1, 2, 3, 4, 5, 6, 7]),
              )
            ],
          ),
        );
        await navigateToActivityPage(tester);

        // Act
        await tester.tap(editActivityButtonFinder);
        await tester.pumpAndSettle();
        await tester.enterText_(titleTextFormFieldFinder, newTitle);
        await tester.tap(finishActivityFinder);
        await tester.pumpAndSettle();
        await tester.tap(thisDayAndForwardRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(okButtonFinder);
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

  testWidgets('Check and uncheck activity with confirmation',
      (WidgetTester tester) async {
    when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value(
        <Activity>[FakeActivity.starts(startTime).copyWith(checkable: true)]));
    await navigateToActivityPage(tester);
    expect(checkButtonFinder, findsOneWidget);
    expect(uncheckButtonFinder, findsNothing);
    await tester.tap(checkButtonFinder);
    await tester.pumpAndSettle();

    expect(noButtonFinder, findsOneWidget);
    await tester.tap(noButtonFinder);
    await tester.pumpAndSettle();

    expect(checkButtonFinder, findsOneWidget);
    expect(uncheckButtonFinder, findsNothing);

    await tester.tap(checkButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(yesButtonFinder);
    await tester.pumpAndSettle();

    expect(checkButtonFinder, findsNothing);
    expect(uncheckButtonFinder, findsOneWidget);

    await tester.tap(uncheckButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(yesButtonFinder);
    await tester.pumpAndSettle();

    expect(checkButtonFinder, findsOneWidget);
    expect(uncheckButtonFinder, findsNothing);
  });

  group('Memoplanner settings', () {
    testWidgets('Do not display delete button when setting is false',
        (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
      when(mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          <Generic>[
            memoplannerSetting(
                false, MemoplannerSettings.displayDeleteButtonKey)
          ],
        ),
      );
      await navigateToActivityPage(tester);
      expect(deleteButtonFinder, findsNothing);
      expect(editActivityButtonFinder, findsOneWidget);
      expect(alarmButtonFinder, findsOneWidget);
    });

    testWidgets('Do not display any button when all settings are false',
        (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
      when(mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          <Generic>[
            memoplannerSetting(
                false, MemoplannerSettings.displayDeleteButtonKey),
            memoplannerSetting(
                false, MemoplannerSettings.displayAlarmButtonKey),
            memoplannerSetting(false, MemoplannerSettings.displayEditButtonKey),
          ],
        ),
      );
      await navigateToActivityPage(tester);
      expect(deleteButtonFinder, findsNothing);
      expect(editActivityButtonFinder, findsNothing);
      expect(alarmButtonFinder, findsNothing);
    });

    testWidgets('Do not display side dots when setting is false',
        (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
          (_) => Future.value(<Activity>[FakeActivity.starts(startTime)]));
      when(mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (_) => Future.value(
          <Generic>[
            memoplannerSetting(
                false, MemoplannerSettings.displayQuarterHourKey),
          ],
        ),
      );
      await navigateToActivityPage(tester);
      expect(activityInfoSideDotsFinder, findsNothing);
    });
  });
  group('tts', () {
    testWidgets('heading', (WidgetTester tester) async {
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
          Future.value(<Activity>[
            Activity.createNew(title: 'title', startTime: startTime)
          ]));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byType(AppBar), contains: 'Wednesday');
    });

    testWidgets('title', (WidgetTester tester) async {
      final title = 'generic title';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) => Future.value(
          <Activity>[Activity.createNew(title: title, startTime: startTime)]));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.text(title), exact: title);
    });

    testWidgets('start time', (WidgetTester tester) async {
      final expectedTts = '11:11 AM';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer((_) =>
          Future.value(<Activity>[
            Activity.createNew(title: 'title', startTime: startTime)
          ]));

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byKey(TestKey.startTime), exact: expectedTts);
    });

    testWidgets('end time', (WidgetTester tester) async {
      final expectedTts = '3:11 PM';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
                title: 'title',
                startTime: startTime.add(2.hours()),
                duration: 2.hours())
          ],
        ),
      );

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byKey(TestKey.endTime), exact: expectedTts);
    });

    testWidgets('note', (WidgetTester tester) async {
      final noteText =
          '''Ceasarsallad - Kyckling, bacon, sallad, gurka, tomat, rödlök, brödkrutonger, Grana Padano samt ceasardressing ((G), (L))
Asien sweet and SourBowl – Sesam marinerad kycklingfile, plocksallad, picklade morötter, risnudlar, sojabönor toppas med rostade sesamfrön och koriander, chili och apelsindressing
Asien sweet and SourBowl vegetarian – marinerad tofu, plocksallad, picklade morötter, risnudlar, sojabönor toppas med rostade sesamfrön och koriander, chili och apelsindressing
''';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
                title: 'title',
                startTime: startTime,
                infoItem: NoteInfoItem(noteText))
          ],
        ),
      );

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byType(NoteBlock), exact: noteText);
    });

    testWidgets('checklist', (WidgetTester tester) async {
      final item1 = 'first thing on the list';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
              title: 'title',
              startTime: startTime,
              infoItem: Checklist(questions: [Question(id: 1, name: item1)]),
            )
          ],
        ),
      );

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byType(QuestionView), exact: item1);
    });

    testWidgets('timepillar left to start', (WidgetTester tester) async {
      final expectedTts = '2 h\n2 min';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
                title: 'title',
                startTime: startTime.add(2.hours() + 2.minutes()),
                duration: 2.hours())
          ],
        ),
      );

      await navigateToActivityPage(tester);
      await tester.verifyTts(find.byKey(TestKey.sideDotsTimeText),
          contains: expectedTts);
    });

    testWidgets('check button', (WidgetTester tester) async {
      final title = 'just some title';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
                title: title, startTime: startTime, checkable: true),
          ],
        ),
      );
      await navigateToActivityPage(tester);
      expect(checkButtonFinder, findsOneWidget);
      expect(uncheckButtonFinder, findsNothing);
      await tester.verifyTts(checkButtonFinder, exact: translate.check);
      await tester.tap(checkButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(yesButtonFinder);
      await tester.pumpAndSettle();
      expect(uncheckButtonFinder, findsOneWidget);
    });

    testWidgets('delete activity', (WidgetTester tester) async {
      final title = 'just some title';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
                title: title, startTime: startTime, checkable: true),
          ],
        ),
      );

      await navigateToActivityPage(tester);
      await tester.tap(deleteButtonFinder);
      await tester.pumpAndSettle();
      await tester.verifyTts(find.text(translate.remove),
          exact: translate.remove);
      await tester.verifyTts(find.text(translate.deleteActivity),
          exact: translate.deleteActivity);
    });

    testWidgets('alarms', (WidgetTester tester) async {
      final title = 'just some title';
      when(mockActivityDb.getAllNonDeleted()).thenAnswer(
        (_) => Future.value(
          <Activity>[
            Activity.createNew(
              title: title,
              startTime: startTime,
              checkable: true,
              alarmType: ALARM_VIBRATION,
            ),
          ],
        ),
      );

      await navigateToActivityPage(tester);
      // Act -- tap reminder button
      await tester.tap(alarmButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- tts
      await tester.verifyTts(
        find.byKey(ObjectKey(AlarmType.SoundAndVibration)),
        exact: translate.alarmAndVibration,
      );
      await tester.verifyTts(
        find.byKey(ObjectKey(AlarmType.Vibration)),
        exact: translate.vibration,
      );
      await tester.verifyTts(
        find.byIcon(AbiliaIcons.handi_no_alarm_vibration),
        exact: translate.noAlarm,
      );

      await tester.verifyTts(
        find.byKey(TestKey.alarmAtStartSwitch),
        exact: translate.alarmOnlyAtStartTime,
      );
    });
  });
}
