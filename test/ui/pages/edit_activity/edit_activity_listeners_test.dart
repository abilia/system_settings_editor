import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

import '../../../mocks_and_fakes/fake_db_and_repository.dart';
import '../../../mocks_and_fakes/fakes_blocs.dart';
import '../../../mocks_and_fakes/shared.mocks.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../mocks_and_fakes/fake_authenticated_blocs_provider.dart';

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

  setUp(() async {
    tz.initializeTimeZones();
    await initializeDateFormatting();
    mockActivitiesBloc = MockActivitiesBloc();
    when(mockActivitiesBloc.state).thenReturn(ActivitiesLoaded([]));
    when(mockActivitiesBloc.stream).thenAnswer((_) => Stream.empty());
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
              BlocProvider<MemoplannerSettingBloc>(
                create: (_) => FakeMemoplannerSettingsBloc(),
              ),
              BlocProvider<ActivitiesBloc>.value(value: mockActivitiesBloc),
              BlocProvider<ActivityWizardCubit>(
                create: (context) => ActivityWizardCubit(),
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
      home: ErrorPopupListener(
        child: EditActivityPage(),
      ),
    );
  }

  final submitButtonFinder = find.byType(SaveActivityButton);
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
    final newActivtyName = 'new activity name';

    // Act press submit
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
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
    await tester.enterText_(
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
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(WarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(WarningDialog), findsNothing);
    expect(find.text(translate.startTimeBeforeNowWarning), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // // Assert - finds nothing
    expect(find.byType(WarningDialog), findsNothing);
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
    expect(find.byType(WarningDialog), findsNothing);

    // Act -- dissmiss, enter title, press submit
    await tester.tap(
      find.descendant(
        of: find.byType(ErrorDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText_(
        find.byKey(TestKey.editTitleTextFormField), 'newActivtyName');
    await tester.pumpAndSettle();
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert now show warning
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);
    expect(find.byType(ErrorDialog), findsNothing);

    // Act -- Ok the warning
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert -- leaves editactivitypage
    expect(find.byType(WarningDialog), findsNothing);
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
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act -- Ok the warning
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert -- leaves editactivitypage
    expect(find.byType(SelectRecurrentTypePage), findsNothing);
    expect(find.byType(WarningDialog), findsNothing);
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
    when(mockActivitiesBloc.state).thenReturn(ActivitiesLoaded([conflicting]));
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.enterText_(
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
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(WarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(WarningDialog), findsNothing);
    expect(find.text(translate.conflictWarning), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // // Assert - finds nothing
    expect(find.byType(WarningDialog), findsNothing);
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
    when(mockActivitiesBloc.state)
        .thenReturn(ActivitiesLoaded([conflictingActivity]));
    await tester.pumpWidget(createEditActivityPage(newActivity: true));
    await tester.pumpAndSettle();

    // Act enter title
    await tester.enterText_(
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
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act dissmiss
    await tester.tap(
      find.descendant(
        of: find.byType(WarningDialog),
        matching: find.byType(PreviousButton),
      ),
    );
    await tester.pumpAndSettle();

    // Assert - back ad edit activity
    expect(find.byType(EditActivityPage), findsOneWidget);
    expect(find.byType(WarningDialog), findsNothing);

    // Act press submit
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    // Assert warning message before now
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.startTimeBeforeNowWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert warning message conflict
    expect(find.byType(WarningDialog), findsOneWidget);
    expect(find.text(translate.conflictWarning), findsOneWidget);

    // Act press ok
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    // Assert - finds nothing
    expect(find.byType(WarningDialog), findsNothing);
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
