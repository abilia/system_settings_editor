import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_clock/ticker.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';

void main() {
  group('week calendar settings page', () {
    final translate = Locales.language.values.first;
    final initialTime = DateTime(2021, 04, 17, 09, 20);
    final Iterable<Generic> generics = [];
    late MockGenericDb genericDb;

    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
      scheduleNotificationsIsolated = noAlarmScheduler;

      genericDb = MockGenericDb();
      when(() => genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(generics));
      when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      when(() => genericDb.insertAndAddDirty(any()))
          .thenAnswer((_) => Future.value(true));

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker.fake(initialTime: initialTime)
        ..client = fakeClient(genericResponse: () => generics)
        ..database = FakeDatabase()
        ..genericDb = genericDb
        ..sortableDb = FakeSortableDb()
        ..battery = FakeBattery()
        ..deviceDb = FakeDeviceDb()
        ..init();
    });

    tearDown(GetIt.I.reset);

    testWidgets('Hide browse buttons', (tester) async {
      await tester.goToWeekCalendarSettingsPage();
      expect(find.byType(LeftNavButton), findsOneWidget);
      expect(find.byType(RightNavButton), findsOneWidget);
      await tester.tap(find.text(translate.showBrowseButtons));
      await tester.pumpAndSettle();
      expect(find.byType(LeftNavButton), findsNothing);
      expect(find.byType(RightNavButton), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: WeekCalendarSettings.showBrowseButtonsKey,
        matcher: isFalse,
      );
    });

    testWidgets('Hide week number', (tester) async {
      final weekText = '${translate.week} '
          '${initialTime.firstInWeek().getWeekNumber()}';
      await tester.goToWeekCalendarSettingsPage();
      expect(find.text(weekText), findsOneWidget);
      await tester.tap(find.text(translate.showWeekNumber));
      await tester.pumpAndSettle();
      expect(find.text(weekText), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: WeekCalendarSettings.showWeekNumberKey,
        matcher: isFalse,
      );
    });

    testWidgets('Hide year and month', (tester) async {
      await tester.goToWeekCalendarSettingsPage();
      expect(find.text('April ${initialTime.year}'), findsOneWidget);
      await tester.tap(find.text(translate.showMonthAndYear));
      await tester.pumpAndSettle();
      expect(find.text('${initialTime.year}'), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: WeekCalendarSettings.showYearAndMonthKey,
        matcher: isFalse,
      );
    });

    testWidgets('Hide clock', (tester) async {
      await tester.goToWeekCalendarSettingsPage();
      expect(find.byType(AbiliaClock), findsOneWidget);
      await tester.tap(find.text(translate.showClock));
      await tester.pumpAndSettle();
      expect(find.byType(AbiliaClock), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: WeekCalendarSettings.showClockKey,
        matcher: isFalse,
      );
    });

    testWidgets('Select number of days', (tester) async {
      await tester.goToWeekCalendarSettingsPage();
      await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
      await tester.pumpAndSettle();
      expect(find.byType(DayHeading), findsNWidgets(7));
      await tester.tap(find.text(translate.weekdays));
      await tester.pumpAndSettle();
      expect(find.byType(DayHeading), findsNWidgets(5));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: WeekCalendarSettings.showFullWeekKey,
        matcher: WeekDisplayDays.weekdays.index,
      );
    });

    testWidgets('Select caption', (tester) async {
      await tester.goToWeekCalendarSettingsPage();
      await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
      await tester.pumpAndSettle();
      await tester.dragUntilVisible(find.text(translate.captions),
          find.byType(WeekSettingsTab), const Offset(0, 100));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.captions));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: WeekCalendarSettings.showColorModeKey,
        matcher: WeekColor.captions.index,
      );
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> goToWeekCalendarSettingsPage() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.week));
    await pumpAndSettle();
  }
}
