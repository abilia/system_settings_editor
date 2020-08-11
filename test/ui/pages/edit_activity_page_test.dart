import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
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
  final translate = Translator(Locale('en')).translate;

  final startTimeFieldFinder = find.byKey(TestKey.startTimePicker);
  final endTimeFieldFinder = find.byKey(TestKey.endTimePicker);
  final okFinder = find.byKey(TestKey.okDialog);

  Widget wrapWithMaterialApp(Widget widget,
      {Activity givenActivity, bool use24H = false}) {
    final activity = givenActivity ?? startActivity;
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale.languageCode,
              orElse: () => supportedLocales.first),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24H),
          child: child),
      home: MultiBlocProvider(providers: [
        BlocProvider<AuthenticationBloc>(
            create: (context) => MockAuthenticationBloc()),
        BlocProvider<ActivitiesBloc>(create: (context) => MockActivitiesBloc()),
        BlocProvider<EditActivityBloc>(
          create: (context) => EditActivityBloc(
            ActivityDay(activity, today),
            activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
          ),
        ),
        BlocProvider<SortableBloc>(
          create: (context) => MockSortableBloc(),
        ),
        BlocProvider<UserFileBloc>(
          create: (context) => MockUserFileBloc(),
        ),
        BlocProvider<ClockBloc>(
          create: (context) => ClockBloc(StreamController<DateTime>().stream,
              initialTime: startTime),
        ),
      ], child: widget),
    );
  }

  setUp(() async {
    await initializeDateFormatting();
  });

  group('edit activity test', () {
    Future scrollDown(WidgetTester tester, {double dy = -800.0}) async {
      final center = tester.getCenter(find.byIcon(AbiliaIcons.handi_reminder));
      await tester.dragFrom(center, Offset(0.0, dy));
      await tester.pump();
    }

    testWidgets('New activity shows', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
    });

    testWidgets('Scroll to end of page', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.byType(AvailibleForWidget), findsNothing);
      await scrollDown(tester);
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
        'Add activity button is disabled when no title and enabled when titled entered',
        (WidgetTester tester) async {
      final newActivtyName = 'new activity name';
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<ActionButton>(
                  find.byKey(TestKey.finishEditActivityButton))
              .onPressed,
          isNull);
      await tester.enterText_(
          find.byKey(TestKey.editTitleTextFormField), newActivtyName);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<ActionButton>(find.byKey(TestKey.finishEditActivityButton))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(TestKey.finishEditActivityButton));
      await tester.pumpAndSettle();
    });

    testWidgets('full day switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isFalse);
      expect(startTimeFieldFinder, findsOneWidget);
      expect(find.byIcon(AbiliaIcons.handi_reminder), findsOneWidget);
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isTrue);
      expect(startTimeFieldFinder, findsNothing);
      expect(find.byIcon(AbiliaIcons.handi_reminder), findsNothing);
      expect(find.byKey(TestKey.leftCategoryRadio), findsNothing);
      expect(find.byKey(TestKey.rightCategoryRadio), findsNothing);
    });

    testWidgets('alarm at start switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await scrollDown(tester);
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
      await scrollDown(tester);
      await tester.pumpAndSettle();
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
      await scrollDown(tester);
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
      await scrollDown(tester);
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

      await scrollDown(tester, dy: -100);
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
      await scrollDown(tester);
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
      await scrollDown(tester, dy: -100);
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
      expect(find.byIcon(AbiliaIcons.plus), findsNothing);

      // Act -- remove end time
      await tester.tap(endTimeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(removeEndTimeFinder);
      await tester.pumpAndSettle();

      // Assert -- old end time does not show
      expect(find.text('2:55 PM'), findsNothing);
      expect(find.text('11:55 AM'), findsOneWidget);

      expect(find.byIcon(AbiliaIcons.plus), findsOneWidget);
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
