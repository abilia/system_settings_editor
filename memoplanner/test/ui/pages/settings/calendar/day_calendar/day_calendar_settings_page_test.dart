import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';

void main() {
  late SharedPreferences fakeSharedPreferences;
  group('Day calendar settings page', () {
    final translate = Locales.language.values.first;
    final initialTime = DateTime(2021, 04, 17, 09, 20);
    Iterable<Generic> generics = [];
    late MockGenericDb genericDb;

    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
      scheduleNotificationsIsolated = noAlarmScheduler;

      genericDb = MockGenericDb();
      when(() => genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(generics));
      when(() => genericDb.insertAndAddDirty(any()))
          .thenAnswer((_) => Future.value(true));
      when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));

      fakeSharedPreferences = await FakeSharedPreferences.getInstance();

      GetItInitializer()
        ..sharedPreferences = fakeSharedPreferences
        ..ticker = Ticker.fake(initialTime: initialTime)
        ..client = fakeClient(genericResponse: () => generics)
        ..database = FakeDatabase()
        ..sortableDb = FakeSortableDb()
        ..genericDb = genericDb
        ..battery = FakeBattery()
        ..deviceDb = FakeDeviceDb()
        ..init();
    });

    tearDown(GetIt.I.reset);

    testWidgets('Navigate to page', (tester) async {
      await tester.goToDayCalendarSettingsPage(pump: true);
      expect(find.byType(DayCalendarSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });

    group('Settings tab', () {
      testWidgets('Hide browse buttons', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.text(translate.showBrowseButtons));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DayAppBarSettings.dayCaptionShowDayButtonsKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide week day', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.text(translate.showWeekday));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DayAppBarSettings.activityDisplayWeekdayKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide time period', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.text(translate.showDayPeriod));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DayAppBarSettings.activityDisplayDayPeriodKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide date', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.text(translate.showDate));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DayAppBarSettings.activityDisplayDateKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide clock', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.dragUntilVisible(find.text(translate.showClock),
            find.byType(DayAppBarSettingsTab), const Offset(0, 100));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.showClock));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: DayAppBarSettings.activityDisplayClockKey,
          matcher: isFalse,
        );
      });

      testWidgets(
          'BUG SGC-1683 - Header shown in menu page even when turned off',
          (tester) async {
        generics = [
          Generic.createNew<GenericSettingData>(
            data: GenericSettingData.fromData(
              data: false,
              identifier: DayAppBarSettings.dayCaptionShowDayButtonsKey,
            ),
          ),
          Generic.createNew<GenericSettingData>(
            data: GenericSettingData.fromData(
              data: false,
              identifier: DayAppBarSettings.activityDisplayWeekdayKey,
            ),
          ),
          Generic.createNew<GenericSettingData>(
            data: GenericSettingData.fromData(
              data: false,
              identifier: DayAppBarSettings.activityDisplayDayPeriodKey,
            ),
          ),
          Generic.createNew<GenericSettingData>(
            data: GenericSettingData.fromData(
              data: false,
              identifier: DayAppBarSettings.activityDisplayDateKey,
            ),
          ),
          Generic.createNew<GenericSettingData>(
            data: GenericSettingData.fromData(
              data: false,
              identifier: DayAppBarSettings.activityDisplayClockKey,
            ),
          ),
        ];
        await tester.pumpApp();
        await tester.tap(find.byType(MenuButton));
        await tester.pumpAndSettle();
        expect(find.byType(AppBar), findsNothing);
      });
    });

    group('Display tab', () {
      testWidgets('Select list', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.calendarList));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        expect(
          fakeSharedPreferences
              .getInt(DayCalendarViewSettings.viewOptionsCalendarTypeKey),
          DayCalendarType.list.index,
        );
      });

      testWidgets('Select two timepillars', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.twoTimelines));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        expect(
          fakeSharedPreferences
              .getInt(DayCalendarViewSettings.viewOptionsCalendarTypeKey),
          DayCalendarType.twoTimepillars.index,
        );
      });

      testWidgets('Set timepillar interval', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.dayNight));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(
          fakeSharedPreferences
              .getInt(DayCalendarViewSettings.viewOptionsTimeIntervalKey),
          TimepillarIntervalType.dayAndNight.index,
        );
      });

      testWidgets('Set timepillar zoom', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.large));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(
          fakeSharedPreferences
              .getInt(DayCalendarViewSettings.viewOptionsTimepillarZoomKey),
          TimepillarZoom.large.index,
        );
      });

      testWidgets('Set timepillar dots', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(find.byIcon(AbiliaIcons.flarp),
            find.byType(DayAppBarSettingsTab), const Offset(0, 100));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.flarp));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(
          fakeSharedPreferences
              .getBool(DayCalendarViewSettings.viewOptionsDotsKey),
          isFalse,
        );
      });
    });

    group('Eyebutton tab', () {
      testWidgets('Hide type of display in eye button', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showTypeOfDisplaySwitch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(
          fakeSharedPreferences.getBool(
            DayCalendarViewOptionsDisplaySettings.displayCalendarTypeKey,
          ),
          isFalse,
        );
      });

      testWidgets('Hide interval setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showTimepillarLengthSwitch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(
          fakeSharedPreferences.getBool(
            DayCalendarViewOptionsDisplaySettings
                .displayIntervalTypeIntervalKey,
          ),
          isFalse,
        );
      });

      testWidgets('Hide zoom setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showTimelineZoomSwitch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(
          fakeSharedPreferences.getBool(
            DayCalendarViewOptionsDisplaySettings.displayTimepillarZoomKey,
          ),
          isFalse,
        );
      });

      testWidgets('Hide time display setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showDurationSelectionSwitch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();

        expect(
          fakeSharedPreferences.getBool(
            DayCalendarViewOptionsDisplaySettings.displayDurationKey,
          ),
          isFalse,
        );
      });

      testWidgets('BUG SGC-1564 Has ScrollArrows', (tester) async {
        await tester.goToEyeButtonSwitches();
        expect(find.byType(ScrollArrows), findsOneWidget);
      });
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> goToDayCalendarSettingsPage({bool pump = false}) async {
    if (pump) await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.day));
    await pumpAndSettle();
  }

  Future<void> goToEyeButtonSwitches() async {
    await goToDayCalendarSettingsPage(pump: true);
    await tap(find.byIcon(AbiliaIcons.show));
    await pumpAndSettle();
    final center = getCenter(find.byType(EyeButtonSettingsTab));
    await dragFrom(center, const Offset(0.0, -800));
    await pumpAndSettle();
  }
}
