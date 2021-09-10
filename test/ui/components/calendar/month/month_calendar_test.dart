import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/shared.mocks.dart';
import '../../../../test_helpers/tts.dart';

void main() {
  late MockGenericDb mockGenericDb;

  ActivityResponse activityResponse = () => [];
  final initialDay = DateTime(2020, 08, 05);

  setUp(() async {
    setupPermissions();
    setupFakeTts();

    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockActivityDb = MockActivityDb();
    when(mockActivityDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(activityResponse()));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    mockGenericDb = MockGenericDb();
    when(mockGenericDb.insertAndAddDirty(any))
        .thenAnswer((_) => Future.value(false));
    when(mockGenericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value([]));
    when(mockGenericDb.getById(any)).thenAnswer((_) => Future.value(null));
    when(mockGenericDb.insert(any)).thenAnswer((_) async {});

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..activityDb = mockActivityDb
      ..ticker = Ticker(
          stream: StreamController<DateTime>().stream, initialTime: initialDay)
      ..syncDelay = SyncDelays.zero
      ..client = Fakes.client(activityResponse: activityResponse)
      ..database = FakeDatabase()
      ..genericDb = mockGenericDb
      ..ticker = Ticker(stream: Stream.empty(), initialTime: initialDay)
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
    await tester.tap(find.byIcon(AbiliaIcons.return_to_previous_page));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(AbiliaIcons.return_to_previous_page));
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
      await tester.tap(find.byIcon(AbiliaIcons.go_to_next_page));
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
      await tester.tap(find.byIcon(AbiliaIcons.return_to_previous_page));
      await tester.pumpAndSettle();
      expect(find.byType(GoToCurrentActionButton), findsOneWidget);
      await tester.verifyTts(find.byType(MonthAppBar), contains: 'July 2020');
    });

    testWidgets('Go to this month', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.return_to_previous_page));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GoToCurrentActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(GoToCurrentActionButton), findsNothing);
      await tester.verifyTts(find.byType(MonthAppBar), contains: 'August 2020');
    });
  });

  group('Grid', () {
    testWidgets('day tts', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.verifyTts(find.text('30'), contains: 'Sunday, August 30');
    });

    testWidgets('tapping day goes back to that day calendar',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.tap(find.text('30'));
      await tester.pumpAndSettle();
      expect(find.byType(DayAppBar), findsOneWidget);
      expect(find.byType(DayCalendar), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('30 August 2020'), findsOneWidget);
    });

    group('shows activities', () {
      final fridayTitle = 'en rubrik', nextMonthTitle = 'next month';
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
        expect(find.byType(MonthFullDayStack), findsOneWidget);

        await tester.tap(find.byIcon(AbiliaIcons.go_to_next_page));
        await tester.pumpAndSettle();

        expect(find.text(fridayTitle), findsNothing);
        expect(find.text(nextMonthTitle), findsOneWidget);
      });

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

  group('With preview', () {
    final time = initialDay.withTime(TimeOfDay(hour: 16, minute: 16));
    final title1 = 'i1', title2 = 't2', fridayTitle = 'ft1';
    final friday = time.addDays(2);
    setUp(() {
      activityResponse = () => [
            Activity.createNew(title: title1, startTime: time),
            Activity.createNew(title: title2, startTime: time),
            Activity.createNew(title: fridayTitle, startTime: friday),
          ];
    });

    testWidgets('can switch to month list preview',
        (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EyeButtonMonth));
      await tester.pumpAndSettle();
      expect(find.byType(EyeButtonMonthDialog), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.calendar_list));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.byType(MonthListPreview), findsOneWidget);
    });

    testWidgets('Shows activity in the preview', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.month));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EyeButtonMonth));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.calendar_list));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
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
      when(mockGenericDb.getAllNonDeletedMaxRevision()).thenAnswer(
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
      await tester.tap(find.byType(EyeButtonMonth));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.calendar_list));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      final activityCardList =
          tester.widgetList<ActivityCard>(find.byType(ActivityCard));
      expect(
          activityCardList.any((activityCard) => activityCard.showCategories),
          isFalse);
    });
  });
}
