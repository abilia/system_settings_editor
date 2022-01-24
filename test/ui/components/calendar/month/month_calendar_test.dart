import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/tts.dart';
import '../../../../test_helpers/enter_text.dart';

void main() {
  late MockGenericDb mockGenericDb;

  ActivityResponse activityResponse = () => [];
  final initialDay = DateTime(2020, 08, 05);

  setUp(() async {
    setupPermissions();
    setupFakeTts();

    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();

    final mockActivityDb = MockActivityDb();
    when(() => mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activityResponse()));
    when(() => mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value([]));
    when(() => mockActivityDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    mockGenericDb = MockGenericDb();
    when(() => mockGenericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(false));
    when(() => mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value([]));
    when(() => mockGenericDb.getById(any()))
        .thenAnswer((_) => Future.value(null));
    when(() => mockGenericDb.insert(any())).thenAnswer((_) async {});

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..client = Fakes.client(activityResponse: activityResponse)
      ..database = FakeDatabase()
      ..genericDb = mockGenericDb
      ..ticker = Ticker.fake(initialTime: initialDay)
      ..battery = FakeBattery()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('Can navigate to week calendar', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.month));
    await tester.pumpAndSettle();
    expect(find.byType(MonthCalendarTab), findsOneWidget);
    expect(find.byType(MonthAppBar), findsOneWidget);
  });

  testWidgets('Tapping Month in TabBar returns to this month',
      (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.month));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
    expect(find.byType(GoToCurrentActionButton), findsOneWidget);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.month));
    await tester.pumpAndSettle();
    expect(find.byType(GoToCurrentActionButton), findsNothing);
    await tester.verifyTts(find.byType(MonthAppBar), contains: 'August 2020');
  });

  group('app bar', () {
    testWidgets('MonthAppBar', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.byType(MonthAppBar), contains: 'August 2020');
    });

    testWidgets('next month', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      expect(find.byType(GoToCurrentActionButton), findsOneWidget);
      await tester.verifyTts(find.byType(MonthAppBar),
          contains: 'September 2020');
    });

    testWidgets('previous month', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();
      expect(find.byType(GoToCurrentActionButton), findsOneWidget);
      await tester.verifyTts(find.byType(MonthAppBar), contains: 'July 2020');
    });

    testWidgets('Go to this month', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GoToCurrentActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(GoToCurrentActionButton), findsNothing);
      await tester.verifyTts(find.byType(MonthAppBar), contains: 'August 2020');
    });
  });

  group('Calendar body', () {
    testWidgets('day tts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.text('30'), contains: 'Sunday, August 30');
    });

    group('shows activities', () {
      const fridayTitle = 'en rubrik', nextMonthTitle = 'next month';
      final friday = initialDay.addDays(2);
      final nextMonth = initialDay.nextMonth();
      final recuresOnMonthDaySet = {1, 5, 6, 9, 22, 23};

      setUp(() {
        activityResponse = () => [
              Activity.createNew(
                  title: fridayTitle, startTime: friday, fullDay: true),
              Activity.createNew(
                  title: nextMonthTitle, startTime: nextMonth, fullDay: true),
              Activity.createNew(
                  title: 't1', startTime: initialDay, fullDay: true),
              Activity.createNew(
                  title: 't2', startTime: initialDay, fullDay: true),
              Activity.createNew(
                title: 'recurring',
                startTime: initialDay.previousMonth().add(1.minutes()),
                recurs: Recurs.monthlyOnDays((recuresOnMonthDaySet)),
              ),
            ];
      });

      testWidgets('shows fullday ', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();
        // Assert
        expect(find.text(fridayTitle), findsOneWidget);
        expect(find.text(nextMonthTitle), findsNothing);
        expect(find.byKey(TestKey.monthCalendarFullDayStack), findsOneWidget);

        await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
        await tester.pumpAndSettle();

        expect(find.text(fridayTitle), findsNothing);
        expect(find.text(nextMonthTitle), findsOneWidget);
      }, skip: Config.isMPGO);

      testWidgets('shows activity as dot ', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(App());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();
        // Assert
        expect(
          find.byType(ColorDot),
          findsNWidgets(recuresOnMonthDaySet.length),
        );
      });
    });
  });

  group('Day preview', () {
    final time = initialDay.withTime(const TimeOfDay(hour: 16, minute: 16));
    const title1 = 'i1', title2 = 't2', fridayTitle = 'ft1';
    final friday = time.addDays(2);
    setUp(() {
      activityResponse = () => [
            Activity.createNew(title: title1, startTime: time),
            Activity.createNew(title: title2, startTime: time),
            Activity.createNew(title: fridayTitle, startTime: friday),
          ];
    });

    testWidgets(
        'Day preview hides when navigation to non-current month and shows when navigating to current month',
        (WidgetTester tester) async {
      final translate = Locales.language.values.first;

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      expect(find.byType(MonthDayPreviewHeading), findsOneWidget);
      expect(find.text(translate.selectADayToViewDetails), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.returnToPreviousPage));
      await tester.pumpAndSettle();
      expect(find.byType(MonthDayPreviewHeading), findsNothing);
      expect(find.text(translate.selectADayToViewDetails), findsOneWidget);

      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      expect(find.byType(MonthDayPreviewHeading), findsOneWidget);
      expect(find.text(translate.selectADayToViewDetails), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      expect(find.byType(MonthDayPreviewHeading), findsNothing);
      expect(find.text(translate.selectADayToViewDetails), findsOneWidget);

      await tester.tap(find.byType(GoToCurrentActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(MonthDayPreviewHeading), findsOneWidget);
      expect(find.text(translate.selectADayToViewDetails), findsNothing);
    });

    testWidgets(
        'tapping button in preview header goes back to that day calendar',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.tap(find.text('30'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.navigationNext));
      await tester.pumpAndSettle();
      expect(find.byType(DayAppBar), findsOneWidget);
      expect(find.byType(DayCalendar), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('30 August 2020'), findsOneWidget);
    });

    testWidgets('Shows activity in the preview', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNWidgets(2));
      expect(find.text(title2), findsOneWidget);
      expect(find.text(title1), findsOneWidget);
      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();
      expect(find.text(title2), findsNothing);
      expect(find.byType(ActivityCard), findsOneWidget);
      expect(find.text(fridayTitle), findsOneWidget);
      await tester.tap(find.text('25'));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);
      expect(find.text(fridayTitle), findsNothing);
    });

    testWidgets('Activities in the preview repspects show categories setting',
        (WidgetTester tester) async {
      when(() => mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
        (realInvocation) => Future.value(
          [
            Generic.createNew<MemoplannerSettingData>(
              data: MemoplannerSettingData.fromData(
                data: false,
                identifier:
                    MemoplannerSettings.calendarActivityTypeShowTypesKey,
              ),
            ),
          ],
        ),
      );
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      final cardPaddingList = tester.widgetList<Padding>(find.ancestor(
          of: find.byType(ActivityCard), matching: find.byType(Padding)));

      expect(
          cardPaddingList.any((padding) =>
              padding.padding.collapsedSize.width <
              layout.activityCard.categorySideOffset),
          isTrue);
    });

    testWidgets('Can navigate to month calendar', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      expect(find.byType(MonthCalendar), findsOneWidget);
      expect(find.byType(MonthPreview), findsOneWidget);
    });

    testWidgets('Preview header shows one activity',
        (WidgetTester tester) async {
      final activities = [
        FakeActivity.starts(initialDay, title: 'one').copyWith(fullDay: true),
      ];
      activityResponse = () => activities;

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      expect(find.byType(MonthPreview), findsOneWidget);
      expect(find.byType(FullDayStack), findsNothing);
      expect(find.byKey(TestKey.monthPreviewHeaderActivity), findsOneWidget);
      expect(
          find.descendant(
              of: find.byKey(TestKey.monthPreviewHeaderActivity),
              matching: find.text('one')),
          findsOneWidget);
    });

    testWidgets('Preview header shows many activities',
        (WidgetTester tester) async {
      final activities = [
        FakeActivity.starts(initialDay, title: 'one').copyWith(fullDay: true),
        FakeActivity.starts(initialDay, title: 'two').copyWith(fullDay: true),
      ];
      activityResponse = () => activities;

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      expect(find.byType(MonthPreview), findsOneWidget);
      expect(
          find.byKey(TestKey.monthPreviewHeaderFullDayStack), findsOneWidget);
      expect(find.byType(MonthActivityContent), findsNothing);
      expect(
          find.descendant(
              of: find.byKey(TestKey.monthPreviewHeaderFullDayStack),
              matching: find.text('+2')),
          findsOneWidget);
    });

    testWidgets(
        'SGC-1062 Split month view: List not updated when editing activity',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();

      expect(find.byType(MonthPreview), findsOneWidget);

      await tester.tap(find.text(title1));

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.edit));
      await tester.pumpAndSettle();
      await tester.ourEnterText(
          find.byKey(TestKey.editTitleTextFormField), 'new title');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(NextWizardStepButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.activityBackButton));
      await tester.pumpAndSettle();
      expect(find.byType(MonthPreview), findsOneWidget);
      expect(find.text('new title'), findsOneWidget);
    });
  });
}
