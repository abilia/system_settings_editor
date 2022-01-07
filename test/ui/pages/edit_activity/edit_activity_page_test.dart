import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';

import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';
import '../../../test_helpers/tts.dart';
import '../../../test_helpers/types.dart';

void main() {
  final startTime = DateTime(2020, 02, 10, 15, 30);
  final today = startTime.onlyDays();
  final startActivity = Activity.createNew(
    title: '',
    startTime: startTime,
  );
  final translate = Locales.language.values.first;

  final timeFieldFinder = find.byType(TimeIntervallPicker);
  final okButtonFinder = find.byType(OkButton);
  final cancelButtonFinder = find.byType(CancelButton);

  late MockSortableBloc mockSortableBloc;
  late MockUserFileBloc mockUserFileBloc;
  late MockTimerCubit mockTimerCubit;
  late MemoplannerSettingBloc mockMemoplannerSettingsBloc;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    tz.initializeTimeZones();
    await initializeDateFormatting();
    mockSortableBloc = MockSortableBloc();
    when(() => mockSortableBloc.stream).thenAnswer((_) => const Stream.empty());
    mockUserFileBloc = MockUserFileBloc();
    when(() => mockUserFileBloc.stream).thenAnswer((_) => const Stream.empty());
    mockTimerCubit = MockTimerCubit();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
            MemoplannerSettings(advancedActivityTemplate: false)));
    when(() => mockMemoplannerSettingsBloc.stream)
        .thenAnswer((_) => const Stream.empty());
  });

  tearDown(GetIt.I.reset);

  Widget createEditActivityPage({
    Activity? givenActivity,
    bool use24H = false,
    bool newActivity = false,
  }) {
    final activity = givenActivity ?? startActivity;
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: const [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale?.languageCode,
              orElse: () => supportedLocales.first),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24H),
        child: FakeAuthenticatedBlocsProvider(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<ClockBloc>(
                create: (context) => ClockBloc(
                    StreamController<DateTime>().stream,
                    initialTime: startTime),
              ),
              BlocProvider<MemoplannerSettingBloc>.value(
                value: mockMemoplannerSettingsBloc,
              ),
              BlocProvider<ActivitiesBloc>(create: (_) => FakeActivitiesBloc()),
              BlocProvider<EditActivityBloc>(
                create: (context) => newActivity
                    ? EditActivityBloc.newActivity(
                        day: today,
                        defaultAlarmTypeSetting: mockMemoplannerSettingsBloc
                            .state.defaultAlarmTypeSetting,
                      )
                    : EditActivityBloc.edit(
                        ActivityDay(activity, today),
                      ),
              ),
              BlocProvider<ActivityWizardCubit>(
                create: (context) => newActivity
                    ? ActivityWizardCubit.newActivity(
                        activitiesBloc: context.read<ActivitiesBloc>(),
                        clockBloc: context.read<ClockBloc>(),
                        editActivityBloc: context.read<EditActivityBloc>(),
                        settings: context.read<MemoplannerSettingBloc>().state,
                      )
                    : ActivityWizardCubit.edit(
                        activitiesBloc: context.read<ActivitiesBloc>(),
                        clockBloc: context.read<ClockBloc>(),
                        editActivityBloc: context.read<EditActivityBloc>(),
                        settings: mockMemoplannerSettingsBloc.state,
                      ),
              ),
              BlocProvider<SortableBloc>.value(value: mockSortableBloc),
              BlocProvider<UserFileBloc>.value(value: mockUserFileBloc),
              BlocProvider<DayPickerBloc>(
                create: (context) => DayPickerBloc(
                  clockBloc: context.read<ClockBloc>(),
                ),
              ),
              BlocProvider<SettingsBloc>(
                create: (context) => SettingsBloc(
                  settingsDb: FakeSettingsDb(),
                ),
              ),
              BlocProvider<PermissionBloc>(
                create: (context) => PermissionBloc()..checkAll(),
              ),
              BlocProvider<TimepillarCubit>(
                create: (context) => TimepillarCubit(
                  clockBloc: context.read<ClockBloc>(),
                  memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                  dayPickerBloc: context.read<DayPickerBloc>(),
                ),
              ),
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  screenTimeoutCallback: Future.value(30.minutes()),
                  memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                  battery: FakeBattery(),
                ),
              ),
              BlocProvider<TimerCubit>.value(value: mockTimerCubit),
            ],
            child: child!,
          ),
        ),
      ),
      home: const ActivityWizardPage(),
    );
  }

  group('edit activity test', () {
    testWidgets('New activity shows', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.byType(EditActivityPage), findsOneWidget);
    });

    testWidgets('TabBar shows', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.byType(AbiliaTabBar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.myPhotos), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.attention), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.repeat), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.attachment), findsOneWidget);
    });

    testWidgets('Can switch tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.byType(MainTab), findsOneWidget);
      await tester.goToAlarmTab();
      expect(find.byType(AlarmAndReminderTab), findsOneWidget);
      await tester.goToMainTab();
      expect(find.byType(MainTab), findsOneWidget);
    });

    testWidgets('Scroll to end of page', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.byType(AvailableForWidget), findsNothing);
      await tester.scrollDown();
      expect(find.byType(AvailableForWidget), findsOneWidget);
    });

    testWidgets('Can enter text', (WidgetTester tester) async {
      const newActivtyTitle = 'activity title';
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.text(newActivtyTitle), findsNothing);
      await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField), newActivtyTitle);
      expect(find.text(newActivtyTitle), findsOneWidget);
    });

    group('picture dialog', () {
      setUp(() {
        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew(
                  data: const ImageArchiveData(upload: true), fixed: true),
              Sortable.createNew(
                  data: const ImageArchiveData(myPhotos: true), fixed: true),
            ],
          ),
        );
      });

      tearDown(setupPermissions);

      testWidgets('Select picture dialog shows', (WidgetTester tester) async {
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addPicture));
        await tester.pumpAndSettle();
        expect(find.byType(SelectPicturePage), findsOneWidget);
        await tester.tap(find.byIcon(AbiliaIcons.closeProgram));
        await tester.pumpAndSettle();
        expect(find.byType(SelectPicturePage), findsNothing);
      });

      final cameraPickFieldFinder =
              find.byKey(const ObjectKey(ImageSource.camera)),
          photoPickFieldFinder =
              find.byKey(const ObjectKey(ImageSource.gallery)),
          photoInfoButtonFinder =
              find.byKey(Key('${ImageSource.gallery}${Permission.photos}')),
          cameraInfoButtonFinder =
              find.byKey(Key('${ImageSource.camera}${Permission.camera}'));
      testWidgets(
          'Select picture dialog picker options are disabled and shows info button when permission denied',
          (WidgetTester tester) async {
        setupPermissions({
          Permission.camera: PermissionStatus.permanentlyDenied,
          Permission.photos: PermissionStatus.permanentlyDenied,
        });
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addPicture));
        await tester.pumpAndSettle();
        expect(find.byType(SelectPicturePage), findsOneWidget);

        if (Config.isMPGO) {
          final photoPickField = tester.widget<PickField>(photoPickFieldFinder);
          expect(photoPickField.onTap, isNull);
          expect(find.byType(InfoButton), findsNWidgets(2));
          expect(photoInfoButtonFinder, findsOneWidget);
        } else {
          expect(find.byType(InfoButton), findsNWidgets(1));
        }

        final cameraPickField = tester.widget<PickField>(cameraPickFieldFinder);
        expect(cameraPickField.onTap, isNull);
        expect(cameraInfoButtonFinder, findsOneWidget);
      });

      testWidgets('Image dialog picker options camera info button calls',
          (WidgetTester tester) async {
        setupPermissions({
          Permission.camera: PermissionStatus.permanentlyDenied,
        });
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addPicture));
        await tester.pumpAndSettle();
        await tester.tap(cameraInfoButtonFinder);
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
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.addPicture));
        await tester.pumpAndSettle();
        await tester.tap(photoInfoButtonFinder);
        await tester.pumpAndSettle();

        final permissionDialog = tester
            .widget<PermissionInfoDialog>(find.byType(PermissionInfoDialog));

        expect(permissionDialog.permission, Permission.photos);
        expect(find.byIcon(Permission.photos.iconData), findsWidgets);
        expect(find.byType(PermissionSwitch), findsOneWidget);
      }, skip: Config.isMP);
    });

    testWidgets('full day switch', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -150);
      // Assert -- Fullday switch is off
      expect(
          tester
              .widget<Switch>(
                  find.byKey(const ObjectKey(TestKey.fullDaySwitch)))
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
      expect(find.byIcon(AbiliaIcons.handiReminder), findsOneWidget);
      await tester.goToMainTab();
      await tester.scrollDown(dy: -150);

      // Act -- set to full day
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();

      // Assert -- Fullday switch is on,
      expect(
          tester
              .widget<Switch>(
                  find.byKey(const ObjectKey(TestKey.fullDaySwitch)))
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
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await tester.goToAlarmTab();
        expect(
            tester
                .widget<Switch>(
                    find.byKey(const ObjectKey(TestKey.alarmAtStartSwitch)))
                .value,
            isFalse);
        expect(find.byKey(TestKey.alarmAtStartSwitch), findsOneWidget);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.alarmAtStartSwitch));
        await tester.pumpAndSettle();
        expect(
            tester
                .widget<Switch>(
                    find.byKey(const ObjectKey(TestKey.alarmAtStartSwitch)))
                .value,
            isTrue);
      });

      testWidgets('Select alarm dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await tester.goToAlarmTab();
        expect(find.byKey(TestKey.selectAlarm), findsOneWidget);
        expect(find.text(translate.vibration), findsNothing);
        expect(find.byIcon(AbiliaIcons.handiVibration), findsNothing);
        await tester.tap(find.byKey(TestKey.selectAlarm));
        await tester.pumpAndSettle();
        expect(find.byType(SelectAlarmTypePage), findsOneWidget);
        await tester.tap(find.byKey(const ObjectKey(AlarmType.vibration)));
        await tester.pumpAndSettle();
        expect(find.text(translate.vibration), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.handiVibration), findsOneWidget);
      });

      testWidgets('SGC-359 Select alarm dialog silent alarms maps to Silent',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createEditActivityPage(
            givenActivity: Activity.createNew(
                title: 'null',
                startTime: startTime,
                alarmType: alarmSilentOnlyOnStart),
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToAlarmTab();
        expect(find.byKey(TestKey.selectAlarm), findsOneWidget);
        expect(find.text(translate.silentAlarm), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.handiAlarm), findsNWidgets(2));
        await tester.tap(find.byKey(TestKey.selectAlarm));
        await tester.pumpAndSettle();
        expect(find.byType(SelectAlarmTypePage), findsOneWidget);
        final radio = tester
            .widget<RadioField>(find.byKey(const ObjectKey(AlarmType.silent)));
        expect(radio.groupValue, AlarmType.silent);
      });

      testWidgets(
          'SGC-359 Select alarm dialog only sound alarms maps to sound and vibration',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createEditActivityPage(
            givenActivity: Activity.createNew(
                title: 'null',
                startTime: startTime,
                alarmType: alarmSoundOnlyOnStart),
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToAlarmTab();
        expect(find.byKey(TestKey.selectAlarm), findsOneWidget);
        expect(find.text(translate.alarmAndVibration), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.handiAlarmVibration), findsOneWidget);
        await tester.tap(find.byKey(TestKey.selectAlarm));
        await tester.pumpAndSettle();
        expect(find.byType(SelectAlarmTypePage), findsOneWidget);
        final radio = tester.widget<RadioField>(
            find.byKey(const ObjectKey(AlarmType.vibration)));
        expect(radio.groupValue, AlarmType.soundAndVibration);
      });
    });

    testWidgets('checkable switch', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.scrollDown();
      expect(
          tester
              .widget<Switch>(
                  find.byKey(const ObjectKey(TestKey.checkableSwitch)))
              .value,
          isFalse);
      expect(find.byKey(TestKey.checkableSwitch), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.checkableSwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(
                  find.byKey(const ObjectKey(TestKey.checkableSwitch)))
              .value,
          isTrue);
    });

    testWidgets('delete after switch', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.scrollDown();
      expect(
          tester
              .widget<Switch>(
                  find.byKey(const ObjectKey(TestKey.deleteAfterSwitch)))
              .value,
          isFalse);
      expect(find.byKey(TestKey.deleteAfterSwitch), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.deleteAfterSwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(
                  find.byKey(const ObjectKey(TestKey.deleteAfterSwitch)))
              .value,
          isTrue);
    });

    testWidgets('Category picker', (WidgetTester tester) async {
      const rightRadioKey = ObjectKey(TestKey.rightCategoryRadio);
      const leftRadioKey = ObjectKey(TestKey.leftCategoryRadio);
      await tester.pumpWidget(createEditActivityPage());
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
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.scrollDown();
      await tester.pumpAndSettle();

      expect(find.byKey(TestKey.availibleFor), findsOneWidget);
      expect(find.text(translate.onlyMe), findsNothing);
      expect(find.byIcon(AbiliaIcons.passwordProtection), findsNothing);
      await tester.tap(find.byKey(TestKey.availibleFor));
      await tester.pumpAndSettle();
      expect(find.byType(AvailableForPage), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.passwordProtection));
      await tester.pumpAndSettle();
      expect(find.text(translate.onlyMe), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.passwordProtection), findsOneWidget);
    });

    testWidgets('Reminder', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      final reminderSwitchFinder = find.byIcon(AbiliaIcons.handiReminder);
      final reminder15MinFinder =
          find.text(15.minutes().toDurationString(translate));
      final reminderDayFinder = find.text(1.days().toDurationString(translate));
      final remindersAllSelected =
          find.byIcon(AbiliaIcons.radiocheckboxSelected);
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
      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
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
      const q1 = 'q1', q2 = 'q2', q3 = 'q3', noteText = 'noteText';
      final activity = Activity.createNew(
          title: 'null',
          startTime: startTime,
          infoItem: Checklist(questions: const [
            Question(id: 1, name: q1),
            Question(id: 2, name: q3),
            Question(id: 3, name: q2)
          ]));
      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
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
        const aLongNote = '''
This is a note
I am typing for testing
that it is visible in the info item tab
''';
        final activity = Activity.createNew(
            title: 'null',
            startTime: startTime,
            infoItem: const NoteInfoItem(aLongNote));
        await tester
            .pumpWidget(createEditActivityPage(givenActivity: activity));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(aLongNote), findsOneWidget);
      });

      testWidgets('Info item note not deleted when to info item note',
          (WidgetTester tester) async {
        const aLongNote = '''
This is a note
I am typing for testing
that it is visible in the info item tab
''';
        final activity = Activity.createNew(
            title: 'null',
            startTime: startTime,
            infoItem: const NoteInfoItem(aLongNote));
        await tester
            .pumpWidget(createEditActivityPage(givenActivity: activity));
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
        await tester.pumpWidget(createEditActivityPage());
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
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToNote(tester);

        await tester.tap(find.byType(NoteBlock));
        await tester.pumpAndSettle();

        expect(find.byType(EditNotePage), findsOneWidget);
      });

      testWidgets('Info item note can be edited', (WidgetTester tester) async {
        const noteText = '''4.1.1
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
        await tester.pumpWidget(createEditActivityPage());
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
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToNote(tester);
        expect(find.byIcon(AbiliaIcons.showText), findsOneWidget);
      });

      testWidgets('note library shows', (WidgetTester tester) async {
        const content =
            'Etappen har sin början vid Bjursjöns strand, ett mycket populärt friluftsområde med närhet till Uddevalla tätort.';

        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<NoteData>(
                data: const NoteData(
                  name: 'NAAAMAE',
                  text: content,
                ),
                sortOrder: startChar,
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

        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToNote(tester);
        await tester.tap(find.byIcon(AbiliaIcons.showText));
        await tester.pumpAndSettle();
        expect(
            find.byType(typeOf<SortableLibrary<NoteData>>()), findsOneWidget);
        expect(find.byType(LibraryNote), findsWidgets);
        expect(find.text(content), findsOneWidget);
      });

      testWidgets('notes from library is selectable',
          (WidgetTester tester) async {
        const content =
            'Etappen har sin början vid Bjursjöns strand, ett mycket populärt'
            ' friluftsområde med närhet till Uddevalla tätort.';

        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<NoteData>(
                data: const NoteData(
                  name: 'NAAAMAE',
                  text: content,
                ),
              ),
            ],
          ),
        );

        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToNote(tester);
        await tester.tap(find.byIcon(AbiliaIcons.showText));
        await tester.pumpAndSettle();
        await tester.tap(find.text(content));
        await tester.pumpAndSettle();
        expect(find.text(content), findsOneWidget);
        expect(find.byType(NoteBlock), findsOneWidget);
      });
    });

    group('checklist', () {
      setUp(() async {
        GetItInitializer()
          ..fileStorage = FakeFileStorage()
          ..sharedPreferences = await FakeSharedPreferences.getInstance()
          ..database = FakeDatabase()
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
              questions.keys.map((k) => Question(id: k, name: questions[k]!)));

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
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToChecklist(tester);

        expect(find.byType(EditChecklistWidget), findsOneWidget);
      });

      testWidgets('Checklist shows check', (WidgetTester tester) async {
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(questions[0]!), findsOneWidget);
        expect(find.text(questions[1]!), findsOneWidget);
        expect(find.text(questions[2]!), findsOneWidget);
      });

      testWidgets('Checklist with images shows', (WidgetTester tester) async {
        when(() => mockUserFileBloc.state)
            .thenReturn(const UserFilesNotLoaded());
        await tester.pumpWidget(
          createEditActivityPage(
            givenActivity: Activity.createNew(
              title: 'null',
              startTime: startTime,
              infoItem: Checklist(
                questions: const [Question(id: 0, fileId: 'fileid')],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.byKey(TestKey.checklistQuestionImageKey), findsOneWidget);
      });

      testWidgets('Can open new question dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToChecklist(tester);

        await tester.tap(find.byIcon(AbiliaIcons.newIcon));
        await tester.pumpAndSettle();

        expect(find.byType(EditQuestionPage), findsOneWidget);
      });

      testWidgets('Can add new question', (WidgetTester tester) async {
        const questionName = 'one question!';
        await tester.pumpWidget(createEditActivityPage());

        await tester.pumpAndSettle();
        await goToChecklist(tester);

        await tester.tap(find.byIcon(AbiliaIcons.newIcon));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), questionName);
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsWidgets);
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsOneWidget);
      });

      testWidgets('Can add question to checklist', (WidgetTester tester) async {
        const questionName = 'last question!';
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();
        await tester.tap(find.byIcon(AbiliaIcons.newIcon));
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
        const questionName = 'question!';
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        await tester.tap(find.byIcon(AbiliaIcons.newIcon));
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

      testWidgets('Can remove questions from edit question page',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(questions[0]!), findsOneWidget);
        expect(find.text(questions[1]!), findsOneWidget);
        expect(find.text(questions[2]!), findsOneWidget);
        expect(find.text(questions[3]!, skipOffstage: false), findsOneWidget);
        await tester.tap(find.text(questions[0]!));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.checklistToolbarEditQButton));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(RemoveButton));
        await tester.pumpAndSettle();
        expect(find.text(questions[0]!), findsNothing);
        expect(find.text(questions[1]!), findsOneWidget);
        expect(find.text(questions[2]!), findsOneWidget);
        expect(find.text(questions[3]!), findsOneWidget);
      });

      testWidgets('Can remove questions from toolbar',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(questions[0]!), findsOneWidget);
        expect(find.text(questions[1]!), findsOneWidget);
        expect(find.text(questions[2]!), findsOneWidget);
        expect(find.text(questions[3]!, skipOffstage: false), findsOneWidget);
        await tester.tap(find.text(questions[0]!));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(TestKey.checklistToolbarDeleteQButton));
        await tester.pumpAndSettle();
        expect(find.text(questions[0]!), findsNothing);
        expect(find.text(questions[1]!), findsOneWidget);
        expect(find.text(questions[2]!), findsOneWidget);
        expect(find.text(questions[3]!), findsOneWidget);
      });

      testWidgets('Can bring up and hide the toolbar on questions',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        await tester.tap(find.text(questions[0]!));
        await tester.pumpAndSettle();
        expect(find.byType(ChecklistToolbar), findsOneWidget);

        await tester.tap(find.text(questions[0]!));
        await tester.pumpAndSettle();
        expect(find.byType(ChecklistToolbar), findsNothing);

        await tester.tap(find.text(questions[1]!));
        await tester.pumpAndSettle();
        await tester.tap(find.text(questions[2]!));
        await tester.pumpAndSettle();
        expect(find.byType(ChecklistToolbar), findsOneWidget);
      });

      testWidgets('Can edit question', (WidgetTester tester) async {
        const newQuestionName = 'laditatssss';
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        await tester.tap(find.text(questions[0]!));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.checklistToolbarEditQButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), newQuestionName);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();

        expect(find.text(questions[0]!), findsNothing);
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
                    .map((k) => Question(id: k, name: questions[k]!))));
        const newQuestionName = '''
yet
more
lines
for
the
text''';
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.text(questions[0]!), findsOneWidget);
        await tester.tap(find.text(questions[1]!));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.checklistToolbarEditQButton));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), newQuestionName);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();

        expect(find.text(questions[1]!), findsNothing);
        expect(find.text(newQuestionName), findsOneWidget);
      });

      testWidgets('checklist button library shows',
          (WidgetTester tester) async {
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        expect(find.byIcon(AbiliaIcons.showText), findsOneWidget);
      });

      testWidgets('checklist library shows', (WidgetTester tester) async {
        when(() => mockUserFileBloc.state)
            .thenReturn(const UserFilesNotLoaded());
        const title1 = 'listtitle1';
        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                  sortOrder: startChar,
                  data: ChecklistData(Checklist(
                      name: title1,
                      fileId: 'fileid1',
                      questions: const [
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

        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        await tester.tap(find.byIcon(AbiliaIcons.showText));
        await tester.pumpAndSettle();
        expect(find.byType(typeOf<SortableLibrary<ChecklistData>>()),
            findsOneWidget);
        expect(find.byType(ChecklistLibraryPage), findsWidgets);
        expect(find.text(title1), findsOneWidget);
      });

      testWidgets('checklist from library is selectable',
          (WidgetTester tester) async {
        when(() => mockUserFileBloc.state)
            .thenReturn(const UserFilesNotLoaded());
        const title1 = 'listtitle1';
        const checklisttitle1 = 'checklisttitle1',
            checklisttitle2 = 'checklisttitle2';
        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                data: ChecklistData(
                  Checklist(
                    name: title1,
                    fileId: 'fileid1',
                    questions: const [
                      Question(id: 0, name: checklisttitle1),
                      Question(id: 1, name: checklisttitle2, fileId: '2222')
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        await tester.tap(find.byIcon(AbiliaIcons.showText));
        await tester.pumpAndSettle();
        await tester.tap(find.text(title1));
        await tester.pumpAndSettle();
        expect(find.text(checklisttitle1), findsOneWidget);
        expect(find.text(checklisttitle2), findsOneWidget);
        expect(find.byType(ChecklistView), findsOneWidget);
      });
    });
  });

  group('Date picker', () {
    testWidgets('changes date', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.text('(Today) February 10, 2020'), findsOneWidget);

      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
          of: find.text('14'), matching: find.byType(MonthDayView)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      expect(find.text('(Today) February 10, 2020'), findsNothing);
      expect(find.text('February 14, 2020'), findsOneWidget);
    });

    testWidgets('can switch months', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerPage), findsOneWidget);

      expect(find.text('February'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
      expect(find.byType(MonthDayView), findsNWidgets(29));

      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();

      expect(find.text('January'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
      expect(find.byType(MonthDayView), findsNWidgets(31));

      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();

      expect(find.text('April'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
      expect(find.byType(MonthDayView), findsNWidgets(30));

      await tester.tap(find.byType(GoToCurrentActionButton));
      await tester.pumpAndSettle();
      expect(find.text('February'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
    });

    testWidgets('changes date then add recurring sets end date to start date',
        (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.text('(Today) February 10, 2020'), findsOneWidget);

      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
          of: find.text('14'), matching: find.byType(MonthDayView)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.byType(EndDateWidget));
      await tester.pumpAndSettle();
      expect(find.text('February 14, 2020'), findsOneWidget);
    });

    testWidgets(
        'changes date after added recurring sets end date to start date',
        (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.byType(EndDateWidget));
      await tester.pumpAndSettle();
      expect(find.text('(Today) February 10, 2020'), findsOneWidget);
      await tester.goToMainTab();
      // Act change start date to 14th
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
          of: find.text('14'), matching: find.byType(MonthDayView)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await tester.goToRecurrenceTab();
      await tester.scrollDown(dy: -250);
      expect(find.text('February 14, 2020'), findsOneWidget);
    });

    testWidgets('cant pick recurring end date before start date',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.byType(EndDateWidget));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
        of: find.text('3'),
        matching: find.byType(MonthDayView),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      expect(find.byType(EditActivityPage), findsNothing);
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text(translate.endBeforeStartError), findsOneWidget);

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();

      expect(find.byType(EditActivityPage), findsNothing);
      expect(find.byType(DatePickerPage), findsOneWidget);
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
        createEditActivityPage(
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Act -- tap att start time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      // Assert -- Start time dialog shows with correct time
      expect(find.byType(TimeInputPage), findsOneWidget);
      expect(find.text('11:55'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
    });

    testWidgets('Error message when no start time is entered',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();

      // Act
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
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
        createEditActivityPage(
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
      await tester.tap(okButtonFinder);
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
        createEditActivityPage(
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Assert -- that correct start and end time shows
      expect(find.text('11:55 AM - 2:55 PM'), findsOneWidget);

      // Act -- remove end time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(endTimeInputFinder, warnIfMissed: false);
      await tester.showKeyboard(endTimeInputFinder);
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
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
        createEditActivityPage(
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
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- time now in pm
      expect(find.text('11:55 PM'), findsOneWidget);
    });

    testWidgets('can change pm to am', (WidgetTester tester) async {
      // Arrange
      final acivity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 12, 55));
      await tester.pumpWidget(
        createEditActivityPage(
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
      await tester.tap(okButtonFinder);
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
        createEditActivityPage(
          givenActivity: acivity,
        ),
      );
      await tester.pumpAndSettle();

      // Act -- remove values
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      await tester.enterText(startTimeInputFinder, '');
      await tester.enterText(endTimeInputFinder, '');

      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
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
        createEditActivityPage(
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
        tester.widget<TextField>(startTimeInputFinder).focusNode?.hasFocus,
        isTrue,
      );
      expect(
        tester.widget<TextField>(endTimeInputFinder).focusNode?.hasFocus,
        isFalse,
      );

      await tester.enterText(startTimeInputFinder, '1111');
      await tester.pumpAndSettle();
      expect(find.text('11:11'), findsOneWidget);

      expect(
        tester.widget<TextField>(endTimeInputFinder).focusNode?.hasFocus,
        isTrue,
      );
      expect(
        tester.widget<TextField>(startTimeInputFinder).focusNode?.hasFocus,
        isFalse,
      );

      await tester.enterText(endTimeInputFinder, '1112');
      await tester.pumpAndSettle();
      expect(find.text('11:12'), findsOneWidget);

      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      expect(find.byType(TimeInputPage), findsNothing);
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
        createEditActivityPage(
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
      expect(find.text('13:44'), findsOneWidget);

      await tester.enterText(startTimeInputFinder, '0');
      expect(find.text('0'), findsOneWidget);

      await tester.tap(endTimeInputFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('13:44'),
          findsOneWidget); // Time resets when no valid time is entered

      await tester.enterText(endTimeInputFinder, '1111');
      expect(find.text('11:11'), findsOneWidget);

      await tester.enterText(startTimeInputFinder, '0001');
      expect(find.text('00:01'), findsOneWidget);
      await tester.pumpAndSettle();

      await tester.tap(okButtonFinder);
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
        createEditActivityPage(
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
        createEditActivityPage(
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
      await tester.pumpWidget(createEditActivityPage(givenActivity: acivity));
      await tester.pumpAndSettle();
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      await tester.enterText(startTimeInputFinder, '1033');
      await tester.enterText(endTimeInputFinder, '1111');

      await tester.tap(startTimeInputFinder,
          warnIfMissed:
              false); // startTimeInputFinder is below another input widget that catches the tap event
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();
      expect(find.text('10:3-'), findsOneWidget);
    });

    testWidgets(
        'edit activity time with both times and setting removes end time',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityEndTimeEditable: false,
      )));

      final acivity = Activity.createNew(
          title: '',
          startTime: DateTime(2000, 11, 22, 11, 55),
          duration: 3.hours());

      await tester.pumpWidget(createEditActivityPage(givenActivity: acivity));
      await tester.pumpAndSettle();

      // Assert -- that correct start and end time shows
      expect(find.text('11:55 AM - 2:55 PM'), findsOneWidget);

      // Act -- enter time input and cancel
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(cancelButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- that start and end time is the same
      expect(find.text('11:55 AM - 2:55 PM'), findsOneWidget);

      // Act -- enter time input and save
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- old end time does not show
      expect(find.text('11:55 AM - 2:55 PM'), findsNothing);
      expect(find.text('11:55 AM'), findsOneWidget);
    });
  });

  group('Recurrence', () {
    testWidgets('Shows time picker widget ', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(newActivity: true));
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
      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();
      // Assert
      expect(find.byType(RecurrenceTab), findsOneWidget);
      expect(find.byType(TimeIntervallPicker), findsNothing);
    });

    testWidgets('No recurrance selected', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();

      // Assert
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.text(translate.once), findsOneWidget);
    });

    testWidgets('all recurrance present', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(SelectRecurrencePage), findsOneWidget);
      expect(find.text(translate.recurrence), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.text(translate.once), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.week), findsOneWidget);
      expect(find.text(translate.weekly), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsOneWidget);
      expect(find.text(translate.monthly), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.basicActivity), findsOneWidget);
      expect(find.text(translate.yearly), findsOneWidget);
    });

    testWidgets('can change to yearly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
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
      await tester.tap(find.byIcon(AbiliaIcons.basicActivity));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      // Assert -- Yearly selected, not Once
      expect(find.byIcon(AbiliaIcons.day), findsNothing);
      expect(find.text(translate.once), findsNothing);
      expect(find.byIcon(AbiliaIcons.basicActivity), findsOneWidget);
      expect(find.text(translate.yearly), findsOneWidget);
    });

    testWidgets('can change to monthly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
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
      await tester.tap(find.byType(OkButton));
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
      await tester.pumpWidget(createEditActivityPage(
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
      await tester.tap(find.byType(OkButton));
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
      await tester.pumpWidget(createEditActivityPage(
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
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.byType(EndDateWidget));
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
          Recurs.typeWeekly,
          Recurs.allDaysOfWeek,
          startTime.add(30.days()).millisecondsSinceEpoch,
        ),
      );
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        givenActivity: activity,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Assert -- date picker visible
      await tester.scrollDown();
      await tester.tap(find.byType(EndDateWidget));
      expect(find.byType(EndDateWidget), findsOneWidget);
      expect(find.byType(DatePicker), findsOneWidget);
      expect(
        tester.widget<DatePicker>(find.byType(DatePicker)).onChange,
        isNull,
      );
      await tester.tap(find.byType(EndDateWidget));

      expect(
        tester
            .widget<SwitchField>(find.descendant(
                of: find.byType(EndDateWidget),
                matching: find.byType(SwitchField)))
            .onChanged,
        isNull,
      );
    });

    testWidgets(
        'add activity without recurance data tab scrolls back to recurance tab',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(newActivity: true));

      await tester.pumpAndSettle();
      // Arrange -- enter title
      await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField), 'newActivtyTitle');

      // Arrange -- enter start time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(startTimeInputFinder, '0933');
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();
      // Arrange -- set weekly recurance
      await tester.goToRecurrenceTab();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.changeRecurrence));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      // Arrange -- deselect preselect
      await tester.tap(find.text(translate.shortWeekday(startTime.weekday)));
      await tester.goToMainTab();
      await tester.pumpAndSettle();

      expect(find.byType(MainTab), findsOneWidget);

      // Act press submit
      await tester.tap(find.byType(NextWizardStepButton));
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
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityDateEditable: false,
      )));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.byType(DatePicker), findsOneWidget);
      final datePicker =
          tester.widgetList(find.byType(DatePicker)).first as DatePicker;
      expect(datePicker.onChange, isNull);
    });

    testWidgets('Right/left not visible', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityTypeEditable: false,
      )));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      expect(find.byKey(TestKey.leftCategoryRadio), findsNothing);
      expect(find.byKey(TestKey.rightCategoryRadio), findsNothing);
    });

    testWidgets('No end time', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityEndTimeEditable: false,
      )));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      expect(endTimeInputFinder, findsNothing);
    });

    testWidgets('No recurring option', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityRecurringEditable: false,
      )));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(AbiliaIcons.repeat), findsNothing);
    });

    testWidgets('Alarm options', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityDisplayAlarmOption: false,
        activityDisplaySilentAlarmOption: false,
      )));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();

      expect(find.byType(PickField), findsNWidgets(3));
      final alarmPicker =
          tester.widgetList(find.byType(PickField)).first as PickField;

      expect(alarmPicker.onTap, isNull);
    });

    testWidgets('Alarm options - silent option alarm and vibration',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityDisplayAlarmOption: false,
        activityDisplayNoAlarmOption: false,
      )));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();

      expect(find.byType(PickField), findsNWidgets(3));
      final alarmPicker =
          tester.widgetList(find.byType(PickField)).first as PickField;

      expect(alarmPicker.onTap, isNotNull);
      await tester.tap(find.byType(AlarmWidget));
      await tester.pumpAndSettle();

      expect(find.byType(SelectAlarmTypePage), findsOneWidget);

      expect(find.text(translate.silentAlarm), findsOneWidget);
      expect(find.text(translate.vibration), findsOneWidget);
    });

    testWidgets(
        'activityTimeBeforeCurrent true - Cant save when start time is past',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityTimeBeforeCurrent: false,
      )));
      await tester.pumpWidget(
        createEditActivityPage(
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
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextWizardStepButton));
      await tester.pumpAndSettle();

      expect(find.text('15:29'), findsOneWidget);
      expect(find.text(translate.startTimeBeforeNowError), findsOneWidget);
    });

    testWidgets(
        'activityTimeBeforeCurrent true - CAN save when start time is future',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityTimeBeforeCurrent: false,
      )));
      await tester.pumpWidget(
        createEditActivityPage(
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
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextWizardStepButton));
      await tester.pumpAndSettle();

      expect(find.text(translate.startTimeBeforeNowError), findsNothing);
    });

    testWidgets(
        'activityTimeBeforeCurrent true - CAN save recurring when start time is future',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(const MemoplannerSettingsLoaded(MemoplannerSettings(
        activityTimeBeforeCurrent: false,
      )));

      final activity = Activity.createNew(
        title: 't i t l e',
        startTime: startTime.subtract(100.days()),
        recurs: Recurs.everyDay,
      );

      await tester.pumpWidget(
        createEditActivityPage(givenActivity: activity),
      );

      await tester.pumpAndSettle();

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterText(
          startTimeInputFinder, '${startTime.hour + 1}${startTime.minute + 1}');
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextWizardStepButton));
      await tester.pumpAndSettle();

      expect(find.text(translate.startTimeBeforeNowError), findsNothing);
    });

    testWidgets('calendarActivityType-Left/Rigth given name',
        (WidgetTester tester) async {
      const leftCategoryName = 'VÄNSTER',
          rightCategoryName =
              'HÖGER IS SUPER LONG AND WILL PROBABLY OVERFLOW BADLY!';
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            calendarActivityTypeLeft: leftCategoryName,
            calendarActivityTypeRight: rightCategoryName,
          ),
        ),
      );

      await tester.pumpWidget(
        createEditActivityPage(),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -200);

      expect(find.text(leftCategoryName), findsOneWidget);
      expect(find.text(rightCategoryName), findsOneWidget);
    });

    testWidgets('calendarActivityTypeShowTypes false does not show categories',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            calendarActivityTypeShowTypes: false,
          ),
        ),
      );

      await tester.pumpWidget(
        createEditActivityPage(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(CategoryWidget), findsNothing);
      await tester.scrollDown();
      expect(find.byType(CategoryWidget), findsNothing);
    });
  });

  group('tts', () {
    setUp(() async {
      setupFakeTts();
      GetItInitializer()
        ..database = FakeDatabase()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..init();
    });
    testWidgets('title', (WidgetTester tester) async {
      const name = 'new name of a activity';
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byKey(TestKey.editTitleTextFormField),
          exact: translate.name, warnIfMissed: false);

      await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField), name);

      await tester.verifyTts(find.byKey(TestKey.editTitleTextFormField),
          exact: name, warnIfMissed: false);
    });

    testWidgets('image', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byKey(TestKey.addPicture),
          exact: translate.picture);
    });

    testWidgets('date', (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byType(DatePicker),
          contains: translate.today);
    });

    testWidgets('time', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
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
      await tester.tap(okButtonFinder);
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
          createEditActivityPage(
            givenActivity: acivity,
          ),
        );
        await tester.pumpAndSettle();

        // Act -- remove end time
        await tester.tap(timeFieldFinder);
        await tester.pumpAndSettle();

        // Assert
        await tester.verifyTts(
          endTimeInputFinder,
          exact: '${translate.endTime} 02:55 PM',
          warnIfMissed: false,
        );
        await tester.verifyTts(
          startTimeInputFinder,
          exact: '${translate.startTime} 11:55 AM',
          warnIfMissed: false,
        );

        // Act change to period
        await tester.tap(startTimePmRadioFinder);
        await tester.pumpAndSettle();
        await tester.tap(endTimeAmRadioFinder);
        await tester.pumpAndSettle();

        // Assert
        await tester.verifyTts(
          endTimeInputFinder,
          exact: '${translate.endTime} 02:55 AM',
          warnIfMissed: false,
        );
        await tester.verifyTts(
          startTimeInputFinder,
          exact: '${translate.startTime} 11:55 PM',
          warnIfMissed: false,
        );
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
          createEditActivityPage(
            givenActivity: acivity,
            use24H: true,
          ),
        );
        await tester.pumpAndSettle();

        // Act -- remove end time
        await tester.tap(timeFieldFinder);
        await tester.pumpAndSettle();

        // Assert
        await tester.verifyTts(
          startTimeInputFinder,
          exact: '${translate.startTime} 11:55',
          warnIfMissed: false,
        );
        await tester.verifyTts(
          endTimeInputFinder,
          exact: '${translate.endTime} 14:55',
          warnIfMissed: false,
        );
      });

      testWidgets('invalid input tts', (WidgetTester tester) async {
        // Arrange
        final acivity = Activity.createNew(
            title: '', startTime: DateTime(2000, 11, 22, 3, 44));
        await tester.pumpWidget(
          createEditActivityPage(
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
          warnIfMissed: false,
        );
        await tester.verifyTts(
          endTimeInputFinder,
          exact: translate.endTime,
          warnIfMissed: false,
        );
      });
    });

    testWidgets('fullday', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
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
        createEditActivityPage(
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
        createEditActivityPage(
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
        createEditActivityPage(
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
        createEditActivityPage(
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -500);

      await tester.verifyTts(find.byKey(TestKey.availibleFor),
          exact: translate.meAndSupportPersons);

      await tester.tap(find.byKey(TestKey.availibleFor));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byIcon(AbiliaIcons.passwordProtection),
          exact: translate.onlyMe);
    });

    testWidgets('reminders', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();

      await tester.verifyTts(find.byIcon(AbiliaIcons.handiReminder),
          exact: translate.reminders);

      await tester.tap(find.byIcon(AbiliaIcons.handiReminder));
      await tester.pumpAndSettle();

      final reminders = [
        5.minutes(),
        15.minutes(),
        30.minutes(),
        1.hours(),
        2.hours(),
        1.days(),
      ].map((r) => r.toDurationString(translate));

      for (final t in reminders) {
        await tester.verifyTts(find.text(t), exact: t);
      }
    });

    testWidgets('alarms', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
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

      await tester.verifyTts(find.byKey(const ObjectKey(AlarmType.vibration)),
          exact: translate.vibration);
    });

    testWidgets('recurrance', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
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
      await tester.verifyTts(find.byIcon(AbiliaIcons.basicActivity),
          exact: translate.yearly);

      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);

      await tester.verifyTts(find.byType(EndDateWidget),
          exact: translate.noEndDate);
    });

    testWidgets('error view', (WidgetTester tester) async {
      // Act press submit
      await tester.pumpWidget(createEditActivityPage(newActivity: true));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextWizardStepButton));
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
          createEditActivityPage(
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
        when(() => mockUserFileBloc.state)
            .thenReturn(const UserFilesNotLoaded());
        const title1 = 'listtitle1';
        const item1Name = 'Item 1 name';
        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                  data: ChecklistData(Checklist(
                      name: title1,
                      fileId: 'fileid1',
                      questions: const [
                    Question(id: 0, name: item1Name),
                    Question(id: 1, name: '2', fileId: '2222')
                  ]))),
            ],
          ),
        );
        await tester.pumpWidget(
          createEditActivityPage(
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

        await tester.tap(find.byIcon(AbiliaIcons.showText));
        await tester.pumpAndSettle();
        await tester.verifyTts(find.byType(LibraryChecklist), exact: title1);
        await tester.tap(find.byType(LibraryChecklist));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();
        await tester.verifyTts(find.text(item1Name), exact: item1Name);
        await tester.verifyTts(find.byIcon(AbiliaIcons.newIcon),
            exact: translate.addNew);
      });
    });

    testWidgets('note', (WidgetTester tester) async {
      const name = 'Rigel';
      const content =
          'is a blue supergiant star in the constellation of Orion, approximately 860 light-years (260 pc) from Earth. It is the brightest and most massive component of a star system of at least four stars that appear as a single blue-white point of light to the naked eye. A star of spectral type B8Ia, Rigel is calculated to be anywhere from 61,500 to 363,000 times as luminous as the Sun, and 18 to 24 times as massive. ';
      when(() => mockSortableBloc.state).thenReturn(
        SortablesLoaded(
          sortables: [
            Sortable.createNew<NoteData>(
              data: const NoteData(
                name: name,
                text: content,
              ),
            ),
          ],
        ),
      );

      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToInfoItemTab();
      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.showText));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.text(content), exact: content);
      await tester.tap(find.text(content));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.text(content), exact: content);
      await tester.tap(find.text(content));
      await tester.pumpAndSettle();
    });
  });

  group('Sound on alarm', () {
    testWidgets('Sound selectors show up', (WidgetTester tester) async {
      await tester.pumpWidget(
        createEditActivityPage(
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();
      expect(find.byType(RecordSoundWidget), findsOneWidget);
      expect(find.byType(SelectOrPlaySoundWidget), findsNWidgets(2));
    });
  });
}

extension on WidgetTester {
  Future scrollDown({double dy = -800.0}) async {
    final center = getCenter(find.byType(EditActivityPage));
    await dragFrom(center, Offset(0.0, dy));
    await pump();
  }

  Future goToMainTab() async => goToTab(AbiliaIcons.myPhotos);
  Future goToAlarmTab() async => goToTab(AbiliaIcons.attention);
  Future goToRecurrenceTab() async => goToTab(AbiliaIcons.repeat);
  Future goToInfoItemTab() async => goToTab(AbiliaIcons.attachment);

  Future goToTab(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }
}
