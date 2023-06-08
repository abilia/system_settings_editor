import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/src/unmodifiable_wrappers.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_logging/seagull_logging.dart';

import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';
import '../../../test_helpers/tts.dart';

void main() {
  final startTime = DateTime(2020, 02, 10, 15, 30);
  final today = startTime.onlyDays();
  final startActivity = Activity.createNew(
    title: '',
    startTime: startTime,
  );
  final translate = Locales.language.values.first;

  final timeFieldFinder = find.byType(TimeIntervalPicker);
  final okButtonFinder = find.byType(OkButton);
  final cancelButtonFinder = find.byType(CancelButton);

  late MockSortableBloc mockSortableBloc;
  late MockUserFileBloc mockUserFileBloc;
  late MockTimerCubit mockTimerCubit;
  late MemoplannerSettingsBloc mockMemoplannerSettingsBloc;
  late MockSupportPersonsRepository supportUserRepo;
  late MockSupportPersonsCubit supportPersonsCubit;

  setUpAll(() async {
    registerFallbackValues();
    tz.initializeTimeZones();
    await initializeDateFormatting();
  });

  setUp(() async {
    setupFakeTts();
    mockSortableBloc = MockSortableBloc();
    supportPersonsCubit = MockSupportPersonsCubit();
    when(() => supportPersonsCubit.stream)
        .thenAnswer((_) => const Stream.empty());
    when(() => supportPersonsCubit.state).thenAnswer(
      (_) => SupportPersonsState(
        UnmodifiableSetView(
          {
            const SupportPerson(
              id: 1,
              name: 'name',
              image: 'image',
            ),
          },
        ),
      ),
    );

    when(() => supportPersonsCubit.loadSupportPersons())
        .thenAnswer((_) => Future.value());

    when(() => mockSortableBloc.stream).thenAnswer((_) => const Stream.empty());
    mockUserFileBloc = MockUserFileBloc();

    when(() => mockUserFileBloc.stream).thenAnswer((_) => const Stream.empty());
    mockTimerCubit = MockTimerCubit();
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
      MemoplannerSettingsLoaded(
        const MemoplannerSettings(
          addActivity: AddActivitySettings(
            editActivity: EditActivitySettings(template: false),
          ),
        ),
      ),
    );
    when(() => mockMemoplannerSettingsBloc.stream)
        .thenAnswer((_) => const Stream.empty());

    supportUserRepo = MockSupportPersonsRepository();
    when(() => supportUserRepo.load())
        .thenAnswer((_) => Future.value(const {}));
    GetItInitializer()
      ..fileStorage = FakeFileStorage()
      ..database = FakeDatabase()
      ..analytics = MockSeagullAnalytics()
      ..client = Fakes.client()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..init();
    Bloc.observer =
        BlocLoggingObserver(GetIt.I<SeagullAnalytics>(), isRelease: false);
  });

  tearDown(GetIt.I.reset);

  Widget createEditActivityPage({
    Activity? givenActivity,
    DateTime? day,
    bool use24H = false,
    bool newActivity = false,
    bool isTemplate = false,
  }) {
    final activity = givenActivity ?? startActivity;
    return MaterialApp(
      navigatorObservers: [
        AnalyticNavigationObserver(GetIt.I<SeagullAnalytics>()),
      ],
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
                create: (context) => ClockBloc.fixed(startTime),
              ),
              BlocProvider<MemoplannerSettingsBloc>.value(
                value: mockMemoplannerSettingsBloc,
              ),
              BlocProvider<ActivitiesBloc>(
                create: (_) => ActivitiesBloc(
                  activityRepository: FakeActivityRepository(),
                  syncBloc: FakeSyncBloc(),
                ),
              ),
              BlocProvider<SupportPersonsCubit>(
                create: (_) => supportPersonsCubit,
              ),
              BlocProvider<EditActivityCubit>(
                create: (context) => newActivity
                    ? EditActivityCubit.newActivity(
                        day: today,
                        defaultsSettings: DefaultsAddActivitySettings(
                          alarm: mockMemoplannerSettingsBloc
                              .state.addActivity.defaults.alarm,
                        ),
                        calendarId: 'calendarId',
                      )
                    : EditActivityCubit.edit(
                        ActivityDay(activity, day ?? today),
                      ),
              ),
              BlocProvider<WizardCubit>(
                create: (context) => isTemplate
                    ? TemplateActivityWizardCubit(
                        editActivityCubit: context.read<EditActivityCubit>(),
                        sortableBloc: mockSortableBloc,
                        original: Sortable.createNew(
                          data: BasicActivityDataItem.createNew(),
                        ),
                      )
                    : newActivity
                        ? ActivityWizardCubit.newActivity(
                            supportPersonsCubit: FakeSupportPersonsCubit(),
                            activitiesBloc: context.read<ActivitiesBloc>(),
                            clockBloc: context.read<ClockBloc>(),
                            editActivityCubit:
                                context.read<EditActivityCubit>(),
                            addActivitySettings: context
                                .read<MemoplannerSettingsBloc>()
                                .state
                                .addActivity,
                          )
                        : ActivityWizardCubit.edit(
                            activitiesBloc: context.read<ActivitiesBloc>(),
                            clockBloc: context.read<ClockBloc>(),
                            editActivityCubit:
                                context.read<EditActivityCubit>(),
                            allowPassedStartTime: context
                                .read<MemoplannerSettingsBloc>()
                                .state
                                .addActivity
                                .general
                                .allowPassedStartTime,
                          ),
              ),
              BlocProvider<SortableBloc>.value(value: mockSortableBloc),
              BlocProvider<UserFileBloc>.value(value: mockUserFileBloc),
              BlocProvider<DayPickerBloc>(
                create: (context) => DayPickerBloc(
                  clockBloc: context.read<ClockBloc>(),
                ),
              ),
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
              ),
              BlocProvider<PermissionCubit>(
                create: (context) => PermissionCubit()..checkAll(),
              ),
              BlocProvider<WakeLockCubit>(
                create: (context) => WakeLockCubit(
                  settingsDb: FakeSettingsDb(),
                  battery: FakeBattery(),
                  hasBattery: true,
                ),
              ),
              BlocProvider<TimerCubit>.value(value: mockTimerCubit),
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
              ),
              BlocProvider<VoicesCubit>(
                create: (context) => FakeVoicesCubit(),
              ),
              BlocProvider<DayPartCubit>(
                create: (context) => FakeDayPartCubit(),
              ),
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

    testWidgets('When no support persons do not show available for widget',
        (WidgetTester tester) async {
      when(() => supportPersonsCubit.state)
          .thenAnswer((_) => SupportPersonsState(UnmodifiableSetView({})));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.byType(AvailableForWidget), findsNothing);
      await tester.scrollDown();
      expect(find.byType(AvailableForWidget), findsNothing);
    });

    testWidgets('Can enter text', (WidgetTester tester) async {
      const newActivityTitle = 'activity title';
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.text(newActivityTitle), findsNothing);
      await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField), newActivityTitle);
      expect(find.text(newActivityTitle), findsOneWidget);
    });

    testWidgets(
        'SGC-2200 - When editing an activity from a template, open TimeIntervalPicker '
        'but not edit the start time will not trigger DiscardWarningDialog',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        startTime: startTime,
      );
      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
      await tester.pumpAndSettle();

      // Act - Open TimeIntervalPicker and clock ok without edit
      await tester.scrollDown(dy: -100);
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CancelButton));
      await tester.pumpAndSettle();

      // Assert - No DiscardWarningDialog shows
      expect(find.byType(DiscardWarningDialog), findsNothing);
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
      // Assert -- Full day switch is off
      expect(
          tester
              .widget<Switch>(
                  find.byKey(const ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isFalse);
      // Assert -- Start time, left and right category visible
      expect(timeFieldFinder, findsOneWidget);
      expect(find.byKey(TestKey.leftCategoryRadio), findsOneWidget);
      expect(find.byKey(TestKey.rightCategoryRadio), findsOneWidget);

      // Assert -- can see Alarm tab
      expect(find.byIcon(AbiliaIcons.attention), findsOneWidget);
      await tester.goToAlarmTab();
      // Assert -- alarm tab contains reminders
      expect(find.text(translate.reminders), findsOneWidget);
      await tester.goToMainTab();
      await tester.scrollDown(dy: -150);

      // Act -- set to full day
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();

      // Assert -- Full day switch is on,
      expect(
          tester
              .widget<Switch>(
                  find.byKey(const ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isTrue);
      // Assert -- Start time, left and right category not visible
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
        expect(find.text(translate.vibrationIfAvailable), findsNothing);
        expect(find.byIcon(AbiliaIcons.handiVibration), findsNothing);
        await tester.tap(find.byKey(TestKey.selectAlarm));
        await tester.pumpAndSettle();
        expect(find.byType(SelectAlarmTypePage), findsOneWidget);
        await tester.tap(find.byKey(const ObjectKey(AlarmType.vibration)));
        await tester.pumpAndSettle();
        expect(find.text(translate.vibrationIfAvailable), findsOneWidget);
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
      await tester.scrollDown(dy: -200);
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

    group('Available for dialog', () {
      testWidgets('Available for dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await tester.scrollDown();
        await tester.pumpAndSettle();

        expect(find.byType(AvailableForWidget), findsOneWidget);
        expect(find.text(translate.onlyMe), findsNothing);
        expect(find.byIcon(AbiliaIcons.lock), findsNothing);
        await tester.tap(find.byType(AvailableForWidget));
        await tester.pumpAndSettle();
        expect(find.byType(AvailableForPage), findsOneWidget);
        await tester.tap(find.byIcon(AbiliaIcons.lock));
        await tester.pumpAndSettle();
        expect(find.text(translate.onlyMe), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.lock), findsOneWidget);
      });
    });

    testWidgets('Reminder', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      final reminder15MinFinder =
          find.text(15.minutes().toDurationString(translate));
      final reminderDayFinder = find.text(1.days().toDurationString(translate));
      final remindersAllSelected =
          find.byIcon(AbiliaIcons.radioCheckboxSelected);
      final remindersAll = find.byType(SelectableField);
      final reminderField = find.byType(Reminders);

      // Act -- Go to alarm tab
      await tester.goToAlarmTab();

      // Assert -- all reminders shows
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
      expect(remindersAllSelected, findsNothing);

      // Act -- tap 15 min and day reminder
      await tester.tap(reminder15MinFinder);
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
      expect(reminderField, findsOneWidget);
      expect(remindersAll, findsNWidgets(6));
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
      await tester.tap(find.byType(ChangeInfoItemPicker));
      await tester.pumpAndSettle();
      expect(find.byType(SelectInfoTypePage), findsOneWidget);
      expect(find.byKey(TestKey.infoItemNoneRadio), findsOneWidget);
      expect(find.byKey(TestKey.infoItemChecklistRadio), findsOneWidget);
      expect(find.byKey(TestKey.infoItemNoteRadio), findsOneWidget);
    });

    testWidgets('Change between info items preserves old info item state',
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

      await tester.tap(find.byType(ChangeInfoItemPicker));
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

      await tester.tap(find.byType(ChangeInfoItemPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemChecklistRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      expect(find.text(q1), findsOneWidget);
      expect(find.text(q2), findsOneWidget);
      expect(find.text(q3), findsOneWidget);

      await tester.tap(find.byType(ChangeInfoItemPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.infoItemNoneRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GreenButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ChangeInfoItemPicker));
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

        await tester.tap(find.byType(ChangeInfoItemPicker));
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

        await tester.tap(find.byType(ChangeInfoItemPicker));
        await tester.pumpAndSettle();

        expect(find.byType(SelectInfoTypePage), findsOneWidget);

        await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
        await tester.tap(find.byType(GreenButton));
        await tester.pumpAndSettle();

        await tester.pumpAndSettle();
        expect(find.byType(SelectInfoTypePage), findsNothing);
        expect(find.text(translate.infoType), findsOneWidget);
        expect(find.text(translate.addNote), findsOneWidget);
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
Mark the un exported and accidentally public setDefaultResponse as deprecated.
Mark the not useful, and not generally used, named function as deprecated.
Produce a meaningful error message if an argument matcher is used outside of stubbing (when) or verification (verify and untilCalled).
4.1.0 
Add a Fake class for implementing a subset of a class API as overrides without misusing the Mock class.
4.0.0 
Replace the dependency on the test package with a dependency on the new test_api package. This dramatically reduces transitive dependencies.

This bump can result in runtime errors when coupled with a version of the test package older than 1.4.0.

3.0.2 
Rollback the test_api part of the 3.0.1 release. This was breaking tests that use Flutter's current test tools, and will instead be released as part of  4.0.0.
3.0.1 
Replace the dependency on the test package with a dependency on the new test_api package. This dramatically reduces transitive dependencies.
Internal improvements to tests and examples.''';
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToNote(tester);

        await tester.tap(find.byType(NoteBlock));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), noteText);
        await tester.pumpAndSettle();
        await tester.verifyTts(
          find.byType(TtsPlayButton),
          exact: noteText,
          useTap: true,
        );
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
        const content = 'No pride like that of an enriched beggar.';

        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<NoteData>(
                data: const NoteData(
                  name: 'NAME',
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
        expect(find.byType(SortableLibrary<NoteData>), findsOneWidget);
        expect(find.byType(LibraryNote), findsWidgets);
        expect(find.text(content), findsOneWidget);
      });

      testWidgets('notes from library is selectable',
          (WidgetTester tester) async {
        const content = 'I have left Act I, for involution'
            'And Act II. There, mired in complexity '
            'I cannot write Act III. ';

        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<NoteData>(
                data: const NoteData(
                  name: 'NAME',
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

        await tester.tap(find.byType(ChangeInfoItemPicker));
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
                questions: const [Question(id: 0, fileId: 'fileId')],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        expect(find.byType(FadeInCalendarImage), findsOneWidget);
      });

      testWidgets('Can open new question dialog', (WidgetTester tester) async {
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToChecklist(tester);

        await tester.tap(find.byIcon(AbiliaIcons.newIcon));
        await tester.pumpAndSettle();

        expect(find.byType(EditQuestionBottomSheet), findsOneWidget);
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
        await tester.tap(find.byKey(TestKey.bottomSheetOKButton));
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.checkboxUnselected), findsNothing);
      });

      testWidgets('Question get name of image', (WidgetTester tester) async {
        // Arrange - Two images and go to checklist
        const imageName = 'yoyoyyo';
        const imageName2 = 'hohohhoho';
        final sortables = [
          Sortable.createNew<ImageArchiveData>(
            data: const ImageArchiveData(name: imageName, fileId: 'sasd'),
          ),
          Sortable.createNew<ImageArchiveData>(
            data: const ImageArchiveData(name: imageName2, fileId: 'ssd'),
          ),
          Sortable.createNew<ImageArchiveData>(
            isGroup: true,
            data: const ImageArchiveData(upload: true),
          ),
        ];
        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: sortables,
          ),
        );

        final mockState = MockUserFileState();
        when(() => mockState.getLoadedByIdOrPath(any(), any(), any()))
            .thenReturn(await _tinyPng());
        when(() => mockUserFileBloc.state).thenReturn(mockState);

        // Act - Open new checklist question
        await tester.pumpWidget(createEditActivityPage());
        await tester.pumpAndSettle();
        await goToChecklist(tester);
        await tester.tap(find.byIcon(AbiliaIcons.newIcon));
        await tester.pumpAndSettle();

        // Expect - Name is empty
        expect(find.text(imageName), findsNothing);
        expect(find.text(imageName2), findsNothing);

        // Act - Select an image
        await tester.tap(find.byType(SelectPictureWidget));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.imageArchiveButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ArchiveImage).first);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        // Expect - Question has taken the name of the image
        expect(find.text(imageName), findsOneWidget);
        expect(find.text(imageName2), findsNothing);
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
        await tester.verifyTts(
          find.byType(TtsPlayButton),
          exact: questionName,
          useTap: true,
        );
        await tester.tap(find.byKey(TestKey.bottomSheetOKButton));
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
            tester.widget<OkButton>(find.byKey(TestKey.bottomSheetOKButton));
        expect(editViewDialogBefore.onPressed, isNull);

        await tester.enterText(find.byType(TextField), questionName);
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsWidgets);

        final editViewDialogAfter =
            tester.widget<OkButton>(find.byKey(TestKey.bottomSheetOKButton));
        expect(editViewDialogAfter.onPressed, isNotNull);
        await tester.tap(find.byKey(TestKey.bottomSheetOKButton));
        await tester.pumpAndSettle();
        expect(find.text(questionName), findsOneWidget);
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

        await tester.tap(find.byIcon(AbiliaIcons.deleteAllClear));
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
        expect(find.byType(SortableToolbar), findsOneWidget);

        await tester.tap(find.text(questions[0]!));
        await tester.pumpAndSettle();
        expect(find.byType(SortableToolbar), findsNothing);

        await tester.tap(find.text(questions[1]!));
        await tester.pumpAndSettle();
        await tester.dragFrom(tester.getCenter(find.byType(EditChecklistView)),
            const Offset(0, -50));
        await tester.pump();
        await tester.tap(find.text(questions[2]!));
        await tester.pumpAndSettle();
        expect(find.byType(SortableToolbar), findsOneWidget);
      });

      testWidgets('Can reorder questions', (WidgetTester tester) async {
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        final question0y = tester.getCenter(find.text(questions[0]!)).dy;
        final question1y = tester.getCenter(find.text(questions[1]!)).dy;
        expect(true, question0y < question1y);

        await tester.tap(find.text(questions[0]!));
        await tester.pumpAndSettle();
        expect(find.byType(SortableToolbar), findsOneWidget);
        await tester.tap(find.byIcon(AbiliaIcons.cursorDown));
        await tester.pumpAndSettle();

        final newQuestion0y = tester.getCenter(find.text(questions[0]!)).dy;
        final newQuestion1y = tester.getCenter(find.text(questions[1]!)).dy;
        expect(true, newQuestion0y > newQuestion1y);
      });

      testWidgets('Can edit question', (WidgetTester tester) async {
        const newQuestionName = 'One who has control over his pants';
        await tester.pumpWidget(
            createEditActivityPage(givenActivity: activityWithChecklist));
        await tester.pumpAndSettle();
        await tester.goToInfoItemTab();

        await tester.tap(find.text(questions[0]!));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.edit));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), newQuestionName);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.bottomSheetOKButton));
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
        await tester.scrollDown();
        await tester.pumpAndSettle();
        await tester.tap(find.text(questions[1]!));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.edit));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), newQuestionName);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.bottomSheetOKButton));
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
        const title1 = 'listTitle1';
        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                  sortOrder: startChar,
                  data: ChecklistData(Checklist(
                      name: title1,
                      fileId: 'fileId1',
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
        expect(find.byType(SortableLibrary<ChecklistData>), findsOneWidget);
        expect(find.byType(ChecklistLibraryPage), findsWidgets);
        expect(find.text(title1), findsOneWidget);
      });

      testWidgets('checklist from library is selectable',
          (WidgetTester tester) async {
        when(() => mockUserFileBloc.state)
            .thenReturn(const UserFilesNotLoaded());
        const title1 = 'listTitle1';
        const checklistTitle1 = 'checklistTitle1',
            checklistTitle2 = 'checklistTitle2';
        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                data: ChecklistData(
                  Checklist(
                    name: title1,
                    fileId: 'fileId1',
                    questions: const [
                      Question(id: 0, name: checklistTitle1),
                      Question(id: 1, name: checklistTitle2, fileId: '2222')
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
        expect(find.text(checklistTitle1), findsOneWidget);
        expect(find.text(checklistTitle2), findsOneWidget);
        expect(find.byType(ChecklistView), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.checkboxUnselected), findsNothing);
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

      // Expect - MonthDayViewCompact not used in date picker
      expect(find.byType(MonthDayViewCompact), findsNothing);
      expect(find.byType(MonthDayView), findsWidgets);

      await tester.tap(find.ancestor(
          of: find.text('14'), matching: find.byKey(TestKey.monthCalendarDay)));
      await tester.pumpAndSettle();

      expect(find.byType(MonthDayViewCompact), findsNothing);
      expect(find.byType(MonthDayView), findsWidgets);

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
      expect(find.byKey(TestKey.monthCalendarDay), findsNWidgets(29));

      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();

      expect(find.text('January'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
      expect(find.byKey(TestKey.monthCalendarDay), findsNWidgets(31));

      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();

      expect(find.text('April'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
      expect(find.byKey(TestKey.monthCalendarDay), findsNWidgets(30));

      await tester.tap(find.byType(GoToTodayButton));
      await tester.pumpAndSettle();
      expect(find.text('February'), findsOneWidget);
      expect(find.text('2020'), findsOneWidget);
    });

    testWidgets('changes date then add recurring sets end date to no end',
        (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.text('(Today) February 10, 2020'), findsOneWidget);

      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
          of: find.text('14'), matching: find.byKey(TestKey.monthCalendarDay)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      expect(find.text('February 14, 2020'), findsOneWidget);
    });

    testWidgets(
        'changes date after added recurring does not set end date to start date',
        (WidgetTester tester) async {
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -1000);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();
      expect(
          find.descendant(of: find.byType(DatePicker), matching: find.text('')),
          findsOneWidget);
      await tester.goToMainTab();
      // Act change start date to 14th
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
          of: find.text('14'), matching: find.byKey(TestKey.monthCalendarDay)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await tester.goToRecurrenceTab();
      await tester.scrollDown(dy: -250);
      expect(find.text('February 14, 2020'), findsNothing);
      expect(
          find.descendant(of: find.byType(DatePicker), matching: find.text('')),
          findsOneWidget);
    });

    testWidgets('cant pick recurring end date before start date',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.ancestor(
        of: find.text('3'),
        matching: find.byKey(TestKey.monthCalendarDay),
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

    testWidgets('SGC-1668 full day recurring activity shows correct date',
        (WidgetTester tester) async {
      final activity = Activity.createNew(
          title: 'title',
          startTime: startTime,
          recurs: Recurs.everyDay,
          fullDay: true);
      await tester.pumpWidget(createEditActivityPage(
          givenActivity: activity, day: startTime.addDays(5)));
      await tester.pumpAndSettle();
      expect(find.text('February 15, 2020'), findsOneWidget);
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
      final activity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 11, 55));
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

      // Act -- tap at start time
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
      await tester.scrollDown(dy: -100);

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
      final activity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 11, 55));
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

      // Assert -- that the activities start time shows
      expect(find.text('9:33 AM'), findsNothing);
      expect(find.text('11:55 AM'), findsOneWidget);

      // Act -- Change input to new start time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterTime(startTimeInputFinder, '0933');
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- that the activities new start time shows
      expect(find.text('9:33 AM'), findsOneWidget);
    });

    testWidgets('can remove end time', (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
          title: '',
          startTime: DateTime(2000, 11, 22, 11, 55),
          duration: 3.hours());

      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

      // Assert -- that correct start and end time shows
      expect(find.text('11:55 AM - 2:55 PM'), findsOneWidget);

      // Act -- remove end time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(endTimeInputFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithIcon(
          KeyboardActionButton,
          AbiliaIcons.cancel,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- old end time does not show
      expect(find.text('11:55 AM - 2:55 PM'), findsNothing);
      expect(find.text('11:55 AM'), findsOneWidget);
    });

    testWidgets('SGC-1471 - Can edit start time when end time is not visible',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              general: GeneralAddActivitySettings(showEndTime: false),
            ),
          ),
        ),
      );
      final activity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 11, 55));
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

      // Assert -- that the activities start time shows
      expect(find.text('9:33 AM'), findsNothing);
      expect(find.text('11:55 AM'), findsOneWidget);

      // Act -- Change input to new start time to 09:33

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterTime(startTimeInputFinder, '0933');
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- that the activities new start time shows
      expect(find.text('9:33 AM'), findsOneWidget);
    });

    testWidgets('can change am to pm', (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 11, 55));
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

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
      final activity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 12, 55));
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

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

    testWidgets('SGC-1787 start time gives error dialog must enter start time',
        (WidgetTester tester) async {
      // Arrange
      final clear =
          find.widgetWithIcon(KeyboardActionButton, AbiliaIcons.cancel);

      final activity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 3, 44));
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

      // Act -- remove values
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.tap(startTimeInputFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(clear);
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- time is same
      expect(find.byType(ErrorDialog), findsOneWidget);
    });

    testWidgets('Changes focus to endTime when startTime is filled in',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
        title: '',
        startTime: DateTime(2000, 11, 22, 3, 04),
      );
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pump();
      await tester.scrollDown(dy: -100);
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

      await tester.enterTime(startTimeInputFinder, '1111');
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

      await tester.enterTime(endTimeInputFinder, '1112');
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
      final activity = Activity.createNew(
          title: '', startTime: DateTime(2000, 11, 22, 13, 44));
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
          use24H: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

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
      await tester.enterTime(startTimeInputFinder, '0');
      expect(find.text('0'), findsWidgets);

      await tester.tap(endTimeInputFinder, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Type '1111'
      await tester.enterTime(startTimeInputFinder, '1111');
      expect(find.text('11:11'), findsOneWidget); // End time
      expect(find.text('--:--'), findsOneWidget); // Start time

      // Type '0001'
      await tester.enterTime(startTimeInputFinder, '0001');
      expect(find.text('00:01'), findsOneWidget);

      // Tap OK button
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- time is now 00:01
      expect(find.text('00:01 - 13:44'), findsNothing);
    });

    testWidgets('Leading 0 for hour not necessary when entering time',
        (WidgetTester tester) async {
      final activity = Activity.createNew(
        title: '',
        startTime: DateTime(2020, 2, 20, 10, 00),
      );

      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: activity,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterTime(startTimeInputFinder, '9');
      expect(find.text('09:--'), findsOneWidget);
    });

    testWidgets('Delete key just deletes last digit',
        (WidgetTester tester) async {
      final delete =
          find.widgetWithIcon(KeyboardActionButton, AbiliaIcons.delete);
      final activity = Activity.createNew(
        title: '',
        startTime: DateTime(2020, 2, 20, 10, 00),
      );
      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();

      // Type 1033 in start time input field
      await tester.enterTime(startTimeInputFinder, '1033');

      // Type 1111 in end time input field
      await tester.enterTime(endTimeInputFinder, '1111');

      await tester.tap(startTimeInputFinder,
          warnIfMissed:
              false); // startTimeInputFinder is below another input widget that catches the tap event
      await tester.pumpAndSettle();

      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(find.text('10:3-'), findsOneWidget);
    });

    testWidgets(
        'edit activity time with both times and setting removes end time',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(const MemoplannerSettings(
        addActivity: AddActivitySettings(
          general: GeneralAddActivitySettings(showEndTime: false),
        ),
      )));

      final activity = Activity.createNew(
          title: '',
          startTime: DateTime(2000, 11, 22, 11, 55),
          duration: 3.hours());

      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

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
    testWidgets('Does not shows time picker widget on fullDay',
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
      expect(find.byType(TimeIntervalPicker), findsNothing);
    });

    testWidgets('No recurrence selected', (WidgetTester tester) async {
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

    testWidgets('all recurrence present', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        newActivity: true,
      ));
      await tester.pumpAndSettle();
      // Act
      await tester.goToRecurrenceTab();

      // Assert
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
      var radioWidget = tester.firstWidget(
        find.byType(RadioField<RecurrentType>),
      ) as RadioField<RecurrentType>;
      expect(radioWidget.groupValue, RecurrentType.none);

      // Act -- Change to Yearly
      await tester.tap(find.byIcon(AbiliaIcons.basicActivity));
      await tester.pumpAndSettle();

      // Assert -- Yearly selected
      radioWidget = tester.firstWidget(
        find.byType(RadioField<RecurrentType>),
      ) as RadioField<RecurrentType>;
      expect(radioWidget.groupValue, RecurrentType.yearly);
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
      var radioWidget = tester.firstWidget(
        find.byType(RadioField<RecurrentType>),
      ) as RadioField<RecurrentType>;
      expect(radioWidget.groupValue, RecurrentType.none);

      // Act -- Change to Monthly
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      // Assert -- Monthly selected
      radioWidget = tester.firstWidget(
        find.byType(RadioField<RecurrentType>),
      ) as RadioField<RecurrentType>;
      expect(radioWidget.groupValue, RecurrentType.monthly);

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
      var radioWidget = tester.firstWidget(
        find.byType(RadioField<RecurrentType>),
      ) as RadioField<RecurrentType>;
      expect(radioWidget.groupValue, RecurrentType.none);

      // Act -- Change to Weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      // Assert -- Weekly selected
      radioWidget = tester.firstWidget(
        find.byType(RadioField<RecurrentType>),
      ) as RadioField<RecurrentType>;
      expect(radioWidget.groupValue, RecurrentType.weekly);

      expect(find.byType(Weekdays), findsOneWidget);
      expect(find.byType(EndDateWidget), findsOneWidget);
    });

    testWidgets('end date shows when clicking on No end date',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        newActivity: true,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Act -- Change to weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);

      // Assert -- date picker visible
      expect(find.byType(EndDateWidget), findsOneWidget);
      expect(find.byType(DatePicker), findsNothing);
      expect(find.text(translate.noEndDate), findsOneWidget);

      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();

      expect(find.byType(DatePicker), findsOneWidget);
    });

    testWidgets('end date defaults to no end', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        newActivity: true,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Act -- Change to weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);

      // Assert -- end date defaults to unspecified
      expect(
          find.descendant(of: find.byType(DatePicker), matching: find.text('')),
          findsNothing);
      final noEndDateSwitchValue = (find
              .byKey(TestKey.noEndDateSwitch)
              .evaluate()
              .first
              .widget as SwitchField)
          .value;
      expect(noEndDateSwitchValue, isTrue);
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
        'add activity without recurrence data tab scrolls back to recurrence tab',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createEditActivityPage(newActivity: true));

      await tester.pumpAndSettle();
      // Arrange -- enter title
      await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField), 'newActivityTitle');
      await tester.scrollDown(dy: -100);

      // Arrange -- enter start time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterTime(startTimeInputFinder, '0933');
      await tester.pumpAndSettle();
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Arrange -- set weekly recurrence
      await tester.goToRecurrenceTab();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
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

      // Act dismiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      // Assert at Recurrence Tab
      expect(find.byType(RecurrenceTab), findsOneWidget);
    });

    testWidgets('"only this day" when changing end time (Bug SGC-1423)',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity: Activity.createNew(
              title: 'null',
              startTime: startTime,
              duration: const Duration(minutes: 15),
              recurs: Recurs.weeklyOnDay(1),
              alarmType: alarmSoundOnlyOnStart),
          use24H: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

      // Act -- Change end time to 17:00
      await tester.tap(find.byType(TimeIntervalPicker));
      await tester.pumpAndSettle();
      await tester.enterTime(endTimeInputFinder, '1700');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      // Assert correct options
      expect(find.byKey(TestKey.thisDayAndForward), findsOneWidget);
      expect(find.byKey(TestKey.onlyThisDay), findsOneWidget);
    });

    testWidgets('changing recurrence type does not change end date',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(
          title: 'Title',
          startTime: startTime,
          recurs: Recurs.raw(
            Recurs.typeWeekly,
            Recurs.allDaysOfWeek,
            startTime.add(30.days()).millisecondsSinceEpoch,
          ));

      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Act -- Change to monthly
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      // Assert -- end date is still 30 days after startTime
      expect(find.text('March 11, 2020'), findsOneWidget);
    });

    testWidgets('SGC-1721 setting recurrence requires specifying end date',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(title: 'Title', startTime: startTime);

      await tester.pumpWidget(createEditActivityPage(
        givenActivity: activity,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Assert -- Once selected
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.text(translate.once), findsOneWidget);

      // Act -- Change to weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(
          find.text(translate.endDateNotSpecifiedErrorMessage), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.scrollDown(dy: 250);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(
          find.text(translate.endDateNotSpecifiedErrorMessage), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.scrollDown();

      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.ancestor(
        of: find.text('25'),
        matching: find.byKey(TestKey.monthCalendarDay),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorDialog), findsNothing);
    });

    testWidgets('SGC-1721 yearly recurrence requires no end date',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(title: 'Title', startTime: startTime);

      await tester.pumpWidget(createEditActivityPage(
        givenActivity: activity,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Assert -- Once selected
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.text(translate.once), findsOneWidget);

      // Act -- Change to weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(
          find.text(translate.endDateNotSpecifiedErrorMessage), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.scrollDown(dy: 250);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.yearly));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsNothing);
    });

    testWidgets('Changing week days retains end date',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(title: 'Title', startTime: startTime);

      await tester.pumpWidget(createEditActivityPage(
        givenActivity: activity,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Act -- Change to weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      await tester.scrollDown(dy: -250);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DatePicker));
      await tester.pumpAndSettle();

      await tester.tap(find.ancestor(
        of: find.text('17'),
        matching: find.byKey(TestKey.monthCalendarDay),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);

      expect(find.text('February 17, 2020'), findsOneWidget);

      await tester.tap(find.text('Thu'));
      await tester.tap(find.text('Sun'));

      await tester.pumpAndSettle();

      expect(find.text('February 17, 2020'), findsOneWidget);

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();
    });

    testWidgets(
        'Changing week days with no date set does not remove DatePicker',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(title: 'Title', startTime: startTime);

      await tester.pumpWidget(createEditActivityPage(
        givenActivity: activity,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Act -- Change to weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Thu'));
      await tester.tap(find.text('Sun'));

      await tester.pumpAndSettle();

      await tester.scrollDown(dy: -250);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();
      expect(find.byType(DatePicker), findsOneWidget);

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();
    });

    testWidgets('SGC-1845 - Changing end date does not reset selected days',
        (WidgetTester tester) async {
      // Arrange
      final activity = Activity.createNew(title: 'Title', startTime: startTime);

      await tester.pumpWidget(createEditActivityPage(
        givenActivity: activity,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Act -- Change to Monthly
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      // Assert -- One day selected
      expect(find.byIcon(AbiliaIcons.radioCheckboxSelected), findsNWidgets(1));

      // Act -- Select two more days
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();
      // Assert -- Three days selected
      expect(find.byIcon(AbiliaIcons.radioCheckboxSelected), findsNWidgets(3));

      // Act -- Change end date
      await tester.scrollDown(dy: -250);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.calendar));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      // Assert -- Still three days selected
      expect(find.byIcon(AbiliaIcons.radioCheckboxSelected), findsNWidgets(3));
    });

    testWidgets(
        'SGC-1926 - Changing from yearly to weekly or monthly changes end date to No End',
        (WidgetTester tester) async {
      bool endDateSwitchOn() =>
          (tester.firstWidget(find.byKey(TestKey.noEndDateSwitch))
                  as SwitchField)
              .value;

      // Arrange
      await tester.pumpWidget(createEditActivityPage(
        newActivity: true,
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.goToRecurrenceTab();

      // Assert -- Once selected
      final radioWidget = tester.firstWidget(
        find.byType(RadioField<RecurrentType>),
      ) as RadioField<RecurrentType>;
      expect(radioWidget.groupValue, RecurrentType.none);

      // Act -- Change to Weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      // Assert -- End date is not set
      expect(endDateSwitchOn(), true);
      expect(find.byType(DatePicker), findsNothing);

      // Act -- Change to Yearly
      await tester.tap(find.text(RecurrentType.yearly.text(translate)));
      await tester.pumpAndSettle();

      // Act -- Change to back Weekly
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      // Assert -- End date is not set
      expect(endDateSwitchOn(), true);
      expect(find.byType(DatePicker), findsNothing);
    });
  });

  group('Memoplanner settings -', () {
    testWidgets('Select name off', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(title: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      final namePictureW = tester.widget<NameAndPictureWidget>(
        find.byType(NameAndPictureWidget),
      );
      expect(namePictureW.onTextEdit, isNull);
      await tester.tap(find.byType(NameInput));
      await tester.pumpAndSettle();
      expect(find.byType(DefaultTextInput), findsNothing);
    });

    testWidgets('Select image off', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(image: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      final namePictureW = tester.widget<NameAndPictureWidget>(
        find.byType(NameAndPictureWidget),
      );
      expect(namePictureW.onImageSelected, isNull);
      await tester.tap(find.byType(SelectPictureWidget));
      await tester.pumpAndSettle();
      expect(find.byType(SelectPicturePage), findsNothing);
    });

    testWidgets('Date picker not available when setting says so',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(date: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      expect(find.byType(DatePicker), findsOneWidget);
      final datePicker =
          tester.widgetList(find.byType(DatePicker)).first as DatePicker;
      expect(datePicker.onChange, isNull);
    });

    testWidgets('category not visible - category show settings',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            calendar: GeneralCalendarSettings(
              categories: CategoriesSettings(show: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      expect(find.byKey(TestKey.leftCategoryRadio), findsNothing);
      expect(find.byKey(TestKey.rightCategoryRadio), findsNothing);
    });

    testWidgets('No end time', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(const MemoplannerSettings(
        addActivity: AddActivitySettings(
          general: GeneralAddActivitySettings(showEndTime: false),
        ),
      )));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      expect(endTimeInputFinder, findsNothing);
    });

    testWidgets('No Available For', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(availability: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.scrollDown();

      expect(find.byType(AvailableForWidget), findsNothing);
    });

    testWidgets('No Checkable', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(checkable: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.scrollDown();

      expect(find.byKey(TestKey.checkableSwitch), findsNothing);
    });

    testWidgets('No Remove after', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(removeAfter: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.scrollDown();

      expect(find.byKey(TestKey.deleteAfterSwitch), findsNothing);
    });

    testWidgets('No recurring option', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state)
          .thenReturn(MemoplannerSettingsLoaded(const MemoplannerSettings(
        addActivity: AddActivitySettings(
          general: GeneralAddActivitySettings(addRecurringActivity: false),
        ),
      )));
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(AbiliaIcons.repeat), findsNothing);
    });

    testWidgets('Alarm options, only one option', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              general: GeneralAddActivitySettings(
                showAlarm: false,
                showSilentAlarm: false,
                showVibrationAlarm: false,
              ),
            ),
          ),
        ),
      );
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
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              general: GeneralAddActivitySettings(
                showAlarm: false,
                showNoAlarm: false,
              ),
            ),
          ),
        ),
      );
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
      expect(find.text(translate.vibrationIfAvailable), findsOneWidget);
    });

    testWidgets('Alarm options - alarm only at start time',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              general: GeneralAddActivitySettings(
                showAlarmOnlyAtStart: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();

      expect(find.byType(AlarmOnlyAtStartSwitch), findsNothing);
    });

    testWidgets('Show speech at alarm', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              general: GeneralAddActivitySettings(
                showSpeechAtAlarm: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();

      expect(find.byType(RecordSoundWidget), findsNothing);
    });

    testWidgets(
        'activityTimeBeforeCurrent true - Cant save when start time is past',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              general: GeneralAddActivitySettings(allowPassedStartTime: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        createEditActivityPage(
          use24H: true,
          givenActivity:
              Activity.createNew(title: 't i t l e', startTime: startTime),
        ),
      );

      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      final startTimeBefore = '${startTime.hour}${startTime.minute - 1}';
      await tester.enterTime(
        startTimeInputFinder,
        startTimeBefore,
      );
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
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              general: GeneralAddActivitySettings(allowPassedStartTime: false),
            ),
          ),
        ),
      );
      await tester.pumpWidget(
        createEditActivityPage(
          givenActivity:
              Activity.createNew(title: 't i t l e', startTime: startTime),
        ),
      );

      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

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
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              general: GeneralAddActivitySettings(allowPassedStartTime: false),
            ),
          ),
        ),
      );

      final activity = Activity.createNew(
        title: 't i t l e',
        startTime: startTime.subtract(100.days()),
        recurs: Recurs.everyDay,
      );

      await tester.pumpWidget(
        createEditActivityPage(givenActivity: activity),
      );

      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

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

    testWidgets('calendarActivityType-Left/Right given name',
        (WidgetTester tester) async {
      const leftCategoryName = 'LEFT',
          rightCategoryName =
              'RIGHT IS SUPER LONG AND WILL PROBABLY OVERFLOW BADLY!';
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            calendar: GeneralCalendarSettings(
              categories: CategoriesSettings(
                left: ImageAndName(leftCategoryName, AbiliaFile.empty),
                right: ImageAndName(rightCategoryName, AbiliaFile.empty),
              ),
            ),
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
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            calendar: GeneralCalendarSettings(
              categories: CategoriesSettings(show: false),
            ),
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

    testWidgets('Select Alarm off', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(alarm: false),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();

      // Assert -- Alarm options hidden
      expect(find.byType(AlarmWidget), findsNothing);
    });

    testWidgets('Select Reminders off', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(reminders: false),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToAlarmTab();
      await tester.pumpAndSettle();

      // Assert -- Reminder options hidden
      expect(find.text(translate.reminders), findsNothing);
    });

    testWidgets('Select Checklist off', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(checklist: false),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToInfoItemTab();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PickInfoItem));
      await tester.pumpAndSettle();

      // Assert -- Checklist option hidden
      expect(find.text(translate.addChecklist), findsNothing);
    });

    testWidgets('Select Notes off', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(notes: false),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();
      await tester.goToInfoItemTab();
      await tester.pumpAndSettle();
      await tester.tap(find.byType(PickInfoItem));
      await tester.pumpAndSettle();

      // Assert -- Notes option hidden
      expect(find.text(translate.addNote), findsNothing);
    });

    testWidgets(
        'Alarm tab hidden when Alarm, Reminders and Speech options are all hidden ',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(
                alarm: false,
                reminders: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createEditActivityPage(isTemplate: true));
      await tester.pumpAndSettle();

      // Assert -- Alarm tab hidden
      expect(find.byIcon(AbiliaIcons.attention), findsNothing);
    });

    testWidgets('Extra tab hidden when Notes and Checklist options are hidden ',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(
                notes: false,
                checklist: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      // Assert -- Extra tab hidden
      expect(find.byIcon(AbiliaIcons.attachment), findsNothing);
    });

    testWidgets('Full day off', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(
                fullDay: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createEditActivityPage());
      await tester.pumpAndSettle();

      expect(find.byKey(const ObjectKey(TestKey.fullDaySwitch)), findsNothing);
    });

    testWidgets('Activity is full day and full day is off shows no heading',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          const MemoplannerSettings(
            addActivity: AddActivitySettings(
              editActivity: EditActivitySettings(
                fullDay: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpWidget(createEditActivityPage(
          givenActivity: Activity.createNew(
              title: 'Title', startTime: startTime, fullDay: true)));
      await tester.pumpAndSettle();

      expect(find.text(translate.time), findsNothing);
    });
  });

  group('tts', () {
    setUp(() {
      setupFakeTts();
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
      await tester.scrollDown(dy: -100);

      // Assert -- that the activities time shows
      await tester.verifyTts(timeFieldFinder, exact: translate.time);

      // Act -- Change time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterTime(startTimeInputFinder, '0933');
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
      testWidgets('start/endTime 12h', (WidgetTester tester) async {
        // Arrange
        final activity = Activity.createNew(
            title: '',
            startTime: DateTime(2000, 11, 22, 11, 55),
            duration: 3.hours());

        await tester.pumpWidget(
          createEditActivityPage(
            givenActivity: activity,
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollDown(dy: -100);

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

      testWidgets('start/endTime 24h', (WidgetTester tester) async {
        // Arrange
        Intl.defaultLocale = 'sv_SE';
        addTearDown(() => Intl.defaultLocale = null);
        final activity = Activity.createNew(
            title: '',
            startTime: DateTime(2000, 11, 22, 11, 55),
            duration: 3.hours());

        await tester.pumpWidget(
          createEditActivityPage(
            givenActivity: activity,
            use24H: true,
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollDown(dy: -100);

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
        final activity = Activity.createNew(
            title: '', startTime: DateTime(2000, 11, 22, 3, 44));
        await tester.pumpWidget(
          createEditActivityPage(
            givenActivity: activity,
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollDown(dy: -100);

        // Act -- remove values
        await tester.tap(timeFieldFinder);
        await tester.pumpAndSettle();
        await tester.enterTime(startTimeInputFinder, '1');
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

    testWidgets('fullDay', (WidgetTester tester) async {
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
      await tester.scrollDown(dy: -200);

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
      await tester.scrollDown(dy: -400);

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

    testWidgets('available for', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -550);

      await tester.verifyTts(find.byType(AvailableForWidget),
          exact: translate.allSupportPersons);

      await tester.tap(find.byType(AvailableForWidget));
      await tester.pumpAndSettle();

      await tester.verifyTts(find.byIcon(AbiliaIcons.lock),
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
          exact: translate.vibrationIfAvailable);
    });

    testWidgets('recurrence', (WidgetTester tester) async {
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
      await tester.verifyTts(find.byIcon(AbiliaIcons.week),
          exact: translate.weekly);
      await tester.verifyTts(find.byIcon(AbiliaIcons.month),
          exact: translate.monthly);
      await tester.verifyTts(find.byIcon(AbiliaIcons.basicActivity),
          exact: translate.yearly);

      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -350);

      await tester.verifyTts(find.byType(EndDateWidget),
          exact: translate.noEndDate);
    });

    testWidgets('Correct day colors in recurrence tab',
        (WidgetTester tester) async {
      void expectSelectableFieldColor(int dayNum, Color color) {
        expect(
            (find.byType(SelectableField).evaluate().elementAt(dayNum).widget
                    as SelectableField)
                .color,
            color);
      }

      // Arrange
      await tester.pumpWidget(
        createEditActivityPage(
          newActivity: true,
        ),
      );
      await tester.pumpAndSettle();
      await tester.goToRecurrenceTab();

      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      // Check day colors for Selectable fields: Mon, Tue, Wen, Thu, Fri, Sat, Sun
      expectSelectableFieldColor(0, AbiliaColors.green);
      expectSelectableFieldColor(1, AbiliaColors.blue);
      expectSelectableFieldColor(2, AbiliaColors.white110);
      expectSelectableFieldColor(3, AbiliaColors.thursdayBrown);
      expectSelectableFieldColor(4, AbiliaColors.yellow);
      expectSelectableFieldColor(5, AbiliaColors.pink);
      expectSelectableFieldColor(6, AbiliaColors.sundayRed);
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
        await tester.tap(find.byType(ChangeInfoItemPicker));
        await tester.pumpAndSettle();

        await tester.verifyTts(find.byKey(TestKey.infoItemNoneRadio),
            exact: translate.infoTypeNone);
        await tester.verifyTts(find.byKey(TestKey.infoItemChecklistRadio),
            exact: translate.addChecklist);
        await tester.verifyTts(find.byKey(TestKey.infoItemNoteRadio),
            exact: translate.addNote);
      });

      testWidgets('checklist', (WidgetTester tester) async {
        // Arrange
        when(() => mockUserFileBloc.state)
            .thenReturn(const UserFilesNotLoaded());
        const title1 = 'listTitle1';
        const item1Name = 'Item 1 name';
        when(() => mockSortableBloc.state).thenReturn(
          SortablesLoaded(
            sortables: [
              Sortable.createNew<ChecklistData>(
                  data: ChecklistData(Checklist(
                      name: title1,
                      fileId: 'fileId1',
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
        await tester.tap(find.byType(ChangeInfoItemPicker));
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
      await tester.tap(find.byType(ChangeInfoItemPicker));
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

  testWidgets("TabBar doesn't show when there is only one tab",
      (WidgetTester tester) async {
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
      MemoplannerSettingsLoaded(
        const MemoplannerSettings(
          addActivity: AddActivitySettings(
            mode: AddActivityMode.editView,
            editActivity: EditActivitySettings(
              alarm: false,
              checklist: false,
              notes: false,
              reminders: false,
            ),
            general: GeneralAddActivitySettings(
              showSpeechAtAlarm: false,
              addRecurringActivity: false,
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(createEditActivityPage());
    await tester.pumpAndSettle();
    expect(find.byType(AbiliaAppBar), findsOneWidget);
    expect(find.byType(AbiliaTabBar), findsNothing);
  });

  group('Correcting errors', () {
    Future<void> saveAndDismissErrorDialog(WidgetTester tester) async {
      // Act -- Save and dismiss error dialog
      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();
      final prevButton = tester.firstWidget(find.descendant(
          of: find.byType(ErrorDialog), matching: find.byType(PreviousButton)));
      await tester.tap(find.byWidget(prevButton));
      await tester.pumpAndSettle();
    }

    testWidgets('Error marking is removed after adding recurring days - weekly',
        (WidgetTester tester) async {
      Weekly weeklyFinder() {
        return tester.firstWidget(find.byType(Weekly)) as Weekly;
      }

      // Arrange
      final activity = Activity.createNew(title: 'Title', startTime: startTime);
      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
      await tester.pumpAndSettle();

      // Act -- Change to weekly
      await tester.goToRecurrenceTab();
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);

      // Assert -- Error marker is not shown before trying to save
      expect(weeklyFinder().errorState, false);

      // Act -- Deselect all days
      final allSelectedDaysWidgets = tester.widgetList(
        find.descendant(
          of: find.byType(Weekdays),
          matching: find.byWidgetPredicate(
            (w) => w is SelectableField && w.selected,
          ),
        ),
      );

      for (var weekday in allSelectedDaysWidgets) {
        await tester.tap(find.byWidget(weekday));
        await tester.pumpAndSettle();
      }

      // Act -- Save and dismiss error dialog
      await saveAndDismissErrorDialog(tester);

      // Assert -- Error marker is shown
      expect(weeklyFinder().errorState, true);

      // Act -- Add a weekday
      await tester.tap(
        find
            .descendant(
              of: find.byType(Weekdays),
              matching: find.byWidgetPredicate((w) => w is SelectableField),
            )
            .first,
      );
      await tester.pumpAndSettle();

      // Assert -- Error marker is not shown after adding a weekday
      expect(weeklyFinder().errorState, false);
    });

    testWidgets(
        'Error marking is removed after adding recurring days - monthly',
        (WidgetTester tester) async {
      bool monthDaysAreErrorDecorated() {
        final container = tester.firstWidget(
          find.ancestor(
            of: find.byType(MonthDays),
            matching: find.byWidgetPredicate((w) => w is Container),
          ),
        ) as Container;

        return container.decoration == errorBoxDecoration;
      }

      // Arrange
      final activity = Activity.createNew(title: 'Title', startTime: startTime);
      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
      await tester.pumpAndSettle();

      // Act -- Change to monthly
      await tester.goToRecurrenceTab();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);

      // Assert -- Error marker is not shown before trying to save
      expect(monthDaysAreErrorDecorated(), false);

      // Act -- Deselect all days
      final allSelectedDaysWidgets = tester.widgetList(
        find.descendant(
          of: find.byType(MonthDays),
          matching: find.byWidgetPredicate(
            (w) => w is SelectableField && w.selected,
          ),
        ),
      );

      for (var monthDay in allSelectedDaysWidgets) {
        await tester.tap(find.byWidget(monthDay));
        await tester.pumpAndSettle();
      }

      // Act -- Save and dismiss error dialog
      await saveAndDismissErrorDialog(tester);

      // Assert -- Error marker is shown
      expect(monthDaysAreErrorDecorated(), true);

      // Act -- Add a month day
      await tester.tap(
        find
            .descendant(
              of: find.byType(MonthDays),
              matching: find.byWidgetPredicate((w) => w is SelectableField),
            )
            .first,
      );
      await tester.pumpAndSettle();

      // Assert -- Error marker is not shown after adding a month day
      expect(monthDaysAreErrorDecorated(), false);
    });

    testWidgets('Error marking is removed after adding recurring end date',
        (WidgetTester tester) async {
      bool endDateIsErrorDecorated() {
        return (tester.firstWidget(find.byType(EndDateWidget)) as EndDateWidget)
            .errorState;
      }

      // Arrange
      final activity = Activity.createNew(title: 'Title', startTime: startTime);
      await tester.pumpWidget(createEditActivityPage(givenActivity: activity));
      await tester.pumpAndSettle();

      // Act -- Change to monthly
      await tester.goToRecurrenceTab();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -250);
      await tester.tap(find.text(translate.noEndDate));
      await tester.pumpAndSettle();

      // Assert -- Error marker is not shown before trying to save
      expect(endDateIsErrorDecorated(), false);

      // Act -- Save and dismiss error dialog
      await saveAndDismissErrorDialog(tester);

      // Assert -- Error marker is shown
      expect(endDateIsErrorDecorated(), true);

      // Act -- Add an end date
      await tester.tap(find.byIcon(AbiliaIcons.calendar));
      await tester.pumpAndSettle();
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      // Assert -- Error marker is not shown after adding end date
      expect(endDateIsErrorDecorated(), false);
    });

    testWidgets('Error marking is removed after adding title',
        (WidgetTester tester) async {
      bool nameAndPictureIsErrorDecorated() {
        return (tester.firstWidget(find.byType(NameAndPictureWidget))
                as NameAndPictureWidget)
            .errorState;
      }

      // Arrange
      await tester.pumpWidget(createEditActivityPage(newActivity: true));
      await tester.pumpAndSettle();

      // Assert -- Error marker is not shown before trying to save
      expect(nameAndPictureIsErrorDecorated(), false);

      // Act -- Save and dismiss error dialog
      await saveAndDismissErrorDialog(tester);

      // Assert -- Error marker is shown
      expect(nameAndPictureIsErrorDecorated(), true);

      // Act -- Enter title
      await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField),
        'activityTitle',
      );

      // Assert -- Error marker is not shown after entering a title
      expect(nameAndPictureIsErrorDecorated(), false);
    });

    testWidgets('Error marking is removed after adding start time',
        (WidgetTester tester) async {
      bool timeIntervalIsErrorDecorated() {
        return (tester.firstWidget(timeFieldFinder) as TimeIntervalPicker)
            .startTimeError;
      }

      // Arrange
      await tester.pumpWidget(createEditActivityPage(newActivity: true));
      await tester.pumpAndSettle();
      await tester.scrollDown(dy: -100);

      // Assert -- Error marker is not shown before trying to save
      expect(timeIntervalIsErrorDecorated(), false);

      // Act -- Save and dismiss error dialog
      await saveAndDismissErrorDialog(tester);

      // Assert -- Error marker is shown
      expect(timeIntervalIsErrorDecorated(), true);

      // Act -- Enter start time
      await tester.tap(timeFieldFinder);
      await tester.pumpAndSettle();
      await tester.enterTime(startTimeInputFinder, '1100');
      await tester.tap(okButtonFinder);
      await tester.pumpAndSettle();

      // Assert -- Error marker is not shown after entering a start time
      expect(timeIntervalIsErrorDecorated(), false);
    });
  });

  testWidgets('Analytics are correct when creating a new activity',
      (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(createEditActivityPage(
      newActivity: true,
    ));
    await tester.pumpAndSettle();

    await tester.goToAlarmTab();

    await tester.goToRecurrenceTab();

    await tester.goToInfoItemTab();

    await tester.goToMainTab();

    await tester.tap(find.byType(SaveButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PreviousButton).last);
    await tester.pumpAndSettle();

    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivityTitle');
    await tester.scrollDown(dy: -100);

    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterTime(startTimeInputFinder, '0330');
    await tester.pumpAndSettle();
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SaveButton));
    await tester.pumpAndSettle();

    final expectedActivity = Activity.createNew(
        startTime: startTime, title: 'newActivityTitle', timezone: 'UTC');
    final expectedProperties = AddActivity(expectedActivity).properties;

    final mockAnalytics = GetIt.I<SeagullAnalytics>() as MockSeagullAnalytics;
    verifyInOrder([
      () => mockAnalytics.trackNavigation(
            page: (EditActivityPage).toString(),
            action: NavigationAction.viewed,
          ),
      () => mockAnalytics.trackNavigation(
            page: (MainTab).toString(),
            action: NavigationAction.viewed,
          ),
      () => mockAnalytics.trackNavigation(
            page: (AlarmAndReminderTab).toString(),
            action: NavigationAction.viewed,
          ),
      () => mockAnalytics.trackNavigation(
            page: (RecurrenceTab).toString(),
            action: NavigationAction.viewed,
          ),
      () => mockAnalytics.trackNavigation(
            page: (InfoItemTab).toString(),
            action: NavigationAction.viewed,
          ),
      () => mockAnalytics.trackNavigation(
            page: (MainTab).toString(),
            action: NavigationAction.viewed,
          ),
      () => mockAnalytics.trackNavigation(
            page: (ErrorDialog).toString(),
            action: NavigationAction.opened,
            properties: {
              'save errors': [
                SaveError.noTitleOrImage.name,
                SaveError.noStartTime.name,
              ],
            },
          ),
      () => mockAnalytics.trackNavigation(
            page: (ErrorDialog).toString(),
            action: NavigationAction.closed,
            properties: {
              'save errors': [
                SaveError.noTitleOrImage.name,
                SaveError.noStartTime.name,
              ],
            },
          ),
      () => mockAnalytics.trackNavigation(
            page: (DefaultTextInput).toString(),
            action: NavigationAction.opened,
          ),
      () => mockAnalytics.trackNavigation(
            page: (DefaultTextInput).toString(),
            action: NavigationAction.closed,
          ),
      () => mockAnalytics.trackNavigation(
            page: (TimeInputPage).toString(),
            action: NavigationAction.opened,
          ),
      () => mockAnalytics.trackNavigation(
            page: (TimeInputPage).toString(),
            action: NavigationAction.closed,
          ),
      () => mockAnalytics.trackEvent(
            AnalyticsEvents.activityCreated,
            properties: expectedProperties,
          ),
    ]);
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

Future<File> _tinyPng() async {
  final bytes = Uint8List.fromList([
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    10,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    0,
    1,
    0,
    0,
    5,
    0,
    1,
    13,
    10,
    45,
    180,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130
  ]);

  return MemoryFileSystem().file('test.png')..writeAsBytesSync(bytes);
}
