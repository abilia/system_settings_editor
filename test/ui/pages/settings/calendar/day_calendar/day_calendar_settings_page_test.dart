import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/shared.mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';
import '../../../../../test_helpers/verify_generic.dart';

void main() {
  group('Day calendar settings page', () {
    final translate = Locales.language.values.first;
    final initialTime = DateTime(2021, 04, 17, 09, 20);
    Iterable<Generic> generics = [];
    late MockGenericDb genericDb;

    setUp(() async {
      setupPermissions();
      notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
      scheduleAlarmNotificationsIsolated = noAlarmScheduler;

      genericDb = MockGenericDb();
      when(genericDb.getAllNonDeletedMaxRevision())
          .thenAnswer((_) => Future.value(generics));
      when(genericDb.insertAndAddDirty(any))
          .thenAnswer((_) => Future.value(true));
      when(genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));

      GetItInitializer()
        ..sharedPreferences = await FakeSharedPreferences.getInstance()
        ..ticker = Ticker(
          stream: StreamController<DateTime>().stream,
          initialTime: initialTime,
        )
        ..client = Fakes.client(genericResponse: () => generics)
        ..database = FakeDatabase()
        ..syncDelay = SyncDelays.zero
        ..genericDb = genericDb
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
          key: MemoplannerSettings.dayCaptionShowDayButtonsKey,
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
          key: MemoplannerSettings.activityDisplayWeekDayKey,
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
          key: MemoplannerSettings.activityDisplayDayPeriodKey,
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
          key: MemoplannerSettings.activityDisplayDateKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide clock', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.dragUntilVisible(find.text(translate.showClock),
            find.byType(DayAppBarSettingsTab), Offset(0, 100));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.showClock));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.activityDisplayClockKey,
          matcher: isFalse,
        );
      });

      testWidgets('Select list', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.calendarList));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.viewOptionsTimeViewKey,
          matcher: DayCalendarType.list.index,
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
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.viewOptionsTimeViewKey,
          matcher: DayCalendarType.twoTimepillars.index,
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
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.viewOptionsTimeIntervalKey,
          matcher: TimepillarIntervalType.dayAndNight.index,
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
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.viewOptionsZoomKey,
          matcher: TimepillarZoom.large.index,
        );
      });

      testWidgets('Set timepillar dots', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(find.byIcon(AbiliaIcons.flarp),
            find.byType(DayAppBarSettingsTab), Offset(0, 100));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.flarp));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.dotsInTimepillarKey,
          matcher: isFalse,
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
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.settingViewOptionsTimeViewKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide interval setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showTimepillarLengthSwitch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.settingViewOptionsTimeIntervalKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide zoom setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showTimelineZoomSwitch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.settingViewOptionsZoomKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide time display setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showDurationSelectionSwitch));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(OkButton));
        await tester.pumpAndSettle();
        verifySyncGeneric(
          tester,
          genericDb,
          key: MemoplannerSettings.settingViewOptionsDurationDotsKey,
          matcher: isFalse,
        );
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
    await dragFrom(center, Offset(0.0, -800));
    await pumpAndSettle();
  }
}
