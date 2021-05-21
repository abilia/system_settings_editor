import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../../mocks.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Generic> generics = [];
  GenericDb genericDb;

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockBatch = MockBatch();
    when(mockBatch.commit()).thenAnswer((realInvocation) => Future.value([]));
    final db = MockDatabase();
    when(db.batch()).thenReturn(mockBatch);
    when(db.rawQuery(any)).thenAnswer((realInvocation) => Future.value([]));

    genericDb = MockGenericDb();
    when(genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(genericDb.insertAndAddDirty(any))
        .thenAnswer((realInvocation) => Future.value([]));

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: initialTime,
      )
      ..client = Fakes.client(genericResponse: () => generics)
      ..alarmScheduler = noAlarmScheduler
      ..database = db
      ..syncDelay = SyncDelays.zero
      ..genericDb = genericDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  Future _verifySaved(
    WidgetTester tester, {
    String key,
    dynamic matcher,
    bool yesOnDialog = false,
  }) async {
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();
    if (yesOnDialog) {
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();
    }

    final v = verify(genericDb.insertAndAddDirty(captureAny));
    expect(v.callCount, 1);
    final l = v.captured.single.toList() as List<Generic<GenericData>>;
    final d = l
        .whereType<Generic<MemoplannerSettingData>>()
        .firstWhere((element) => element.data.identifier == key);
    expect(d.data.data, matcher);
  }

  group('Day calendar settings page', () {
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

        await _verifySaved(
          tester,
          key: MemoplannerSettings.dayCaptionShowDayButtonsKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide week day', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.text(translate.showWeekday));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.activityDisplayWeekDayKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide time period', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.text(translate.showDayPeriod));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.activityDisplayDayPeriodKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide date', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.text(translate.showDate));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
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

        await _verifySaved(
          tester,
          key: MemoplannerSettings.activityDisplayClockKey,
          matcher: isFalse,
        );
      });

      testWidgets('Select list', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menu_setup));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.calendar_list));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.viewOptionsTimeViewKey,
          matcher: DayCalendarType.LIST.index,
        );
      });

      testWidgets('Set timepillar interval', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menu_setup));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.day_night));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.viewOptionsTimeIntervalKey,
          matcher: TimepillarIntervalType.DAY_AND_NIGHT.index,
        );
      });

      testWidgets('Set timepillar zoom', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menu_setup));
        await tester.pumpAndSettle();
        await tester.tap(find.text(translate.large));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.viewOptionsZoomKey,
          matcher: TimepillarZoom.LARGE.index,
        );
      });

      testWidgets('Set timepillar dots', (tester) async {
        await tester.goToDayCalendarSettingsPage(pump: true);
        await tester.tap(find.byIcon(AbiliaIcons.menu_setup));
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(find.byIcon(AbiliaIcons.flarp),
            find.byType(DayAppBarSettingsTab), Offset(0, 100));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(AbiliaIcons.flarp));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.dotsInTimepillarKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide type of display in eye button', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showTypeOfDisplaySwitch));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.settingViewOptionsTimeViewKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide interval setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showTimepillarLengthSwitch));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.settingViewOptionsTimeIntervalKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide zoom setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showTimelineZoomSwitch));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.settingViewOptionsZoomKey,
          matcher: isFalse,
        );
      });

      testWidgets('Hide time display setting', (tester) async {
        await tester.goToEyeButtonSwitches();
        await tester.tap(find.byKey(TestKey.showDurationSelectionSwitch));
        await tester.pumpAndSettle();

        await _verifySaved(
          tester,
          key: MemoplannerSettings.settingViewOptionsDurationDotsKey,
          matcher: isFalse,
        );
      });
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

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
