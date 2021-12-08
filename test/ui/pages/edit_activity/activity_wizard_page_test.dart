import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  final startTime = DateTime(2021, 09, 22, 12, 46);
  final today = startTime.onlyDays();
  final translate = Locales.language.values.first;

  late MockSortableBloc mockSortableBloc;
  late MockUserFileBloc mockUserFileBloc;
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
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
      const MemoplannerSettingsLoaded(
        MemoplannerSettings(
          addActivityTypeAdvanced: false,
        ),
      ),
    );
    when(() => mockMemoplannerSettingsBloc.stream).thenAnswer(
      (_) => const Stream.empty(),
    );
  });

  Widget wizardPage({
    bool use24H = false,
  }) {
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
                create: (context) => EditActivityBloc.newActivity(
                  day: today,
                  defaultAlarmTypeSetting:
                      mockMemoplannerSettingsBloc.state.defaultAlarmTypeSetting,
                ),
              ),
              BlocProvider<ActivityWizardCubit>(
                create: (context) => ActivityWizardCubit.newActivity(
                  activitiesBloc: context.read<ActivitiesBloc>(),
                  clockBloc: context.read<ClockBloc>(),
                  editActivityBloc: context.read<EditActivityBloc>(),
                  settings: context.read<MemoplannerSettingBloc>().state,
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
            ],
            child: child!,
          ),
        ),
      ),
      home: const ActivityWizardPage(),
    );
  }

  testWidgets('wizard shows all steps', (WidgetTester tester) async {
    await tester.pumpWidget(wizardPage());
    await tester.pumpAndSettle();

    expect(find.byType(ActivityWizardPage), findsOneWidget);
    expect(find.byType(BasicActivityStepPage), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(TitleWiz), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'title');
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(ImageWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(AvailableForWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(CheckableWiz), findsOneWidget);
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(TimeWiz), findsOneWidget);
    await tester.enterText(find.byKey(TestKey.startTimeInput), '1337');
    await tester.pumpAndSettle();
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(RecurringWiz), findsOneWidget);
    await tester.tap(find.byType(SaveButton));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityWizardPage), findsNothing);
  });

  group('title step', () {
    const titleOnlyMemoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: false,
        title: true,
        type: false,
        availability: false,
        checkable: false,
        removeAfter: false,
        alarm: false,
        notes: false,
        reminders: false,
      ),
      activityRecurringEditable: false,
    );

    testWidgets('only title step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          titleOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TitleWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text(translate.missingTitleOrImage), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
    });

    testWidgets('title and image shows no warning step',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: false,
              datePicker: false,
              image: true,
              title: true,
              type: false,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: false,
              reminders: false,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TitleWiz), findsOneWidget);

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ImageWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(find.text(translate.missingTitleOrImage), findsOneWidget);
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(ImageWiz), findsOneWidget);

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
    });

    testWidgets('title shows when going back', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          titleOnlyMemoSettings,
        ),
      );
      const title = 'title';
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      expect(find.text(title), findsNothing);

      await tester.enterText(find.byType(TextField), title);
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
      expect(find.text(title), findsNothing);

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('title from basic activity', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: true,
              datePicker: false,
              image: false,
              title: true,
              type: false,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: false,
              reminders: false,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      const title = 'testtitle';

      when(() => mockSortableBloc.state).thenReturn(SortablesLoaded(sortables: [
        Sortable.createNew<BasicActivityDataItem>(
          data: BasicActivityDataItem.createNew(title: title),
        ),
      ]));
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(BasicActivityStepPage), findsOneWidget);
      await tester.tap(find.byKey(TestKey.basicActivityChoice));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(BasicActivityPickerPage), findsOneWidget);
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      expect(find.text(title), findsOneWidget);
    });
  });

  group('time step', () {
    testWidgets('time from basic activity', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: true,
              datePicker: false,
              image: false,
              title: true,
              type: false,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: false,
              reminders: false,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      const title = 'testtitle';

      when(() => mockSortableBloc.state).thenReturn(SortablesLoaded(sortables: [
        Sortable.createNew<BasicActivityDataItem>(
          data: BasicActivityDataItem.createNew(
            title: title,
            startTime: const Duration(hours: 5, minutes: 55),
            duration: const Duration(hours: 2, minutes: 5),
          ),
        ),
      ]));
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(BasicActivityStepPage), findsOneWidget);
      await tester.tap(find.byKey(TestKey.basicActivityChoice));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(BasicActivityPickerPage), findsOneWidget);
      await tester.tap(find.text(title));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
      expect(find.text('05:55'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
    });

    testWidgets('can enter start and end time', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: false,
              datePicker: false,
              image: false,
              title: true,
              type: false,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: false,
              reminders: false,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      const title = 'testtitle';

      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), title);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TimeWiz), findsOneWidget);
      expect(find.text('--:--'), findsNWidgets(2));
      await tester.enterText(find.byKey(TestKey.startTimeInput), '1337');
      expect(find.text('13:37'), findsOneWidget);
      expect(find.text('--:--'), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(TestKey.endTimeInput), '1448');
      await tester.pumpAndSettle();
      expect(find.text('--:--'), findsNothing);
      expect(find.text('13:37'), findsOneWidget);
      expect(find.text('14:48'), findsOneWidget);
    });

    testWidgets('time is saved', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: false,
              datePicker: false,
              image: false,
              title: true,
              type: false,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: false,
              reminders: true,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      const title = 'testtitle';

      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), title);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(TestKey.startTimeInput), '1337');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(TestKey.endTimeInput), '1448');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();

      expect(find.text('--:--'), findsNothing);
      expect(find.text('13:37'), findsOneWidget);
      expect(find.text('14:48'), findsOneWidget);
    });
  });

  group('type step', () {
    const typeOnlyMemoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: false,
        title: false,
        type: true,
        availability: false,
        checkable: false,
        removeAfter: false,
        alarm: false,
        notes: false,
        reminders: false,
      ),
      activityRecurringEditable: false,
    );

    testWidgets('only type step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          typeOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TypeWiz), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.restore), findsOneWidget);
      expect(find.byKey(TestKey.leftCategoryRadio), findsOneWidget);
      expect(find.byKey(TestKey.rightCategoryRadio), findsOneWidget);
    });

    testWidgets('Select full day removes time step',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: false,
              datePicker: false,
              image: false,
              title: true,
              type: true,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: false,
              reminders: false,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      expect(find.byType(TitleWiz), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(TypeWiz), findsOneWidget);

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(TimeWiz), findsOneWidget);

      await tester.tap(find.byType(PreviousButton));
      await tester.pumpAndSettle();
      expect(find.byType(TypeWiz), findsOneWidget);

      await tester.tap(find.byIcon(AbiliaIcons.restore)); // all day radio
      await tester.pumpAndSettle();
      expect(find.byType(NextButton), findsNothing);
      expect(find.byType(SaveButton), findsOneWidget);
    });
  });

  group('available for step', () {
    const availableForOnlyMemoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: false,
        title: false,
        type: false,
        availability: true,
        checkable: false,
        removeAfter: false,
        alarm: false,
        notes: false,
        reminders: false,
      ),
      activityRecurringEditable: false,
    );

    testWidgets('only available for step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          availableForOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(AvailableForWiz), findsOneWidget);
    });
  });

  group('checkable step', () {
    const checkableOnlyMemoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: false,
        title: false,
        type: false,
        availability: false,
        checkable: true,
        removeAfter: false,
        alarm: false,
        notes: false,
        reminders: false,
      ),
      activityRecurringEditable: false,
    );

    testWidgets('only checkable step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          checkableOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(CheckableWiz), findsOneWidget);
    });
  });

  group('remove after step', () {
    const removeAfterOnlyMemoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: false,
        title: false,
        type: false,
        availability: false,
        checkable: false,
        removeAfter: true,
        alarm: false,
        notes: false,
        reminders: false,
      ),
      activityRecurringEditable: false,
    );

    testWidgets('only remove after step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(removeAfterOnlyMemoSettings),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(RemoveAfterWiz), findsOneWidget);
    });
  });

  group('recurring step', () {
    const _recurringOnly = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: false,
        title: false,
        type: true,
        availability: false,
        checkable: false,
        removeAfter: false,
        alarm: false,
        notes: false,
        reminders: false,
      ),
      activityRecurringEditable: true,
    );

    testWidgets('changing recurring changes save button',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(_recurringOnly),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TypeWiz), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.restore));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(RecurringWiz), findsOneWidget);
      expect(find.byType(SaveButton), findsOneWidget);
      expect(find.byType(NextButton), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();
      expect(find.byType(SaveButton), findsNothing);
      expect(find.byType(NextButton), findsOneWidget);

      await tester.tap(find.byIcon(AbiliaIcons.basicActivity));
      await tester.pumpAndSettle();
      expect(find.byType(SaveButton), findsOneWidget);
      expect(find.byType(NextButton), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      expect(find.byType(SaveButton), findsNothing);
      expect(find.byType(NextButton), findsOneWidget);
    });

    testWidgets('weekly recurring shows weekly recurring',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(MemoplannerSettings(
          addActivityTypeAdvanced: false,
          wizard: WizardStepsSettings(
            template: false,
            datePicker: false,
            image: false,
            title: true,
            type: true,
            availability: false,
            checkable: false,
            removeAfter: false,
            alarm: false,
            notes: false,
            reminders: false,
          ),
          activityRecurringEditable: true,
        )),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TypeWiz), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.restore));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(RecurringWiz), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.week));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(RecurringWeeklyWiz), findsOneWidget);
      expect(find.byType(WeekDays), findsOneWidget);
      expect(find.byType(SelectAllWeekdaysButton), findsOneWidget);
      expect(find.byType(EveryOtherWeekSwitch), findsOneWidget);
      expect(find.byType(EndDateWizWidget), findsOneWidget);

      await tester.tap(find.text(translate.shortWeekday(today.weekday)));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(
        find.text(translate.recurringDataEmptyErrorMessage),
        findsOneWidget,
      );

      // Dismiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SelectAllWeekdaysButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(EndDateWizWidget));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(EndDatePickerWiz), findsOneWidget);
      expect(find.byType(SaveButton), findsOneWidget);

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsNothing);
    });

    testWidgets('monthly recurring shows monthy recurring',
        (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(MemoplannerSettings(
          addActivityTypeAdvanced: false,
          wizard: WizardStepsSettings(
            template: false,
            datePicker: false,
            image: false,
            title: true,
            type: true,
            availability: false,
            checkable: false,
            removeAfter: false,
            alarm: false,
            notes: false,
            reminders: false,
          ),
          activityRecurringEditable: true,
        )),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(TitleWiz), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'title');
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(TypeWiz), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.restore));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(RecurringWiz), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(RecurringMonthlyWiz), findsOneWidget);
      expect(find.byType(MonthDays), findsOneWidget);
      expect(find.byType(EndDateWizWidget), findsOneWidget);

      await tester.tap(find.text('${today.day}'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorDialog), findsOneWidget);
      expect(
        find.text(translate.recurringDataEmptyErrorMessage),
        findsOneWidget,
      );

      // Dismiss
      await tester.tapAt(Offset.zero);
      await tester.pumpAndSettle();

      await tester.tap(find.text('31'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(EndDateWizWidget));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(EndDatePickerWiz), findsOneWidget);
      expect(find.byType(SaveButton), findsOneWidget);

      await tester.tap(find.byType(SaveButton));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorDialog), findsNothing);
    });
  });

  group('image step', () {
    const imageOnlyMemoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: true,
        title: false,
        type: false,
        availability: false,
        checkable: false,
        removeAfter: false,
        alarm: false,
        notes: false,
        reminders: false,
      ),
      activityRecurringEditable: false,
    );

    testWidgets('only image step', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(imageOnlyMemoSettings),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(ImageWiz), findsOneWidget);
    });
  });

  group('reminders step', () {
    const remindersOnlyMemoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: false,
        title: false,
        type: true,
        availability: false,
        checkable: false,
        removeAfter: false,
        alarm: false,
        checklist: false,
        notes: false,
        reminders: true,
      ),
      activityRecurringEditable: false,
    );

    testWidgets('reminders step present', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(remindersOnlyMemoSettings),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TypeWiz), findsOneWidget);
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(TimeWiz), findsOneWidget);
      await tester.enterText(find.byKey(TestKey.startTimeInput), '1111');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      expect(find.byType(RemindersWiz), findsOneWidget);
    });

    testWidgets('no reminders when full day', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(remindersOnlyMemoSettings),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(TypeWiz), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.restore));
      await tester.pumpAndSettle();
      expect(find.byType(NextButton), findsNothing);
      expect(find.byType(SaveButton), findsOneWidget);
    });
  });

  group('extra function step', () {
    testWidgets('Both show', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: false,
              datePicker: false,
              image: false,
              title: false,
              type: true,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: true,
              checklist: true,
              reminders: false,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.restore)); // fullday
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExtraFunctionWiz), findsOneWidget);

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.infoItemChecklistRadio), findsOneWidget);
      expect(find.byKey(TestKey.infoItemNoteRadio), findsOneWidget);
    });

    testWidgets('only note show', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: false,
              datePicker: false,
              image: false,
              title: false,
              type: true,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: true,
              checklist: false,
              reminders: false,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.restore)); // fullday
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExtraFunctionWiz), findsOneWidget);

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.infoItemChecklistRadio), findsNothing);
      expect(find.byKey(TestKey.infoItemNoteRadio), findsOneWidget);

      await tester.tap(find.byKey(TestKey.infoItemNoteRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.byType(EditNoteWidget), findsOneWidget);
    });

    testWidgets('only checklist show', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizard: WizardStepsSettings(
              template: false,
              datePicker: false,
              image: false,
              title: false,
              type: true,
              availability: false,
              checkable: false,
              removeAfter: false,
              alarm: false,
              notes: false,
              checklist: true,
              reminders: false,
            ),
            activityRecurringEditable: false,
          ),
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.restore)); // fullday
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ExtraFunctionWiz), findsOneWidget);

      await tester.tap(find.byKey(TestKey.changeInfoItem));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.infoItemChecklistRadio), findsOneWidget);
      expect(find.byKey(TestKey.infoItemNoteRadio), findsNothing);

      await tester.tap(find.byKey(TestKey.infoItemChecklistRadio));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.byType(EditChecklistWidget), findsOneWidget);
    });
  });

  group('alarm step', () {
    const memoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizard: WizardStepsSettings(
        template: false,
        datePicker: false,
        image: false,
        title: false,
        type: true,
        availability: false,
        checkable: false,
        removeAfter: false,
        alarm: true,
        notes: false,
        checklist: false,
        reminders: false,
      ),
      activityRecurringEditable: false,
    );

    testWidgets('alarm step shown', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          memoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.leftCategoryRadio)); // type wiz
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(TestKey.startTimeInput), '1111'); // time wiz
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextButton));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(AlarmWiz), findsOneWidget);
    });

    testWidgets('no alarm step when fullDay', (WidgetTester tester) async {
      when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        const MemoplannerSettingsLoaded(
          memoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.restore)); // fullday
      await tester.pumpAndSettle();

      expect(find.byType(SaveButton), findsOneWidget);
      expect(find.byType(AlarmWiz), findsNothing);
    });
  });
}
