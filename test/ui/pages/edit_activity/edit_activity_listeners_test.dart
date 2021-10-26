import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';

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

  late MockActivitiesBloc mockActivitiesBloc;
  late MemoplannerSettingBloc mockMemoplannerSettingsBloc;

  setUpAll(() {
    registerFallbackValues();
    tz.initializeTimeZones();
  });

  setUp(() async {
    await initializeDateFormatting();
    mockActivitiesBloc = MockActivitiesBloc();
    when(() => mockActivitiesBloc.state).thenReturn(ActivitiesLoaded(const []));
    when(() => mockActivitiesBloc.stream).thenAnswer((_) => Stream.empty());
    mockMemoplannerSettingsBloc = MockMemoplannerSettingBloc();
    when(() => mockMemoplannerSettingsBloc.state).thenReturn(
        MemoplannerSettingsLoaded(
            MemoplannerSettings(advancedActivityTemplate: false)));
    when(() => mockMemoplannerSettingsBloc.stream)
        .thenAnswer((_) => Stream.empty());
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
              BlocProvider<MemoplannerSettingBloc>(
                create: (_) => mockMemoplannerSettingsBloc,
              ),
              BlocProvider<ActivitiesBloc>.value(value: mockActivitiesBloc),
              BlocProvider<EditActivityBloc>(
                create: (context) => newActivity
                    ? EditActivityBloc.newActivity(
                        day: today,
                        defaultAlarmTypeSetting: context
                            .read<MemoplannerSettingBloc>()
                            .state
                            .defaultAlarmTypeSetting,
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
                        settings: context.read<MemoplannerSettingBloc>().state,
                      ),
              ),
              BlocProvider<SortableBloc>(create: (_) => FakeSortableBloc()),
              BlocProvider<UserFileBloc>(create: (_) => FakeUserFileBloc()),
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

  final submitButtonFinder = find.byType(NextWizardStepButton);

  testWidgets('pressing add activity button with no title nor time shows error',
      (WidgetTester tester) async {
    // Act press submit
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
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
    expect(find.text(translate.missingTitleOrImageAndStartTime), findsNothing);
  });

  testWidgets('pressing add activity button without time shows error',
      (WidgetTester tester) async {
    const newActivtyName = 'new activity name';

    // Act press submit
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.ourEnterText(
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
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
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
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
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

  testWidgets('pressing add activity before now shows warning',
      (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.startTimeInput), '0133');
    await tester.pumpAndSettle();
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmWarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.text(translate.startTimeBeforeNowWarning), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // // Assert - finds nothing
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.text(translate.startTimeBeforeNowWarning), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });

  testWidgets(
      'pressing add activity before now with no title shows error no warning',
      (WidgetTester tester) async {
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.startTimeInput), '0133');
    await tester.pumpAndSettle();
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act -- press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert -- no title error message, no warning
    expect(find.byType(ErrorDialog), findsOneWidget);
    expect(find.text(translate.missingTitleOrImage), findsOneWidget);
    expect(find.byType(ConfirmWarningDialog), findsNothing);

    // Act -- dissmiss, enter title, press submit
    await tester.tap(
      find.descendant(
        of: find.byType(ErrorDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert now show warning
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);
    expect(find.byType(ErrorDialog), findsNothing);

    // Act -- Ok the warning
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert -- leaves editactivitypage
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });

  testWidgets(
      'edit recurrint activity TDO change time before now shows warning',
      (WidgetTester tester) async {
    final edit = Activity.createNew(
      title: 'recurring',
      startTime: startTime.subtract(40.days()),
      recurs: Recurs.everyDay,
    );
    await tester.pumpWidget(createEditActivityPage(givenActivity: edit));
    await tester.pumpAndSettle();

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.startTimeInput), '0133');
    await tester.pumpAndSettle();
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act -- press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert -- select recurrence page shows
    expect(find.byType(SelectRecurrentTypePage), findsOneWidget);

    // Act -- this day onlu selected, pressing OK
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert -- before now warning
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act -- Ok the warning
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert -- leaves editactivitypage
    expect(find.byType(SelectRecurrentTypePage), findsNothing);
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });

  testWidgets('pressing add activity with conflict shows warning',
      (WidgetTester tester) async {
    // Arrange
    final conflicting = Activity.createNew(
      title: 'conflict',
      startTime: startTime,
      duration: 30.minutes(),
    );
    when(() => mockActivitiesBloc.state)
        .thenReturn(ActivitiesLoaded([conflicting]));
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.startTimeInput), '0333');
    await tester.pumpAndSettle();
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmWarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.text(translate.conflictWarning), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // // Assert - finds nothing
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.text(translate.conflictWarning), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });

  testWidgets('add activity with conflict and before now shows both warning',
      (WidgetTester tester) async {
    // Arrange
    final conflictingActivity = Activity.createNew(
      title: 'conflict',
      startTime: startTime.subtract(10.minutes()),
      duration: 30.minutes(),
    );
    when(() => mockActivitiesBloc.state)
        .thenReturn(ActivitiesLoaded([conflictingActivity]));
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.ourEnterText(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();

    // Act -- Change input to new start time
    await tester.tap(timeFieldFinder);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(TestKey.startTimeInput), '0325');
    await tester.pumpAndSettle();
    await tester.tap(okButtonFinder);
    await tester.pumpAndSettle();

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message before now
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(ConfirmWarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(ConfirmWarningDialog), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message before now
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert warning message conflict
    expect(find.byType(ConfirmWarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert - finds nothing
    expect(find.byType(ConfirmWarningDialog), findsNothing);
    expect(find.byType(EditActivityPage), findsNothing);
  });
}

extension on WidgetTester {
  Future scrollDown({double dy = -800.0}) async {
    final center = getCenter(find.byType(EditActivityPage));
    await dragFrom(center, Offset(0.0, dy));
    await pump();
  }

  Future goToAlarmTab() async => goToTab(AbiliaIcons.attention);

  Future goToTab(IconData icon) async {
    await tap(find.byIcon(icon));
    await pumpAndSettle();
  }
}
