import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import '../../../fakes/all.dart';
import '../../../mocks/shared.mocks.dart';

void main() {
  final startTime = DateTime(2021, 09, 22, 12, 46);
  final today = startTime.onlyDays();
  final translate = Locales.language.values.first;

  late MockSortableBloc mockSortableBloc;
  late MockUserFileBloc mockUserFileBloc;
  late MemoplannerSettingBloc mockMemoplannerSettingsBloc;

  setUp(() async {
    tz.initializeTimeZones();
    await initializeDateFormatting();
    mockSortableBloc = MockSortableBloc();
    when(mockSortableBloc.stream).thenAnswer((_) => Stream.empty());
    mockUserFileBloc = MockUserFileBloc();
    when(mockUserFileBloc.stream).thenAnswer((_) => Stream.empty());
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(mockMemoplannerSettingsBloc.state).thenReturn(
      MemoplannerSettingsLoaded(
        MemoplannerSettings(
          addActivityTypeAdvanced: false,
        ),
      ),
    );
    when(mockMemoplannerSettingsBloc.stream).thenAnswer((_) => Stream.empty());
  });

  Widget wizardPage({
    bool use24H = false,
  }) {
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: [Translator.delegate],
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
              BlocProvider<TimepillarBloc>(
                create: (context) => TimepillarBloc(
                  clockBloc: context.read<ClockBloc>(),
                  memoSettingsBloc: context.read<MemoplannerSettingBloc>(),
                  dayPickerBloc: context.read<DayPickerBloc>(),
                ),
              )
            ],
            child: child!,
          ),
        ),
      ),
      home: ActivityWizardPage(),
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

    await tester.pumpAndSettle();
    expect(find.byType(PlaceholderWiz), findsOneWidget); // Availible for
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(PlaceholderWiz), findsOneWidget); // Checkable
    await tester.tap(find.byType(NextButton));
    await tester.pumpAndSettle();

    expect(find.byType(TimeWiz), findsOneWidget);
  });

  group('title step', () {
    testWidgets('only title step', (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizardTemplateStep: false,
            wizardDatePickerStep: false,
            wizardImageStep: false,
            wizardTitleStep: true,
            wizardTypeStep: false,
            wizardAvailabilityType: false,
            wizardCheckableStep: false,
            wizardRemoveAfterStep: false,
            wizardAlarmStep: false,
            wizardNotesStep: false,
            wizardRemindersStep: false,
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
      when(mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizardTemplateStep: false,
            wizardDatePickerStep: false,
            wizardImageStep: true,
            wizardTitleStep: true,
            wizardTypeStep: false,
            wizardAvailabilityType: false,
            wizardCheckableStep: false,
            wizardRemoveAfterStep: false,
            wizardAlarmStep: false,
            wizardNotesStep: false,
            wizardRemindersStep: false,
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
      when(mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizardTemplateStep: false,
            wizardDatePickerStep: false,
            wizardImageStep: false,
            wizardTitleStep: true,
            wizardTypeStep: false,
            wizardAvailabilityType: false,
            wizardCheckableStep: false,
            wizardRemoveAfterStep: false,
            wizardAlarmStep: false,
            wizardNotesStep: false,
            wizardRemindersStep: false,
            activityRecurringEditable: false,
          ),
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
      when(mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          MemoplannerSettings(
            addActivityTypeAdvanced: false,
            wizardTemplateStep: true,
            wizardDatePickerStep: false,
            wizardImageStep: false,
            wizardTitleStep: true,
            wizardTypeStep: false,
            wizardAvailabilityType: false,
            wizardCheckableStep: false,
            wizardRemoveAfterStep: false,
            wizardAlarmStep: false,
            wizardNotesStep: false,
            wizardRemindersStep: false,
            activityRecurringEditable: false,
          ),
        ),
      );
      const title = 'testtitle';

      when(mockSortableBloc.state).thenReturn(SortablesLoaded(sortables: [
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

  group('available for step', () {
    final typeOnlyMemoSettings = MemoplannerSettings(
      addActivityTypeAdvanced: false,
      wizardTemplateStep: false,
      wizardDatePickerStep: false,
      wizardImageStep: false,
      wizardTitleStep: false,
      wizardTypeStep: false,
      wizardAvailabilityType: true,
      wizardCheckableStep: false,
      wizardRemoveAfterStep: false,
      wizardAlarmStep: false,
      wizardNotesStep: false,
      wizardRemindersStep: false,
      activityRecurringEditable: false,
    );

    testWidgets('only available for step', (WidgetTester tester) async {
      when(mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
          typeOnlyMemoSettings,
        ),
      );
      await tester.pumpWidget(wizardPage());
      await tester.pumpAndSettle();

      expect(find.byType(ActivityWizardPage), findsOneWidget);
      expect(find.byType(AvailableForWiz), findsOneWidget);
    });
  });
}
