import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';
import '../../../../../test_helpers/verify_generic.dart';

void main() {
  group('week calendar settings page', () {
    final translate = Locales.language.values.first;
    final initialTime = DateTime(2021, 04, 17, 09, 20);
    Iterable<Generic> generics = [];
    late MockGenericDb genericDb;

    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
      scheduleAlarmNotificationsIsolated = noAlarmScheduler;

      genericDb = MockGenericDb();
      when(() => genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(generics));
      when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
      when(() => genericDb.insertAndAddDirty(any()))
          .thenAnswer((_) => Future.value(true));

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker.fake(initialTime: initialTime)
        ..client = Fakes.client(genericResponse: () => generics)
        ..database = FakeDatabase()
        ..genericDb = genericDb
        ..battery = FakeBattery()
        ..deviceDb = FakeDeviceDb()
        ..init();
    });

    tearDown(GetIt.I.reset);

    testWidgets('Navigate to page', (tester) async {
      await tester.goToWeekCalendarSettingsPage(pump: true);
      expect(find.byType(WeekCalendarSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    testWidgets('Hide browse buttons', (tester) async {
      await tester.goToWeekCalendarSettingsPage(pump: true);
      await tester.tap(find.text(translate.showBrowseButtons));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.weekCaptionShowBrowseButtonsKey,
        matcher: isFalse,
      );
    });

    testWidgets('Hide week number', (tester) async {
      await tester.goToWeekCalendarSettingsPage(pump: true);
      await tester.tap(find.text(translate.showWeekNumber));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.weekCaptionShowWeekNumberKey,
        matcher: isFalse,
      );
    });

    testWidgets('Hide year', (tester) async {
      await tester.goToWeekCalendarSettingsPage(pump: true);
      await tester.tap(find.text(translate.showYear));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.weekCaptionShowYearKey,
        matcher: isFalse,
      );
    });

    testWidgets('Hide clock', (tester) async {
      await tester.goToWeekCalendarSettingsPage(pump: true);
      await tester.tap(find.text(translate.showClock));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.weekCaptionShowClockKey,
        matcher: isFalse,
      );
    });

    testWidgets('Select number of days', (tester) async {
      await tester.goToWeekCalendarSettingsPage(pump: true);
      await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
      await tester.pumpAndSettle();
      await tester.tap(find.text(translate.weekdays));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.weekDisplayShowFullWeekKey,
        matcher: WeekDisplayDays.weekdays.index,
      );
    });

    testWidgets('Select caption', (tester) async {
      await tester.goToWeekCalendarSettingsPage(pump: true);
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
        key: MemoplannerSettings.weekDisplayShowColorModeKey,
        matcher: WeekColor.captions.index,
      );
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> goToWeekCalendarSettingsPage({bool pump = false}) async {
    if (pump) await pumpApp();
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
