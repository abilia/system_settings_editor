import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../mocks.dart';
import '../../../utils/types.dart';

void main() {
  final startTime = DateTime(2020, 02, 10, 15, 30);
  final today = startTime.onlyDays();
  final startActivity = Activity.createNew(
    title: '',
    startTime: startTime,
  );
  final translate = Locales.language.values.first;

  final timeFieldFinder = find.byKey(TestKey.timePicker);
  final okFinder = find.byKey(TestKey.okDialog);

  MockSortableBloc mockSortableBloc;
  MockUserFileBloc mockUserFileBloc;
  MockMemoplannerSettingsBloc mockMemoplannerSettingsBloc;
  setUp(() async {
    tz.initializeTimeZones();
    await initializeDateFormatting();
    mockSortableBloc = MockSortableBloc();
    mockUserFileBloc = MockUserFileBloc();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingsBloc();
    when(mockMemoplannerSettingsBloc.state)
        .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings()));
  });

  tearDown(GetIt.I.reset);

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
        child: MockAuthenticatedBlocsProvider(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ClockBloc>(
                create: (context) => ClockBloc(
                    StreamController<DateTime>().stream,
                    initialTime: startTime),
              ),
              BlocProvider<MemoplannerSettingBloc>(
                create: (context) => mockMemoplannerSettingsBloc,
              ),
              BlocProvider<EditActivityBloc>(
                create: (context) => newActivity
                    ? EditActivityBloc.newActivity(
                        activitiesBloc:
                            BlocProvider.of<ActivitiesBloc>(context),
                        clockBloc: BlocProvider.of<ClockBloc>(context),
                        memoplannerSettingBloc:
                            BlocProvider.of<MemoplannerSettingBloc>(context),
                        day: today)
                    : EditActivityBloc(
                        ActivityDay(activity, today),
                        activitiesBloc:
                            BlocProvider.of<ActivitiesBloc>(context),
                        clockBloc: BlocProvider.of<ClockBloc>(context),
                        memoplannerSettingBloc:
                            BlocProvider.of<MemoplannerSettingBloc>(context),
                      ),
              ),
              BlocProvider<SortableBloc>(
                create: (context) => mockSortableBloc,
              ),
              BlocProvider<UserFileBloc>(
                create: (context) => mockUserFileBloc,
              ),
              BlocProvider<SettingsBloc>(
                create: (context) => SettingsBloc(
                  settingsDb: MockSettingsDb(),
                ),
              ),
              BlocProvider<PermissionBloc>(
                create: (context) => PermissionBloc()..checkAll(),
              ),
            ],
            child: child,
          ),
        ),
      ),
      home: widget,
    );
  }

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

    group('picture dialog', () {
      tearDown(() {
        setupPermissions();
      });
      testWidgets('Select picture dialog shows', (WidgetTester tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addPicture));
        await tester.pumpAndSettle();
        expect(find.byType(SelectPicturePage), findsOneWidget);
        await tester.tap(find.byIcon(AbiliaIcons.close_program));
        await tester.pumpAndSettle();
        expect(find.byType(SelectPicturePage), findsNothing);
      });

      final cameraPickFieldFinder = find.byKey(ObjectKey(ImageSource.camera)),
          photoPickFieldFinder = find.byKey(ObjectKey(ImageSource.gallery)),
          photoInfoButtonFiner =
              find.byKey(Key('${ImageSource.gallery}${Permission.photos}')),
          cameraInfoButtonFiner =
              find.byKey(Key('${ImageSource.camera}${Permission.camera}'));
      testWidgets(
          'Select picture dialog picker options are disabled and shows info button when permission denied',
          (WidgetTester tester) async {
        setupPermissions({
          Permission.camera: PermissionStatus.permanentlyDenied,
          Permission.photos: PermissionStatus.permanentlyDenied,
        });
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addPicture));
        await tester.pumpAndSettle();
        expect(find.byType(SelectPicturePage), findsOneWidget);

        final photoPickField = tester.widget<PickField>(photoPickFieldFinder);
        final cameraPickField = tester.widget<PickField>(cameraPickFieldFinder);

        expect(photoPickField.onTap, isNull);
        expect(cameraPickField.onTap, isNull);
        expect(find.byType(InfoButton), findsNWidgets(2));

        expect(cameraInfoButtonFiner, findsOneWidget);
        expect(photoInfoButtonFiner, findsOneWidget);
      });

      testWidgets('Image dialog picker options camera info button calls',
          (WidgetTester tester) async {
        setupPermissions({
          Permission.camera: PermissionStatus.permanentlyDenied,
        });
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addPicture));
        await tester.pumpAndSettle();
        await tester.tap(cameraInfoButtonFiner);
        await tester.pumpAndSettle();

        final permissionDialog = tester
            .widget<PermissionInfoDialog>(find.byType(PermissionInfoDialog));

        expect(permissionDialog.permission, Permission.camera);
        expect(find.byIcon(Permission.camera.iconData), findsWidgets);
        expect(find.byType(PermissionSwitch), findsOneWidget);
      });

      testWidgets('Image dialog picker options photos info button calls',
          (WidgetTester tester) async {
        setupPermissions({
          Permission.photos: PermissionStatus.permanentlyDenied,
        });
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addPicture));
        await tester.pumpAndSettle();
        await tester.tap(photoInfoButtonFiner);
        await tester.pumpAndSettle();

        final permissionDialog = tester
            .widget<PermissionInfoDialog>(find.byType(PermissionInfoDialog));

        expect(permissionDialog.permission, Permission.photos);
        expect(find.byIcon(Permission.photos.iconData), findsWidgets);
        expect(find.byType(PermissionSwitch), findsOneWidget);
      });
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

    testWidgets('pressing add activity button without time shows error',
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
      await tester.scrollDown(dy: -150);
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

    testWidgets(
        'pressing add activity on other tab scrolls back to main page on error',
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
      await tester.scrollDown(dy: -150);
      // Assert -- Fullday switch is off
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isFalse);
      // Assert -- Start time, left and rigth category visible
      expect(timeFieldFinder, findsOneWidget);
      expect(find.byKey(TestKey.leftCategoryRadio), findsOneWidget);
      expect(find.byKey(TestKey.rightCategoryRadio), findsOneWidget);

      // Assert -- can see Alarm tab
      expect(find.byIcon(AbiliaIcons.attention), findsOneWidget);
      await tester.goToAlarmTab();
      // Assert -- alarm tab contains reminders
      expect(find.byIcon(AbiliaIcons.handi_reminder), findsOneWidget);
      await tester.goToMainTab();
      await tester.scrollDown(dy: -150);

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
      expect(timeFieldFinder, findsNothing);
      expect(find.byKey(TestKey.leftCategoryRadio), findsNothing);
      expect(find.byKey(TestKey.rightCategoryRadio), findsNothing);
      // Assert -- Alarm tab not visible
      expect(find.byIcon(AbiliaIcons.attention), findsNothing);
    });
    group('alarms', () {
      testWidgets('alarm at start switch', (WidgetTester tester) async {
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await tester.goToAlarmTab();
        expect(
            tester
                .widget<Switch>(
                    find.byKey(ObjectKey(TestKey.alarmAtStartSwitch)))
                .value,
            isFalse);
        expect(find.byKey(TestKey.alarmAtStartSwitch), findsOneWidget);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.alarmAtStartSwitch));
        await tester.pumpAndSettle();
        expect(
            tester
                .widget<Switch>(
                    find.byKey(ObjectKey(TestKey.alarmAtStartSwitch)))
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
        await tester.tap(find.byKey(ObjectKey(AlarmType.Vibration)));
        await tester.pumpAndSettle();
        expect(find.text(translate.vibration), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.handi_vibration), findsOneWidget);
      });

      testWidgets('SGC-359 Select alarm dialog silent alarms maps to Silent',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: Activity.createNew(
                title: 'null',
                startTime: startTime,
                alarmType: ALARM_SILENT_ONLY_ON_START),
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToAlarmTab();
        expect(find.byKey(TestKey.selectAlarm), findsOneWidget);
        expect(find.text(translate.silentAlarm), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.handi_alarm), findsNWidgets(2));
        await tester.tap(find.byKey(TestKey.selectAlarm));
        await tester.pumpAndSettle();
        expect(find.byType(SelectAlarmTypeDialog), findsOneWidget);
        final radio =
            tester.widget<RadioField>(find.byKey(ObjectKey(AlarmType.Silent)));
        expect(radio.groupValue, AlarmType.Silent);
      });

      testWidgets(
          'SGC-359 Select alarm dialog only sound alarms maps to sound and vibration',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: Activity.createNew(
                title: 'null',
                startTime: startTime,
                alarmType: ALARM_SOUND_ONLY_ON_START),
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToAlarmTab();
        expect(find.byKey(TestKey.selectAlarm), findsOneWidget);
        expect(find.text(translate.alarmAndVibration), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.handi_alarm_vibration), findsOneWidget);
        await tester.tap(find.byKey(TestKey.selectAlarm));
        await tester.pumpAndSettle();
        expect(find.byType(SelectAlarmTypeDialog), findsOneWidget);
        final radio = tester
            .widget<RadioField>(find.byKey(ObjectKey(AlarmType.Vibration)));
        expect(radio.groupValue, AlarmType.SoundAndVibration);
      });
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
      expect(find.text('(Today) February 10, 2020'), findsOneWidget);

      await tester.tap(find.byKey(TestKey.datePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('14'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('(Today) February 10, 2020'), findsNothing);
      expect(find.text('February 14, 2020'), findsOneWidget);
    });

    testWidgets('Category picker', (WidgetTester tester) async {
      final rightRadioKey = ObjectKey(TestKey.rightCategoryRadio);
      final leftRadioKey = ObjectKey(TestKey.leftCategoryRadio);
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -150);
      final leftCategoryRadio1 =
          tester.widget<AbiliaRadio>(find.byKey(leftRadioKey));
      final rightCategoryRadio1 =
          tester.widget<AbiliaRadio>(find.byKey(rightRadioKey));

      expect(leftCategoryRadio1.value, Category.left);
      expect(rightCategoryRadio1.value, Category.right);
      expect(leftCategoryRadio1.groupValue, Category.right);
      expect(rightCategoryRadio1.groupValue, Category.right);

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
      expect(find.byType(SelectInfoTypePage), findsOneWidget);
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
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NoteBlock));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), noteText);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      expect(find.text(noteText), findsOneWidget);

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemChecklistRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      expect(find.text(q1), findsOneWidget);
      expect(find.text(q2), findsOneWidget);
      expect(find.text(q3), findsOneWidget);

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemNoneRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
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
        await tester.tap(find.byType(GreenButton));
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
        expect(find.byType(SelectInfoTypePage), findsOneWidget);
        expect(find.byKey(TestKey.infoItemNoneRadio), findsOneWidget);
        expect(find.byKey(TestKey.infoItemChecklistRadio), findsOneWidget);
        expect(find.byKey(TestKey.infoItemNoteRadio), findsOneWidget);

        await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();
        expect(find.byType(SelectInfoTypePage), findsNothing);
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

        expect(find.byType(SelectInfoTypePage), findsOneWidget);

        await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();

        await tester.pumpAndSettle();
        expect(find.byType(SelectInfoTypePage), findsNothing);
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

        expect(find.byType(EditNotePage), findsOneWidget);
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

        await tester.tap(find.byType(NoteBlock));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), noteText);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
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
        await tester.tap(find.byType(GreenButton));
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

        expect(find.byType(EditQuestionPage), findsOneWidget);
      });

      testWidgets('Can add new question', (WidgetTester tester) async {
        final questionName = 'one question!';
        await tester
            .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
        await tester.pumpAndSettle();
        await goToChecklist(tester);

        await tester.tap(find.byIcon(AbiliaIcons.new_icon));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), questionName);
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsWidgets);
        await tester.tap(find.byType(GreenButton));
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

        await tester.enterText(find.byType(TextField), questionName);
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsWidgets);
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();
        await tester.scrollDown(dy: -150);
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
            tester.widget<GreenButton>(find.byType(GreenButton));
        expect(editViewDialogBefore.onPressed, isNull);

        await tester.enterText(find.byType(TextField), questionName);
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsWidgets);

        final editViewDialogAfter =
            tester.widget<GreenButton>(find.byType(GreenButton));
        expect(editViewDialogAfter.onPressed, isNotNull);
        await tester.tap(find.byType(GreenButton));
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

        await tester.enterText(find.byType(TextField), newQuestionName);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
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

        await tester.enterText(find.byType(TextField), newQuestionName);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
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

  final startTimeInputFinder = find.byKey(TestKey.startTimeInput);
  final endTimeInputFinder = find.byKey(TestKey.endTimeInput);

  final startTimePmRadioFinder = find.byKey(TestKey.startTimePmRadioField);
  final startTimeAmRadioFinder = find.byKey(TestKey.startTimeAmRadioField);
  final endTimeAmRadioFinder = find.byKey(TestKey.endTimeAmRadioField);
  group('Edit time', () {
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
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      // Assert -- Start time dialog shows with correct time
      expect(find.byType(TimeInputDialog), findsOneWidget);
      expect(find.text('11:55'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
    });

    testWidgets('Error message when no start time is entered',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- Error dialog is shown
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text(translate.missingStartTime), findsOneWidget);
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
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(startTimeInputFinder, '0933');
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
      expect(find.text('11:55 AM - 2:55 PM'), findsOneWidget);

      // Act -- remove end time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(endTimeInputFinder);
      await tester.showKeyboard(endTimeInputFinder);
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- old end time does not show
      expect(find.text('11:55 AM - 2:55 PM'), findsNothing);
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

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      // Act -- switch to pm
      await tester.tap(startTimePmRadioFinder);
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
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(startTimeAmRadioFinder);
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
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      await tester.enterText(startTimeInputFinder, '');
      await tester.enterText(endTimeInputFinder, '');
      await tester.tap(endTimeInputFinder);
      await tester.tap(startTimeInputFinder);

      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- time is same
      expect(find.text('3:44 AM'), findsOneWidget);
    });

    testWidgets('Changes focus to endTime when startTime is filled in',
        (WidgetTester tester) async {
      // Arrange
      final acivity = Activity.createNew(
        title: '',
        startTime: DateTime(2000, 11, 22, 3, 04),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pump();
      // Assert -- start time set but not end time endTime
      expect(find.text('3:04 AM'), findsOneWidget);
      expect(find.text('11:11 AM - 11:12 PM'), findsNothing);

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(startTimeInputFinder).focusNode.hasFocus,
        isTrue,
      );
      expect(
        tester.widget<TextField>(endTimeInputFinder).focusNode.hasFocus,
        isFalse,
      );

      await tester.enterText(startTimeInputFinder, '1111');
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(endTimeInputFinder).focusNode.hasFocus,
        isTrue,
      );
      expect(
        tester.widget<TextField>(startTimeInputFinder).focusNode.hasFocus,
        isFalse,
      );

      await tester.enterText(endTimeInputFinder, '1112');
      await tester.pumpAndSettle();

      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      expect(find.byType(TimeInputDialog), findsNothing);
      expect(find.text('3:04 AM'), findsNothing);
      expect(find.text('11:11 AM - 11:12 PM'), findsOneWidget);
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

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      // Assert -- no am/pm radio buttons
      expect(startTimeAmRadioFinder, findsNothing);
      expect(startTimePmRadioFinder, findsNothing);

      // Act -- change time to 01:01
      expect(
          find.text('13:44'),
          findsNWidgets(
              2)); // One in the dialog and one in the edit activity view

      await tester.enterText(startTimeInputFinder, '0');
      expect(find.text('0'), findsOneWidget);

      await tester.tap(endTimeInputFinder);
      await tester.pumpAndSettle();
      expect(find.text('13:44'),
          findsNWidgets(2)); // Time resets when no valid time is entered

      await tester.enterText(endTimeInputFinder, '1111');
      expect(find.text('11:11'), findsOneWidget);

      await tester.tap(startTimeInputFinder);
      await tester.enterText(startTimeInputFinder, '0001');
      expect(find.text('00:01'), findsOneWidget);
      await tester.pumpAndSettle();

      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- time is now 00:01
      expect(find.text('00:01 - 13:44'), findsNothing);
    });

    testWidgets('Leading 0 for hour not necessary when entering time',
        (WidgetTester tester) async {
      final acivity = Activity.createNew(
        title: '',
        startTime: DateTime(2020, 2, 20, 10, 00),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      await tester.enterText(startTimeInputFinder, '9');
      await tester.pumpAndSettle();
      expect(find.text('09:--'), findsOneWidget);
    });

    testWidgets('Keyboard done saves time', (WidgetTester tester) async {
      final acivity = Activity.createNew(
        title: '',
        startTime: DateTime(2020, 2, 20, 10, 00),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      await tester.enterText(startTimeInputFinder, '1033');
      await tester.enterText(endTimeInputFinder, '1111');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      await tester.pumpAndSettle();
      expect(startTimeInputFinder, findsNothing);
      expect(find.text('10:33 AM - 11:11 PM'), findsOneWidget);
    });

    testWidgets('Delete key just deletes last digit',
        (WidgetTester tester) async {
      final acivity = Activity.createNew(
        title: '',
        startTime: DateTime(2020, 2, 20, 10, 00),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      await tester.enterText(startTimeInputFinder, '1033');
      await tester.enterText(endTimeInputFinder, '1111');

      await tester.tap(startTimeInputFinder);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();
      expect(find.text('10:3-'), findsOneWidget);
    });
  });

  group('Recurrence', () {
    testWidgets('Recurrence present', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();

      // Assert
      expect(find.byType(RecurrenceTab), findsOneWidget);
      expect(find.text(translate.recurrence), findsOneWidget);
    });

    testWidgets('Shows time picker widget ', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();
      // Assert
      expect(find.byType(RecurrenceTab), findsOneWidget);
      expect(find.byType(TimeIntervallPicker), findsOneWidget);
    });

    testWidgets('Does not shows time picker widget on fullday ',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
          title: 'null', startTime: startTime, fullDay: true);
      await tester.pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today),
          givenActivity: activity));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();
      // Assert
      expect(find.byType(RecurrenceTab), findsOneWidget);
      expect(find.byType(TimeIntervallPicker), findsNothing);
    });

    testWidgets('No recurrance selected', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();

      // Assert
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.text(translate.once), findsOneWidget);
    });

    testWidgets('all info item present', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SelectRecurrenceDialog), findsOneWidget);
      expect(find.text(translate.recurrence), findsNWidgets(2));
      expect(find.byIcon(AbiliaIcons.day), findsNWidgets(2));
      expect(find.text(translate.once), findsNWidgets(2));
      expect(find.byIcon(AbiliaIcons.week), findsOneWidget);
      expect(find.text(translate.weekly), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsOneWidget);
      expect(find.text(translate.monthly), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.basic_activity), findsOneWidget);
      expect(find.text(translate.yearly), findsOneWidget);
    });

    testWidgets('can change to yearly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        newActivity: true,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Assert -- Once selected
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.text(translate.once), findsOneWidget);

      // Act -- Change to Yearly
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.basic_activity));
      await tester.pumpAndSettle();

      // Assert -- Yearly selected, not Once
      expect(find.byIcon(AbiliaIcons.day), findsNothing);
      expect(find.text(translate.once), findsNothing);
      expect(find.byIcon(AbiliaIcons.basic_activity), findsOneWidget);
      expect(find.text(translate.yearly), findsOneWidget);
    });

    testWidgets('can change to monthly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        newActivity: true,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Assert -- Once selected
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.text(translate.once), findsOneWidget);

      // Act -- Change to montly
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      // Assert -- monthly selected, not Once
      expect(find.byIcon(AbiliaIcons.day), findsNothing);
      expect(find.text(translate.once), findsNothing);
      expect(find.byIcon(AbiliaIcons.month), findsOneWidget);
      expect(find.text(translate.monthly), findsOneWidget);

      expect(find.byType(MonthDays), findsOneWidget);
      expect(find.byType(EndDateWidget), findsOneWidget);
    });

    testWidgets('can change to weekly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        newActivity: true,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Assert -- Once selected
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.text(translate.once), findsOneWidget);

      // Act -- Change to weekly
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      // Assert -- Weekly selected, not Once
      expect(find.byIcon(AbiliaIcons.day), findsNothing);
      expect(find.text(translate.once), findsNothing);
      expect(find.byIcon(AbiliaIcons.week), findsOneWidget);
      expect(find.text(translate.weekly), findsOneWidget);

      expect(find.byType(WeekDays), findsOneWidget);
      expect(find.byType(EndDateWidget), findsOneWidget);
    });

    testWidgets('end date shows', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        newActivity: true,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Act -- Change to weekly
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.byKey(TestKey.noEndDate));
      await tester.pumpAndSettle();

      // Assert -- date picker visible
      expect(find.byType(EndDateWidget), findsOneWidget);
      expect(find.byType(DatePicker), findsOneWidget);
      expect(find.text(translate.endDate), findsOneWidget);
    });

    testWidgets('end date disabled if edit recurring (Bug SGC-354)',
        (WidgetTester tester) async {
      final activity = Activity.createNew(
        title: 'recurring',
        startTime: startTime,
        recurs: Recurs.raw(
          Recurs.TYPE_WEEKLY,
          Recurs.allDaysOfWeek,
          startTime.add(30.days()).millisecondsSinceEpoch,
        ),
      );
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp(
        EditActivityPage(day: today),
        givenActivity: activity,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Act -- Change to weekly
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();

      // Assert -- date picker visible
      expect(find.byKey(TestKey.noEndDate), findsOneWidget);
      expect(find.byType(EndDateWidget), findsOneWidget);
      expect(find.byType(DatePicker), findsOneWidget);
      expect(
        tester.widget<DatePicker>(find.byType(DatePicker)).onChange,
        isNull,
      );
      expect(
        tester.widget<SwitchField>(find.byKey(TestKey.noEndDate)).onChanged,
        isNull,
      );
    });

    testWidgets(
        'add activity without recurance data tab scrolls back to recurance tab',
        (WidgetTester tester) async {
      // Arrange
      final submitButtonFinder = find.byKey(TestKey.finishEditActivityButton);

      await tester.pumpWidget(
          wrapWithMaterialApp(EditActivityPage(day: today), newActivity: true));

      await tester.pumpAndSettle();
      // Arrange -- enter title
      await tester.enterText_(
          find.byKey(TestKey.editTitleTextFormField), 'newActivtyTitle');

      // Arrange -- enter start time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(startTimeInputFinder, '0933');
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();
      // Arrange -- set full day
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();
      await tester.pumpAndSettle();
      // Arrange -- set weekly recurance
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      // Arrange -- deselect preselect
      await tester.tap(find.text(translate.shortWeekday(startTime.weekday)));
      await tester.goToMainTab();
      await tester.pumpAndSettle();

      expect(find.byType(MainTab), findsOneWidget);

      // Act press submit
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Assert error message
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(
          find.text(translate.recurringDataEmptyErrorMessage), findsOneWidget);

      // Act dissmiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Assert at Recurrence Tab
      expect(find.byType(RecurrenceTab), findsOneWidget);
    });
  });

  group('Memoplanner settings', () {
    testWidgets('Date picker not available when setting says so',
        (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityDateEditable: false,
      )));
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      expect(find.byType(DatePicker), findsOneWidget);
      final datePicker =
          tester.widgetList(find.byType(DatePicker)).first as DatePicker;
      expect(datePicker.onChange, isNull);
    });

    testWidgets('Right/left not visible', (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityTypeEditable: false,
      )));
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();

      expect(find.byKey(TestKey.leftCategoryRadio), findsNothing);
      expect(find.byKey(TestKey.rightCategoryRadio), findsNothing);
    });

    testWidgets('No end time', (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityEndTimeEditable: false,
      )));
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      expect(endTimeInputFinder, findsNothing);
    });

    testWidgets('No recurring option', (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityRecurringEditable: false,
      )));
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();

      expect(find.byIcon(AbiliaIcons.repeat), findsNothing);
    });

    testWidgets('Alarm options', (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityDisplayAlarmOption: false,
        activityDisplaySilentAlarmOption: false,
      )));
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();

      expect(find.byType(PickField), findsOneWidget);
      final alarmPicker =
          tester.widgetList(find.byType(PickField)).first as PickField;

      expect(alarmPicker.onTap, isNull);
    });

    testWidgets('Alarm options - silent option alarm and vibration',
        (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityDisplayAlarmOption: false,
        activityDisplayNoAlarmOption: false,
      )));
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();

      expect(find.byType(PickField), findsOneWidget);
      final alarmPicker =
          tester.widgetList(find.byType(PickField)).first as PickField;

      expect(alarmPicker.onTap, isNotNull);
      await tester.tap(find.byType(AlarmWidget));
      await tester.pumpAndSettle();

      expect(find.byType(SelectAlarmTypeDialog), findsOneWidget);

      expect(find.text(translate.silentAlarm), findsOneWidget);
      expect(find.text(translate.vibration), findsOneWidget);
    });

    final finishActivityFinder = find.byKey(TestKey.finishEditActivityButton);
    testWidgets(
        'activityTimeBeforeCurrent true - Cant save when start time is past',
        (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityTimeBeforeCurrent: false,
      )));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          use24H: true,
          givenActivity:
              Activity.createNew(title: 't i t l e', startTime: startTime),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      final startTimeBefore = '${startTime.hour}${startTime.minute - 1}';
      await tester.enterText(
        startTimeInputFinder,
        startTimeBefore,
      );
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();
      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      expect(find.text('15:29'), findsOneWidget);
      expect(find.text(translate.startTimeBeforeNow), findsOneWidget);
    });

    testWidgets(
        'activityTimeBeforeCurrent true - CAN save when start time is future',
        (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityTimeBeforeCurrent: false,
      )));
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          givenActivity:
              Activity.createNew(title: 't i t l e', startTime: startTime),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(
          startTimeInputFinder, '${startTime.hour}${startTime.minute + 1}');
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();
      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      expect(find.text(translate.startTimeBeforeNow), findsNothing);
    });

    testWidgets(
        'activityTimeBeforeCurrent true - CAN save recurring when start time is future',
        (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(MemoplannerSettings(
        activityTimeBeforeCurrent: false,
      )));

      final activity = Activity.createNew(
        title: 't i t l e',
        startTime: startTime.subtract(100.days()),
        recurs: Recurs.everyDay,
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(EditActivityPage(day: today),
            givenActivity: activity),
      );

      await tester.pumpAndSettle();

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(
          startTimeInputFinder, '${startTime.hour + 1}${startTime.minute + 1}');
      await tester.pumpAndSettle();
      await tester.tap(okFinder);
      await tester.pumpAndSettle();
      await tester.tap(finishActivityFinder);
      await tester.pumpAndSettle();

      expect(find.text(translate.startTimeBeforeNow), findsNothing);
    });

    testWidgets('calendarActivityType-Left/Rigth given name',
        (WidgetTester tester) async {
      final leftCategoryName = 'VÄNSTER',
          rightCategoryName =
              'HÖGER IS SUPER LONG AND WILL PROBABLY OVERFLOW BADLY!';
      when(mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            calendarActivityTypeLeft: leftCategoryName,
            calendarActivityTypeRight: rightCategoryName,
          ),
        ),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(EditActivityPage(day: today)),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -200);

      expect(find.text(leftCategoryName), findsOneWidget);
      expect(find.text(rightCategoryName), findsOneWidget);
    });

    testWidgets('calendarActivityTypeShowTypes false does not show categories',
        (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            calendarActivityTypeShowTypes: false,
          ),
        ),
      );

      await tester.pumpWidget(
        wrapWithMaterialApp(EditActivityPage(day: today)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CategoryWidget), findsNothing);
      await tester.scrollDown();
      expect(find.byType(CategoryWidget), findsNothing);
    });
  });

  group('tts', () {
    setUp(() {
      GetItInitializer()
        ..flutterTts = MockFlutterTts()
        ..init();
    });
    testWidgets('title', (WidgetTester tester) async {
      final name = 'new name of a activity';
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byKey(TestKey.editTitleTextFormField),
          exact: translate.name);

      await tester.enterText_(find.byKey(TestKey.editTitleTextFormField), name);

      await tester.verifyTts(find.byKey(TestKey.editTitleTextFormField),
          exact: name);
    });

    testWidgets('image', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byKey(TestKey.addPicture),
          exact: translate.picture);
    });

    testWidgets('date', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byKey(TestKey.datePicker),
          contains: translate.today);
    });

    testWidgets('time', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();

      // Assert -- that the activities time shows
      await tester.verifyTts(timeFieldFinder, exact: translate.time);

      // Act -- Change time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(startTimeInputFinder, '0933');
      await tester.tap(startTimeAmRadioFinder);
      await tester.pumpAndSettle();

      await tester.verifyTts(
        startTimeAmRadioFinder,
        exact: translate.am,
      );
      await tester.verifyTts(
        startTimePmRadioFinder,
        exact: translate.pm,
      );
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      // Assert -- that the activities new start tts
      await tester.verifyTts(
        timeFieldFinder,
        exact: '9:33 AM',
      );
    });
    group('time input tts', () {
      testWidgets('start/endtime 12h', (WidgetTester tester) async {
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

        // Act -- remove end time
        await tester.tap(timeFieldFinder);
        await tester.pumpAndSettle();

        // Assert
        await tester.verifyTts(endTimeInputFinder,
            exact: '${translate.endTime} 02:55 PM');
        await tester.verifyTts(startTimeInputFinder,
            exact: '${translate.startTime} 11:55 AM');

        // Act change to period
        await tester.tap(startTimePmRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(endTimeAmRadioFinder);
        await tester.pumpAndSettle();

        // Assert
        await tester.verifyTts(endTimeInputFinder,
            exact: '${translate.endTime} 02:55 AM');
        await tester.verifyTts(startTimeInputFinder,
            exact: '${translate.startTime} 11:55 PM');
      });

      testWidgets('start/endtime 24h', (WidgetTester tester) async {
        // Arrange
        Intl.defaultLocale = 'sv_SE';
        addTearDown(() => Intl.defaultLocale = null);
        final acivity = Activity.createNew(
            title: '',
            startTime: DateTime(2000, 11, 22, 11, 55),
            duration: 3.hours());

        await tester.pumpWidget(
          wrapWithMaterialApp(
            EditActivityPage(day: today),
            givenActivity: acivity,
            use24H: true,
          ),
        );
        await tester.pumpAndSettle();

        // Act -- remove end time
        await tester.tap(timeFieldFinder);
        await tester.pumpAndSettle();

        // Assert
        await tester.verifyTts(startTimeInputFinder,
            exact: '${translate.startTime} 11:55');
        await tester.verifyTts(endTimeInputFinder,
            exact: '${translate.endTime} 14:55');
      });

      testWidgets('invalid input tts', (WidgetTester tester) async {
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
        await tester.tap(timeFieldFinder);
        await tester.pumpAndSettle();

        await tester.enterText(startTimeInputFinder, '1');
        await tester.pumpAndSettle();

        // Assert
        await tester.verifyTts(
          startTimeInputFinder,
          exact: translate.startTime,
        );
        await tester.verifyTts(
          endTimeInputFinder,
          exact: translate.endTime,
        );
      });
    });

    testWidgets('fullday', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -150);

      await tester.verifyTts(find.byKey(TestKey.fullDaySwitch),
          exact: translate.fullDay);
    });

    testWidgets('category', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -150);

      await tester.verifyTts(find.byKey(TestKey.rightCategoryRadio),
          exact: translate.right);
      await tester.verifyTts(find.byKey(TestKey.leftCategoryRadio),
          exact: translate.left);
    });

    testWidgets('checkable', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -300);

      await tester.verifyTts(find.byKey(TestKey.checkableSwitch),
          exact: translate.checkable);
    });

    testWidgets('delete after', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -400);

      await tester.verifyTts(find.byKey(TestKey.deleteAfterSwitch),
          exact: translate.deleteAfter);
    });

    testWidgets('availible for', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -500);

      await tester.verifyTts(find.byKey(TestKey.availibleFor),
          exact: translate.meAndSupportPersons);

      await tester.tap(find.byKey(TestKey.availibleFor));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byKey(TestKey.onlyMe),
          exact: translate.onlyMe);
    });

    testWidgets('reminders', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();

      await tester.verifyTts(find.byIcon(AbiliaIcons.handi_reminder),
          exact: translate.reminders);

      await tester.tap(find.byIcon(AbiliaIcons.handi_reminder));
      await tester.pumpAndSettle();

      final reminders = [
        5.minutes(),
        15.minutes(),
        30.minutes(),
        1.hours(),
        2.hours(),
        1.days(),
      ].map((r) => r.toReminderString(translate));

      for (final t in reminders) {
        await tester.verifyTts(find.text(t), exact: t);
      }
    });

    testWidgets('alarms', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();

      await tester.verifyTts(find.byKey(TestKey.alarmAtStartSwitch),
          exact: translate.alarmOnlyAtStartTime);
      await tester.verifyTts(find.byKey(TestKey.selectAlarm),
          exact: translate.alarmAndVibration);

      await tester.tap(find.byKey(TestKey.selectAlarm));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byKey(ObjectKey(AlarmType.Vibration)),
          exact: translate.vibration);
    });

    testWidgets('recurrance', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        wrapWithMaterialApp(
          EditActivityPage(day: today),
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();
      await tester.verifyTts(find.byIcon(AbiliaIcons.day),
          exact: translate.once);
      await tester.tap(find.byIcon(AbiliaIcons.day));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byIcon(AbiliaIcons.week),
          exact: translate.weekly);
      await tester.verifyTts(find.byIcon(AbiliaIcons.month),
          exact: translate.monthly);
      await tester.verifyTts(find.byIcon(AbiliaIcons.basic_activity),
          exact: translate.yearly);

      await tester.tap(find.byIcon(AbiliaIcons.week));

      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);

      await tester.verifyTts(find.byType(EndDateWidget),
          exact: translate.noEndDate);
    });

    testWidgets('error view', (WidgetTester tester) async {
      final submitButtonFinder = find.byKey(TestKey.finishEditActivityButton);

      // Act press submit
      await tester.pumpWidget(
          wrapWithMaterialApp(EditActivityPage(day: today), newActivity: true));
      await tester.pumpAndSettle();

      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      // Assert error message
      await tester.verifyTts(
        find.text(translate.missingTitleOrImageAndStartTime),
        exact: translate.missingTitleOrImageAndStartTime,
      );
    });

    group('info items tts', () {
      testWidgets('info item', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(
          wrapWithMaterialApp(
            EditActivityPage(day: today),
            newActivity: true,
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();
        await tester.tap(find.byKey(TestKey.changeInfoItem));
        await tester.pumpAndSettle();

        await tester.verifyTts(find.byKey(TestKey.infoItemNoneRadio),
            exact: translate.infoTypeNone);
        await tester.verifyTts(find.byKey(TestKey.infoItemChecklistRadio),
            exact: translate.infoTypeChecklist);
        await tester.verifyTts(find.byKey(TestKey.infoItemNoteRadio),
            exact: translate.infoTypeNote);
      });

      testWidgets('checklist', (WidgetTester tester) async {
        // Arrange
        when(mockUserFileBloc.state).thenReturn(UserFilesNotLoaded());
        final title1 = 'listtitle1';
        final item1Name = 'Item 1 name';
        when(mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                  data: ChecklistData(Checklist(
                      name: title1,
                      fileId: 'fileid1',
                      questions: [
                    Question(id: 0, name: item1Name),
                    Question(id: 1, name: '2', fileId: '2222')
                  ]))),
            ],
          ),
        );
        await tester.pumpWidget(
          wrapWithMaterialApp(
            EditActivityPage(day: today),
            newActivity: true,
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();
        await tester.tap(find.byKey(TestKey.changeInfoItem));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.infoItemChecklistRadio));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(AbiliaIcons.show_text));
        await tester.pumpAndSettle();
        await tester.verifyTts(find.byType(LibraryChecklist), exact: title1);
        await tester.tap(find.byType(LibraryChecklist));
        await tester.pumpAndSettle();
        await tester.verifyTts(find.text(item1Name), exact: item1Name);
        await tester.verifyTts(find.byIcon(AbiliaIcons.new_icon),
            exact: translate.addNew);
      });
    });

    testWidgets('note', (WidgetTester tester) async {
      final name = 'Rigel';
      final content =
          'is a blue supergiant star in the constellation of Orion, approximately 860 light-years (260 pc) from Earth. It is the brightest and most massive component of a star system of at least four stars that appear as a single blue-white point of light to the naked eye. A star of spectral type B8Ia, Rigel is calculated to be anywhere from 61,500 to 363,000 times as luminous as the Sun, and 18 to 24 times as massive. ';
      when(mockSortableBloc.state).thenReturn(
        SortablesLoaded(
          sortables: [
            Sortable.createNew<NoteData>(
              data: NoteData(
                name: name,
                text: content,
              ),
            ),
          ],
        ),
      );

      await tester
          .pumpWidget(wrapWithMaterialApp(EditActivityPage(day: today)));
      await tester.pumpAndSettle();
      await tester.goToInfoItemTab();
      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.show_text));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.text(content), exact: content);
      await tester.tap(find.text(content));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.text(content), exact: content);
      await tester.tap(find.text(content));
      await tester.pumpAndSettle();
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
  Future goToRecurrenceTab() async => goToTab(AbiliaIcons.repeat);
  Future goToInfoItemTab() async => goToTab(AbiliaIcons.attachment);

  Future goToTab(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }
}