// @dart=2.9

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
import '../../../../../utils/verify_generic.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 05, 03, 16, 25);
  Iterable<Generic> generics;
  GenericDb genericDb;

  setUp(() async {
    setupPermissions();
    generics = [];
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

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
        .thenAnswer((_) => Future.value(true));

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: initialTime,
      )
      ..client = Fakes.client(genericResponse: () => generics)
      ..database = db
      ..syncDelay = SyncDelays.zero
      ..genericDb = genericDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('shows', (tester) async {
    await tester.goToMonthCalendarSettingsPage();
    expect(find.byType(MonthCalendarSettingsPage), findsOneWidget);
    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  }, skip: !Config.isMP);

  group('app bar setting', () {
    testWidgets('defaults', (tester) async {
      await tester.goToMonthCalendarSettingsPage();
      expect(find.byType(AbiliaClock), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.go_to_next_page), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.return_to_previous_page), findsOneWidget);
      expect(find.text('May'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
    });

    testWidgets('memosettings respected', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MemoplannerSettings.monthCaptionShowClockKey,
            data: false,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MemoplannerSettings.monthCaptionShowMonthButtonsKey,
            data: false,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MemoplannerSettings.monthCaptionShowYearKey,
            data: false,
          ),
        ),
      ];
      await tester.goToMonthCalendarSettingsPage();
      expect(find.byType(AbiliaClock), findsNothing);
      expect(find.byIcon(AbiliaIcons.go_to_next_page), findsNothing);
      expect(find.byIcon(AbiliaIcons.return_to_previous_page), findsNothing);
      expect(find.text('May 2021'), findsNothing);
      expect(find.text('May'), findsOneWidget);
    });

    testWidgets('Hide browse buttons', (tester) async {
      await tester.goToMonthCalendarSettingsPage();
      await tester.tap(find.text(translate.showBrowseButtons));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.monthCaptionShowMonthButtonsKey,
        matcher: isFalse,
      );
    });

    testWidgets('Hide year', (tester) async {
      await tester.goToMonthCalendarSettingsPage();
      await tester.tap(find.text(translate.showYear));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.monthCaptionShowYearKey,
        matcher: isFalse,
      );
    });

    testWidgets('Hide time period', (tester) async {
      await tester.goToMonthCalendarSettingsPage();
      await tester.tap(find.text(translate.showClock));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.monthCaptionShowClockKey,
        matcher: isFalse,
      );
    });
  }, skip: !Config.isMP);

  group('respected in month app bar', () {
    testWidgets('defaults', (tester) async {
      await tester.goToMonthCalendar();
      expect(find.byType(AbiliaClock), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.go_to_next_page), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.return_to_previous_page), findsOneWidget);
      expect(find.text('May'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
    });

    testWidgets('memosettings respected', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MemoplannerSettings.monthCaptionShowClockKey,
            data: false,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MemoplannerSettings.monthCaptionShowMonthButtonsKey,
            data: false,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MemoplannerSettings.monthCaptionShowYearKey,
            data: false,
          ),
        ),
      ];
      await tester.goToMonthCalendar();
      expect(find.byType(AbiliaClock), findsNothing);
      expect(find.byIcon(AbiliaIcons.go_to_next_page), findsNothing);
      expect(find.byIcon(AbiliaIcons.return_to_previous_page), findsNothing);
      expect(find.text('May 2021'), findsNothing);
      expect(find.text('May'), findsOneWidget);
    });
  });

  group('display settings', () {
    testWidgets('defaults', (tester) async {
      await tester.goToDisplayTab();
      final w = tester
          .widget<AbiliaRadio>(find.byKey(ObjectKey(TestKey.monthColorSwith)));
      expect(w.groupValue, WeekColor.columns);
      final dayContainer =
          tester.firstWidget<MonthDayContainer>(find.byType(MonthDayContainer));
      expect(dayContainer.color, isNot(AbiliaColors.white110));
    });

    testWidgets('memosettings respected', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MemoplannerSettings.calendarMonthViewShowColorsKey,
            data: WeekColor.captions.index,
          ),
        ),
      ];
      await tester.goToDisplayTab();
      final w = tester
          .widget<AbiliaRadio>(find.byKey(ObjectKey(TestKey.monthColorSwith)));
      expect(w.groupValue, WeekColor.captions);
      final dayContainer =
          tester.firstWidget<MonthDayContainer>(find.byType(MonthDayContainer));
      expect(dayContainer.color, AbiliaColors.white110);
    });

    testWidgets('color saved', (tester) async {
      await tester.goToDisplayTab();
      final dayContainer1 =
          tester.firstWidget<MonthDayContainer>(find.byType(MonthDayContainer));
      expect(dayContainer1.color, isNot(AbiliaColors.white110));

      await tester.tap(find.text(translate.headings));
      await tester.pumpAndSettle();
      final dayContainer2 =
          tester.firstWidget<MonthDayContainer>(find.byType(MonthDayContainer));

      expect(dayContainer2.color, AbiliaColors.white110);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.calendarMonthViewShowColorsKey,
        matcher: WeekColor.captions.index,
      );
    });
  }, skip: !Config.isMP);

  group('respected in month calendar', () {
    testWidgets('defaults', (tester) async {
      await tester.goToMonthCalendar();
      final dayContainer =
          tester.firstWidget<MonthDayContainer>(find.byType(MonthDayContainer));
      expect(dayContainer.color, isNot(AbiliaColors.white110));
    });

    testWidgets('color respected', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MemoplannerSettings.calendarMonthViewShowColorsKey,
            data: WeekColor.captions.index,
          ),
        ),
      ];
      await tester.goToMonthCalendar();
      final dayContainer =
          tester.firstWidget<MonthDayContainer>(find.byType(MonthDayContainer));
      expect(dayContainer.color, AbiliaColors.white110);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToMonthCalendarSettingsPage() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.text(Locales.language.values.first.monthCalendar));
    await pumpAndSettle();
  }

  Future<void> goToDisplayTab() async {
    await goToMonthCalendarSettingsPage();
    await tap(find.byIcon(AbiliaIcons.menu_setup));
    await pumpAndSettle();
  }

  Future<void> goToMonthCalendar({bool pump = true}) async {
    if (pump) await pumpApp();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
  }
}
