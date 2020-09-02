import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../mocks.dart';

void main() {
  final startTime = DateTime(2020, 02, 25, 15, 30);
  final today = startTime.onlyDays();
  final startActivity = Activity.createNew(
    title: '',
    startTime: startTime,
  );
  final translate = Locales.language.values.first;

  final startTimeFieldFinder = find.byKey(TestKey.startTimePicker);
  final endTimeFieldFinder = find.byKey(TestKey.endTimePicker);
  final okFinder = find.byKey(TestKey.okDialog);

  MockSortableBloc mockSortableBloc;
  MockUserFileBloc mockUserFileBloc;
  setUp(() async {
    await initializeDateFormatting();
    mockSortableBloc = MockSortableBloc();
    mockUserFileBloc = MockUserFileBloc();
  });

  Widget wrapWithMaterialApp(Widget widget,
      {Activity givenActivity, bool use24H = false, bool newActivity = false}) {
    final activity = givenActivity ?? startActivity;
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale.languageCode,
              orElse: () => supportedLocales.first),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24H),
          child: MultiBlocProvider(providers: [
            BlocProvider<AuthenticationBloc>(
                create: (context) => MockAuthenticationBloc()),
            BlocProvider<ActivitiesBloc>(
                create: (context) => MockActivitiesBloc()),
            BlocProvider<EditActivityBloc>(
              create: (context) => newActivity
                  ? EditActivityBloc.newActivity(
                      activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
                      day: today)
                  : EditActivityBloc(
                      ActivityDay(activity, today),
                      activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
                    ),
            ),
            BlocProvider<SortableBloc>(
              create: (context) => mockSortableBloc,
            ),
            BlocProvider<UserFileBloc>(
              create: (context) => mockUserFileBloc,
            ),
            BlocProvider<ClockBloc>(
              create: (context) => ClockBloc(
                  StreamController<DateTime>().stream,
                  initialTime: startTime),
            ),
          ], child: child)),
      home: widget,
    );
  }

  Type typeOf<T>() => T;

  group('edit activity test', () {
    testWidgets('New activity shows', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
    });

    testWidgets('TabBar shows', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.byType(AbiliaTabBar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.my_photos), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.attention), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.repeat), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.attachment), findsOneWidget);
    });

    testWidgets('Can switch tabs', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.byType(MainTab), findsOneWidget);
      await tester.goToAlarmTab();
      expect(find.byType(AlarmAndReminderTab), findsOneWidget);
      await tester.goToMainTab();
      expect(find.byType(MainTab), findsOneWidget);
    });

    testWidgets('Scroll to end of page', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.byType(AvailibleForWidget), findsNothing);
      await tester.scrollDown();
      expect(find.byType(AvailibleForWidget), findsOneWidget);
    });

    testWidgets('Can enter text', (WidgetTester tester) async {
      final newActivtyTitle = 'activity title';
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.text(newActivtyTitle), findsNothing);
      await tester.enterText_(
          find.byKey(TestKey.editTitleTextFormField), newActivtyTitle);
      expect(find.text(newActivtyTitle), findsOneWidget);
    });

    testWidgets('Select picture dialog shows', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addPicture));
      await tester.pumpAndSettle();
      expect(find.byType(SelectPictureDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.closeDialog));
      await tester.pumpAndSettle();
      expect(find.byType(SelectPictureDialog), findsNothing);
    });

    testWidgets(
        'pressing add activity button with no title nor time shows error',
        (WidgetTester tester) async {
      final submitButtonFinder = find.byKey(TestKey.finishEditActivityButton);

      // Act press submit
      await tester.pumpWidget(
          wrapWithMaterialApp(EditActivityPage(day: today), newActivity: true));
      await tester.pumpAndSettle();

      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Assert error message
      expect(
          find.text(translate.missingTitleOrImageAndStartTime), findsOneWidget);
      // Act dissmiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      // Assert no error message
      expect(
          find.text(translate.missingTitleOrImageAndStartTime), findsNothing);
    });

    testWidgets('pressing add activity button with time shows error',
        (WidgetTester tester) async {
      final newActivtyName = 'new activity name';
      final submitButtonFinder = find.byKey(TestKey.finishEditActivityButton);

      // Act press submit
      await tester.pumpWidget(
          wrapWithMaterialApp(EditActivityPage(day: today), newActivity: true));
      await tester.pumpAndSettle();

      // Act enter title
      await tester.enterText_(
          find.byKey(TestKey.editTitleTextFormField), newActivtyName);
      await tester.pumpAndSettle();

      // Act press submit
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Assert error message
      expect(find.text(translate.missingStartTime), findsOneWidget);
      // Act dissmiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      // Assert no error message
      expect(find.text(translate.missingStartTime), findsNothing);
    });

    testWidgets('pressing add activity button with no title shows error',
        (WidgetTester tester) async {
      final submitButtonFinder = find.byKey(TestKey.finishEditActivityButton);

      await tester.pumpWidget(
          wrapWithMaterialApp(EditActivityPage(day: today), newActivity: true));
      await tester.pumpAndSettle();
      // Act press fullday
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();

      // Act press submit
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Assert error message
      expect(find.text(translate.missingTitleOrImage), findsOneWidget);
      // Act dissmiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();
      // Assert no error message
      expect(find.text(translate.missingTitleOrImage), findsNothing);
    });

    testWidgets('pressing add activity on other tab scrolls back to main page',
        (WidgetTester tester) async {
      final submitButtonFinder = find.byKey(TestKey.finishEditActivityButton);

      await tester.pumpWidget(
          wrapWithMaterialApp(EditActivityPage(day: today), newActivity: true));
      await tester.pumpAndSettle();

      // Act go to tab
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();
      // Assert not at main tab
      expect(find.byType(MainTab), findsNothing);

      // Act press submit
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Assert error message
      expect(
          find.text(translate.missingTitleOrImageAndStartTime), findsOneWidget);

      // Act dissmiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Assert at main tab
      expect(find.byType(MainTab), findsOneWidget);
    });

    testWidgets('full day switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      // Assert -- Fullday switch is off
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isFalse);
      // Assert -- Start time, left and rigth category visible
      expect(startTimeFieldFinder, findsOneWidget);
      expect(find.byKey(TestKey.leftCategoryRadio), findsOneWidget);
      expect(find.byKey(TestKey.rightCategoryRadio), findsOneWidget);

      // Assert -- can see Alarm tab
      expect(find.byIcon(AbiliaIcons.attention), findsOneWidget);
      await tester.goToAlarmTab();
      // Assert -- alarm tab contains reminders
      expect(find.byIcon(AbiliaIcons.handi_reminder), findsOneWidget);
      await tester.goToMainTab();

      // Act -- set to full day
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();

      // Assert -- Fullday switch is on,
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isTrue);
      // Assert -- Start time, left and rigth category not visible
      expect(startTimeFieldFinder, findsNothing);
      expect(find.byKey(TestKey.leftCategoryRadio), findsNothing);
      expect(find.byKey(TestKey.rightCategoryRadio), findsNothing);
      // Assert -- Alarm tab not visible
      expect(find.byIcon(AbiliaIcons.attention), findsNothing);
    });

    testWidgets('alarm at start switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.alarmAtStartSwitch)))
              .value,
          isFalse);
      expect(find.byKey(TestKey.alarmAtStartSwitch), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.alarmAtStartSwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.alarmAtStartSwitch)))
              .value,
          isTrue);
    });

    testWidgets('Select alarm dialog', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      expect(find.byKey(TestKey.selectAlarm), findsOneWidget);
      expect(find.text(translate.vibration), findsNothing);
      expect(find.byIcon(AbiliaIcons.handi_vibration), findsNothing);
      await tester.tap(find.byKey(TestKey.selectAlarm));
      await tester.pumpAndSettle();
      expect(find.byType(SelectAlarmTypeDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.vibrationAlarm));
      await tester.pumpAndSettle();
      expect(find.text(translate.vibration), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.handi_vibration), findsOneWidget);
    });

    testWidgets('checkable switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.scrollDown();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.checkableSwitch)))
              .value,
          isFalse);
      expect(find.byKey(TestKey.checkableSwitch), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.checkableSwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.checkableSwitch)))
              .value,
          isTrue);
    });

    testWidgets('delete after switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.scrollDown();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.deleteAfterSwitch)))
              .value,
          isFalse);
      expect(find.byKey(TestKey.deleteAfterSwitch), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.deleteAfterSwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.deleteAfterSwitch)))
              .value,
          isTrue);
    });

    testWidgets('Date picker', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.text('(Today) February 25, 2020'), findsOneWidget);

      await tester.tap(find.byKey(TestKey.datePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('14'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('(Today) February 25, 2020'), findsNothing);
      expect(find.text('February 14, 2020'), findsOneWidget);
    });

    testWidgets('Category picker', (WidgetTester tester) async {
      final rightRadioKey = ObjectKey(TestKey.rightCategoryRadio);
      final leftRadioKey = ObjectKey(TestKey.leftCategoryRadio);
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      final leftCategoryRadio1 =
          tester.widget<AbiliaRadio>(find.byKey(leftRadioKey));
      final rightCategoryRadio1 =
          tester.widget<AbiliaRadio>(find.byKey(rightRadioKey));

      expect(leftCategoryRadio1.value, Category.left);
      expect(rightCategoryRadio1.value, Category.right);
      expect(leftCategoryRadio1.groupValue, Category.right);
      expect(rightCategoryRadio1.groupValue, Category.right);

      await tester.scrollDown(dy: -100);
      await tester.tap(find.byKey(TestKey.leftCategoryRadio));
      await tester.pumpAndSettle();
      final leftCategoryRadio2 =
          tester.widget<AbiliaRadio>(find.byKey(leftRadioKey));
      final rightCategoryRadio2 =
          tester.widget<AbiliaRadio>(find.byKey(rightRadioKey));

      expect(leftCategoryRadio2.groupValue, Category.left);
      expect(rightCategoryRadio2.groupValue, Category.left);

      await tester.tap(find.byKey(TestKey.rightCategoryRadio));
      await tester.pumpAndSettle();
      final leftCategoryRadio3 =
          tester.widget<AbiliaRadio>(find.byKey(leftRadioKey));
      final rightCategoryRadio3 =
          tester.widget<AbiliaRadio>(find.byKey(rightRadioKey));

      expect(leftCategoryRadio3.groupValue, Category.right);
      expect(rightCategoryRadio3.groupValue, Category.right);
    });

    testWidgets('Availible for dialog', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.scrollDown();
      await tester.pumpAndSettle();

      expect(find.byKey(TestKey.availibleFor), findsOneWidget);
      expect(find.text(translate.onlyMe), findsNothing);
      expect(find.byIcon(AbiliaIcons.password_protection), findsNothing);
      await tester.tap(find.byKey(TestKey.availibleFor));
      await tester.pumpAndSettle();
      expect(find.byType(SelectAvailableForDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.onlyMe));
      await tester.pumpAndSettle();
      expect(find.text(translate.onlyMe), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.password_protection), findsOneWidget);
    });

    testWidgets('Reminder', (WidgetTester tester) async {
      // Arrange
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      final reminderSwitchFinder = find.byIcon(AbiliaIcons.handi_reminder);
      final reminder15MinFinder =
          find.text(15.minutes().toReminderString(translate));
      final reminderDayFinder = find.text(1.days().toReminderString(translate));
      final remindersAllSelected =
          find.byIcon(AbiliaIcons.radiocheckbox_selected);
      final remindersAll = find.byType(SelectableField);
      final reminderField = find.byType(Reminders);

      // Act -- Go to alarm tab
      await tester.goToAlarmTab();

      // Assert -- reminder switch is visible but reminders field is collapsed
      expect(reminderSwitchFinder, findsOneWidget);
      expect(remindersAll, findsNothing);
      expect(reminderField, findsNothing);

      // Act -- tap reminder switch
      await tester.tap(reminderSwitchFinder);
      await tester.pumpAndSettle();
      // Assert -- 15 min reminder is selected, all reminders shows
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
      expect(reminder15MinFinder, findsOneWidget);
      expect(remindersAllSelected, findsOneWidget);

      // Act -- tap on day reminder
      await tester.scrollDown(dy: -100);
      await tester.tap(reminderDayFinder);
      await tester.pumpAndSettle();
      // Assert -- 15 min and 1 day reminder is selected, all reminders shows
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
      expect(reminder15MinFinder, findsOneWidget);
      expect(reminderDayFinder, findsOneWidget);
      expect(remindersAllSelected, findsNWidgets(2));

      // Act -- tap reminder switch
      await tester.tap(reminderSwitchFinder);
      await tester.pumpAndSettle();
      // Assert -- no reminders shows, is collapsed
      expect(reminderField, findsNothing);
      expect(remindersAll, findsNothing);
      expect(reminder15MinFinder, findsNothing);
      expect(reminderDayFinder, findsNothing);
      expect(remindersAllSelected, findsNothing);

      // Act -- tap reminder switch then day reminder
      await tester.tap(reminderSwitchFinder);
      await tester.pumpAndSettle();
      await tester.tap(reminderDayFinder);
      await tester.pumpAndSettle();
      // Assert -- 15 min and 1 day reminder is selected, all reminders shows
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
      expect(reminder15MinFinder, findsOneWidget);
      expect(reminderDayFinder, findsOneWidget);
      expect(remindersAllSelected, findsNWidgets(2));

      // Act -- tap 15 min and day reminder
      await tester.tap(reminder15MinFinder);
      await tester.tap(reminderDayFinder);
      await tester.pumpAndSettle();
      // Assert -- no reminders shows, is collapsed
      expect(reminderField, findsNothing);
      expect(remindersAll, findsNothing);
      expect(reminder15MinFinder, findsNothing);
      expect(reminderDayFinder, findsNothing);
      expect(remindersAllSelected, findsNothing);
    });
  });

  group('edit info item', () {
    testWidgets('all info item present', (WidgetTester tester) async {
      final activity = Activity.createNew(title: 'null', startTime: startTime);
      await tester.pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today),
          givenActivity: activity));
      await tester.pumpAndSettle();
      await tester.goToInfoItemTab();

      expect(find.byType(InfoItemTab), findsOneWidget);
      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      expect(find.byType(SelectInfoTypeDialog), findsOneWidget);
      expect(find.byKey(TestKey.infoItemNoneRadio), findsOneWidget);
      expect(find.byKey(TestKey.infoItemChecklistRadio), findsOneWidget);
      expect(find.byKey(TestKey.infoItemNoteRadio), findsOneWidget);
    });

    testWidgets('Change beweeen info items preserves old info item state',
        (WidgetTester tester) async {
      final q1 = 'q1', q2 = 'q2', q3 = 'q3', noteText = 'noteText';
      final activity = Activity.createNew(
          title: 'null',
          startTime: startTime,
          infoItem: Checklist(questions: [
            Question(name: q1),
            Question(name: q3),
            Question(name: q2)
          ]));
      await tester.pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today),
          givenActivity: activity));
      await tester.pumpAndSettle();
      await tester.goToInfoItemTab();

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
      await tester.pumpAndSettle();

      await tester.enterText_(find.byType(NoteBlock), noteText);
      await tester.pumpAndSettle();

      expect(find.text(noteText), findsOneWidget);

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemChecklistRadio));
      await tester.pumpAndSettle();

      expect(find.text(q1), findsOneWidget);
      expect(find.text(q2), findsOneWidget);
      expect(find.text(q3), findsOneWidget);

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemNoneRadio));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
      await tester.pumpAndSettle();

      expect(find.text(noteText), findsOneWidget);
    });

    group('note', () {
      Future goToNote(WidgetTester tester) async {
        await tester.goToInfoItemTab();

        await tester.tap(find.byKey(TestKey.changeInfoItem));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
        await tester.pumpAndSettle();
      }

      testWidgets('Info item shows', (WidgetTester tester) async {
        final aLongNote = '''
This is a note
I am typing for testing
that it is visible in the info item tab
''';
        final activity = Activity.createNew(
            title: 'null',
            startTime: startTime,
            infoItem: NoteInfoItem(aLongNote));
        await tester.pumpWidget(wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: activity));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(aLongNote), findsOneWidget);
      });

      testWidgets('Info item note not deleted when to info item note',
          (WidgetTester tester) async {
        final aLongNote = '''
This is a note
I am typing for testing
that it is visible in the info item tab
''';
        final activity = Activity.createNew(
            title: 'null',
            startTime: startTime,
            infoItem: NoteInfoItem(aLongNote));
        await tester.pumpWidget(wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: activity));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(aLongNote), findsOneWidget);
        await tester.tap(find.byIcon(AbiliaIcons.edit));
        await tester.pumpAndSettle();
        expect(find.byType(SelectInfoTypeDialog), findsOneWidget);
        expect(find.byKey(TestKey.infoItemNoneRadio), findsOneWidget);
        expect(find.byKey(TestKey.infoItemChecklistRadio), findsOneWidget);
        expect(find.byKey(TestKey.infoItemNoteRadio), findsOneWidget);

        await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
        await tester.pumpAndSettle();
        expect(find.byType(SelectInfoTypeDialog), findsNothing);
        expect(find.text(aLongNote), findsOneWidget);
      });

      testWidgets('Info item note can be selected',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        await tester.tap(find.byKey(TestKey.changeInfoItem));
        await tester.pumpAndSettle();

        expect(find.byType(SelectInfoTypeDialog), findsOneWidget);

        await tester.tap(find.byKey(TestKey.infoItemNoteRadio));

        await tester.pumpAndSettle();
        expect(find.byType(SelectInfoTypeDialog), findsNothing);
        expect(find.text(translate.infoType), findsOneWidget);
        expect(find.text(translate.infoTypeNote), findsOneWidget);
        expect(find.text(translate.typeSomething), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.edit), findsOneWidget);
      });

      testWidgets('Info item note opens EditNoteDialog',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToNote(tester);

        await tester.tap(find.byType(NoteBlock));
        await tester.pumpAndSettle();

        expect(find.byType(EditNoteDialog), findsOneWidget);
      });

      testWidgets('Info item note can be edited', (WidgetTester tester) async {
        final noteText = '''4.1.1
Mark the unexported and accidentally public setDefaultResponse as deprecated.
Mark the not useful, and not generally used, named function as deprecated.
Produce a meaningful error message if an argument matcher is used outside of stubbing (when) or verification (verify and untilCalled).
4.1.0 
Add a Fake class for implementing a subset of a class API as overrides without misusing the Mock class.
4.0.0 
Replace the dependency on the test package with a dependency on the new test_api package. This dramatically reduces mockito's transitive dependencies.

This bump can result in runtime errors when coupled with a version of the test package older than 1.4.0.

3.0.2 
Rollback the test_api part of the 3.0.1 release. This was breaking tests that use Flutter's current test tools, and will instead be released as part of Mockito 4.0.0.
3.0.1 
Replace the dependency on the test package with a dependency on the new test_api package. This dramatically reduces mockito's transitive dependencies.
Internal improvements to tests and examples.''';
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToNote(tester);

        await tester.enterText_(find.byType(NoteBlock), noteText);
        await tester.pumpAndSettle();

        expect(find.text(noteText), findsOneWidget);
      });

      testWidgets('note button library shows', (WidgetTester tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToNote(tester);
        expect(find.byIcon(AbiliaIcons.show_text), findsOneWidget);
      });

      testWidgets('note library shows', (WidgetTester tester) async {
        final content =
            'Etappen har sin början vid Bjursjöns strand, ett mycket populärt friluftsområde med närhet till Uddevalla tätort.';

        when(mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<NoteData>(
                data: NoteData(
                  name: 'NAAAMAE',
                  text: content,
                ),
              ),
              ...List.generate(
                30,
                (index) => Sortable.createNew<NoteData>(
                  sortOrder: '$index',
                  data: NoteData(
                    name: 'data $index',
                    text: [
                      for (var i = 0; i < index; i++) '$i$i$i$i$i$i\n'
                    ].fold('text:',
                        (previousValue, element) => previousValue + element),
                  ),
                ),
              ),
            ],
          ),
        );

        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToNote(tester);
        await tester.tap(find.byIcon(AbiliaIcons.show_text));
        await tester.pumpAndSettle();
        expect(
            find.byType(typeOf<SortableLibrary<NoteData>>()), findsOneWidget);
        expect(find.byType(LibraryNote), findsWidgets);
        expect(find.text(content), findsOneWidget);
      });

      testWidgets('notes from library is selectable',
          (WidgetTester tester) async {
        final content =
            'Etappen har sin början vid Bjursjöns strand, ett mycket populärt friluftsområde med närhet till Uddevalla tätort.';

        when(mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<NoteData>(
                data: NoteData(
                  name: 'NAAAMAE',
                  text: content,
                ),
              ),
            ],
          ),
        );

        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToNote(tester);
        await tester.tap(find.byIcon(AbiliaIcons.show_text));
        await tester.pumpAndSettle();
        await tester.tap(find.text(content));
        await tester.pumpAndSettle();
        expect(find.text(content), findsOneWidget);
        expect(find.byType(NoteBlock), findsOneWidget);
      });
    });

    group('checklist', () {
      setUp(() {
        GetItInitializer()
          ..fileStorage = MockFileStorage()
          ..init();
      });
      final questions = {
        0: 'Question 0',
        1: 'Question 1',
        2: 'Question 2',
        3: 'Question 3',
      };
      final checklist = Checklist(
          name: 'a checklist',
          questions:
              questions.keys.map((k) => Question(id: k, name: questions[k])));

      final activityWithChecklist = Activity.createNew(
          title: 'null', startTime: startTime, infoItem: checklist);
      Future goToChecklist(WidgetTester tester) async {
        await tester.goToInfoItemTab();

        await tester.tap(find.byKey(TestKey.changeInfoItem));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.infoItemChecklistRadio));
        await tester.pumpAndSettle();
      }

      testWidgets('Checklist is selectable', (WidgetTester tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToChecklist(tester);

        expect(find.byType(EditChecklistWidget), findsOneWidget);
      });

      testWidgets('Checklist shows check', (WidgetTester tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(questions[0]), findsOneWidget);
        expect(find.text(questions[1]), findsOneWidget);
        expect(find.text(questions[2]), findsOneWidget);
      });

      testWidgets('Checklist with images shows', (WidgetTester tester) async {
        when(mockUserFileBloc.state).thenReturn(UserFilesNotLoaded());
        await tester.pumpWidget(
          wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: Activity.createNew(
              title: 'null',
              startTime: startTime,
              infoItem: Checklist(
                questions: [Question(id: 0, fileId: 'fileid')],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.byKey(TestKey.checklistQuestionImageKey), findsOneWidget);
      });

      testWidgets('Can open new question dialog', (WidgetTester tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToChecklist(tester);

        await tester.tap(find.byIcon(AbiliaIcons.new_icon));
        await tester.pumpAndSettle();

        expect(find.byType(EditQuestionDialog), findsOneWidget);
      });

      testWidgets('Can add new question', (WidgetTester tester) async {
        final questionName = 'one question!';
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToChecklist(tester);

        await tester.tap(find.byIcon(AbiliaIcons.new_icon));
        await tester.pumpAndSettle();

        await tester.enterText_(
            find.byKey(TestKey.editTitleTextFormField), questionName);
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsWidgets);
        await tester.tap(find.byKey(TestKey.okDialog));
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsOneWidget);
      });

      testWidgets('Can add question to checklist', (WidgetTester tester) async {
        final questionName = 'last question!';
        await tester.pumpWidget(wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();
        await tester.tap(find.byIcon(AbiliaIcons.new_icon));
        await tester.pumpAndSettle();

        await tester.enterText_(
            find.byKey(TestKey.editTitleTextFormField), questionName);
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsWidgets);
        await tester.tap(find.byKey(TestKey.okDialog));
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsOneWidget);
      });

      testWidgets('Cant add question without image or title',
          (WidgetTester tester) async {
        final questionName = 'question!';
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        await tester.tap(find.byIcon(AbiliaIcons.new_icon));
        await tester.pumpAndSettle();

        final editViewDialogBefore =
            tester.widget<ViewDialog>(find.byType(ViewDialog));
        expect(editViewDialogBefore.onOk, isNull);

        await tester.enterText_(
            find.byKey(TestKey.editTitleTextFormField), questionName);
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsWidgets);

        final editViewDialogAfter =
            tester.widget<ViewDialog>(find.byType(ViewDialog));
        expect(editViewDialogAfter.onOk, isNotNull);
        await tester.tap(find.byKey(TestKey.okDialog));
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsOneWidget);
      });

      testWidgets('Can remove questions', (WidgetTester tester) async {
        await tester.pumpWidget(wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(questions[0]), findsOneWidget);
        expect(find.text(questions[1]), findsOneWidget);
        expect(find.text(questions[2]), findsOneWidget);
        expect(find.text(questions[3]), findsOneWidget);
        await tester.tap(find.text(questions[0]));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(RemoveButton));
        await tester.pumpAndSettle();
        expect(find.text(questions[0]), findsNothing);
        expect(find.text(questions[1]), findsOneWidget);
        expect(find.text(questions[2]), findsOneWidget);
        expect(find.text(questions[3]), findsOneWidget);
      });

      testWidgets('Can edit question', (WidgetTester tester) async {
        final newQuestionName = 'laditatssss';
        await tester.pumpWidget(wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        await tester.tap(find.text(questions[0]));

        await tester.pumpAndSettle();

        await tester.enterText_(
            find.byKey(TestKey.editTitleTextFormField), newQuestionName);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.okDialog));
        await tester.pumpAndSettle();

        expect(find.text(questions[0]), findsNothing);
        expect(find.text(newQuestionName), findsOneWidget);
      });

      testWidgets('Can edit multiline question', (WidgetTester tester) async {
        final questions = {
          0: '''Question
is
a
multi
line
question''',
          1: 'another q',
        };

        final activityWithChecklist = Activity.createNew(
            title: 'null',
            startTime: startTime,
            infoItem: Checklist(
                name: 'a checklist',
                questions: questions.keys
                    .map((k) => Question(id: k, name: questions[k]))));
        final newQuestionName = '''
yet
more
lines
for
the
text''';
        await tester.pumpWidget(wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(questions[0]), findsOneWidget);
        await tester.tap(find.text(questions[1]));

        await tester.pumpAndSettle();

        await tester.enterText_(
            find.byKey(TestKey.editTitleTextFormField), newQuestionName);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.okDialog));
        await tester.pumpAndSettle();

        expect(find.text(questions[1]), findsNothing);
        expect(find.text(newQuestionName), findsOneWidget);
      });

      testWidgets('checklist button library shows',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        expect(find.byIcon(AbiliaIcons.show_text), findsOneWidget);
      });

      testWidgets('checklist library shows', (WidgetTester tester) async {
        when(mockUserFileBloc.state).thenReturn(UserFilesNotLoaded());
        final title1 = 'listtitle1';
        when(mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                  data: ChecklistData(Checklist(
                      name: title1,
                      fileId: 'fileid1',
                      questions: [
                    Question(id: 0, name: '1'),
                    Question(id: 1, name: '2', fileId: '2222')
                  ]))),
              ...List.generate(
                30,
                (index) => Sortable.createNew<ChecklistData>(
                  sortOrder: '$index',
                  data: ChecklistData(
                    Checklist(
                      name: 'data $index',
                      questions: [
                        for (var i = 0; i < index; i++)
                          Question(id: i, name: '$i$i$i$i$i$i\n')
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        await tester.tap(find.byIcon(AbiliaIcons.show_text));
        await tester.pumpAndSettle();
        expect(find.byType(typeOf<SortableLibrary<ChecklistData>>()),
            findsOneWidget);
        expect(find.byType(LibraryChecklist), findsWidgets);
        expect(find.text(title1), findsOneWidget);
      });

      testWidgets('checklist from library is selectable',
          (WidgetTester tester) async {
        when(mockUserFileBloc.state).thenReturn(UserFilesNotLoaded());
        final title1 = 'listtitle1';
        final checklisttitle1 = 'checklisttitle1',
            checklisttitle2 = 'checklisttitle2';
        when(mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                data: ChecklistData(
                  Checklist(
                    name: title1,
                    fileId: 'fileid1',
                    questions: [
                      Question(id: 0, name: checklisttitle1),
                      Question(id: 1, name: checklisttitle2, fileId: '2222')
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        await tester.tap(find.byIcon(AbiliaIcons.show_text));
        await tester.pumpAndSettle();
        await tester.tap(find.text(title1));
        await tester.pumpAndSettle();
        expect(find.text(checklisttitle1), findsOneWidget);
        expect(find.text(checklisttitle2), findsOneWidget);
        expect(find.byType(CheckListView), findsOneWidget);
      });
    });
  });

  group('Edit time', () {
    final hourInputFinder = find.byKey(TestKey.hourTextInput);
    final minInputFinder = find.byKey(TestKey.minTextInput);
    final removeEndTimeFinder = find.byIcon(AbiliaIcons.delete_all_clear);
    final pmRadioFinder = find.byKey(ObjectKey(TestKey.pmRadioField));
    final amRadioFinder = find.byKey(ObjectKey(TestKey.amRadioField));

    testWidgets('Start time shows start time', (WidgetTester tester) async {
      // Arrange
      final acivity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 11, 55));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Act -- tap att start time
      await tester.tap(startTimeFieldFinder);
      await tester.pumpAndSettle();

      // Assert -- Start time dialog shows with correct time
      expect(find.byType(StartTimeInputDialog), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('55'), findsOneWidget);
    });

    testWidgets('can change start time', (WidgetTester tester) async {
      // Arrange
      final acivity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 11, 55));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Assert -- that the activities start time shows
      expect(find.text('9:33 AM'), findsNothing);
      expect(find.text('11:55 AM'), findsOneWidget);

      // Act -- Change input to new start time
      await tester.tap(startTimeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(hourInputFinder, '9');
      await tester.enterText(minInputFinder, '33');
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- that the activities new start time shows
      expect(find.text('9:33 AM'), findsOneWidget);
    });

    testWidgets('can remove end time', (WidgetTester tester) async {
      // Arrange
      final acivity = Activity.createNew(
          title: '',
          startTime: DateTime(2000, 11, 22, 11, 55),
          duration: 3.hours());

      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Assert -- that correct start and end time shows
      expect(find.text('11:55 AM'), findsOneWidget);
      expect(find.text('2:55 PM'), findsOneWidget);

      // Act -- remove end time
      await tester.tap(endTimeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(removeEndTimeFinder);
      await tester.pumpAndSettle();

      // Assert -- old end time does not show
      expect(find.text('2:55 PM'), findsNothing);
      expect(find.text('11:55 AM'), findsOneWidget);
    });

    testWidgets('can change am to pm', (WidgetTester tester) async {
      // Arrange
      final acivity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 11, 55));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Assert -- time is in am
      expect(find.text('11:55 AM'), findsOneWidget);

      await tester.tap(startTimeFieldFinder);
      await tester.pumpAndSettle();

      // Assert -- Am is selected
      final pmRadio = tester.widget<AbiliaRadio>(pmRadioFinder);
      final amRadio = tester.widget<AbiliaRadio>(amRadioFinder);
      expect(amRadio.groupValue, DayPeriod.am);
      expect(amRadio.value, DayPeriod.am);
      expect(pmRadio.groupValue, DayPeriod.am);
      expect(pmRadio.value, DayPeriod.pm);

      // Act -- switch to pm
      await tester.tap(pmRadioFinder);
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- time now in pm
      expect(find.text('11:55 PM'), findsOneWidget);
    });

    testWidgets('can change pm to am', (WidgetTester tester) async {
      // Arrange
      final acivity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 12, 55));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Assert -- time starts in pm
      expect(find.text('12:55 PM'), findsOneWidget);

      // Act -- switch to pm
      await tester.tap(startTimeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(amRadioFinder);
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- time now in pm
      expect(find.text('12:55 AM'), findsOneWidget);
    });

    testWidgets('removing original leaves same value',
        (WidgetTester tester) async {
      // Arrange
      final acivity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 3, 44));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Act -- remove values
      await tester.tap(startTimeFieldFinder);
      await tester.pumpAndSettle();

      await tester.enterText(hourInputFinder, '');
      await tester.enterText(minInputFinder, '');
      await tester.tap(minInputFinder);
      await tester.tap(hourInputFinder);

      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- time is same
      expect(find.text('3:44 AM'), findsOneWidget);
    });

    testWidgets('24h clock', (WidgetTester tester) async {
      // Arrange
      Intl.defaultLocale = 'sv_SE';
      addTearDown(() => Intl.defaultLocale = null);
      final acivity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 13, 44));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
          use24H: true,
        ),
      );
      await tester.pumpAndSettle();

      // Assert -- is 24h clock
      expect(find.text('13:44'), findsOneWidget);
      expect(find.text('00:01'), findsNothing);

      await tester.tap(startTimeFieldFinder);
      await tester.pumpAndSettle();

      // Assert -- no am/pm radio buttons
      expect(amRadioFinder, findsNothing);
      expect(pmRadioFinder, findsNothing);

      // Act -- change time to 01:01
      expect(find.text('13'), findsOneWidget);
      expect(find.text('44'), findsOneWidget);

      await tester.enterText(hourInputFinder, '0');
      expect(find.text('0'), findsOneWidget);

      await tester.tap(minInputFinder);
      expect(find.text('00'), findsOneWidget);
      expect(find.text('44'), findsOneWidget);

      await tester.enterText(minInputFinder, '1');
      expect(find.text('00'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      await tester.tap(hourInputFinder);
      expect(find.text('00'), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
      await tester.pumpAndSettle();

      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- time is now 00:01
      expect(find.text('13:44'), findsNothing);
      expect(find.text('00:01'), findsOneWidget);
    });
  });
}

extension on WidgetTester {
  Future scrollDown({double dy = -800.0}) async {
    final center = getCenter(find.byType(EditActivityPage));
    await dragFrom(center, Offset(0.0, dy));
    await pump();
  }

  Future goToMainTab() async => goToTab(AbiliaIcons.my_photos);
  Future goToAlarmTab() async => goToTab(AbiliaIcons.attention);
  Future goToInfoItemTab() async => goToTab(AbiliaIcons.attachment);

  Future goToTab(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }
}
