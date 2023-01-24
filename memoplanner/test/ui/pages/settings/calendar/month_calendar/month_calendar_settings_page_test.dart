import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';

import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';
import '../../../../../test_helpers/verify_generic.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 05, 03, 16, 25);
  Iterable<Generic> generics;
  late MockGenericDb genericDb;

  setUp(() async {
    setupPermissions();
    generics = [];
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
      ..client = Fakes.client(genericResponse: () => generics)
      ..database = FakeDatabase()
      ..genericDb = genericDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
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
      expect(find.byIcon(AbiliaIcons.goToNextPage), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.returnToPreviousPage), findsOneWidget);
      expect(find.text('May'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
    });

    testWidgets('memosettings respected', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MonthCalendarSettings.monthCaptionShowClockKey,
            data: false,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MonthCalendarSettings.monthCaptionShowMonthButtonsKey,
            data: false,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MonthCalendarSettings.monthCaptionShowYearKey,
            data: false,
          ),
        ),
      ];
      await tester.goToMonthCalendarSettingsPage();
      expect(find.byType(AbiliaClock), findsNothing);
      expect(find.byIcon(AbiliaIcons.goToNextPage), findsNothing);
      expect(find.byIcon(AbiliaIcons.returnToPreviousPage), findsNothing);
      expect(find.text('2021'), findsNothing);
      expect(find.text('Monday'), findsOneWidget);
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
        key: MonthCalendarSettings.monthCaptionShowMonthButtonsKey,
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
        key: MonthCalendarSettings.monthCaptionShowYearKey,
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
        key: MonthCalendarSettings.monthCaptionShowClockKey,
        matcher: isFalse,
      );
    });
  }, skip: !Config.isMP);

  group('respected in month app bar', () {
    testWidgets('defaults', (tester) async {
      await tester.goToMonthCalendar();
      expect(find.byType(AbiliaClock), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.goToNextPage), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.returnToPreviousPage), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('May'), findsOneWidget);
      expect(find.text('2021'), findsOneWidget);
    });

    testWidgets('memosettings respected', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MonthCalendarSettings.monthCaptionShowClockKey,
            data: false,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MonthCalendarSettings.monthCaptionShowMonthButtonsKey,
            data: false,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MonthCalendarSettings.monthCaptionShowYearKey,
            data: false,
          ),
        ),
      ];
      await tester.goToMonthCalendar();
      expect(find.byType(AbiliaClock), findsNothing);
      expect(find.byIcon(AbiliaIcons.goToNextPage), findsNothing);
      expect(find.byIcon(AbiliaIcons.returnToPreviousPage), findsNothing);
      expect(find.text('2021'), findsNothing);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('May'), findsOneWidget);
    });
  });

  group('display settings', () {
    testWidgets('defaults', (tester) async {
      await tester.goToDisplayTab();
      final w = tester.widget<AbiliaRadio>(
          find.byKey(const ObjectKey(TestKey.monthColorSwitch)));
      expect(w.groupValue, WeekColor.columns.index);
      final dayContainer = tester.firstWidget<Container>(
          find.byKey(TestKey.monthDisplaySettingsDayView));
      expect((dayContainer.decoration as BoxDecoration).color,
          isNot(AbiliaColors.white110));
    });

    testWidgets('memosettings respected', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            identifier: MonthCalendarSettings.calendarMonthViewShowColorsKey,
            data: WeekColor.captions.index,
          ),
        ),
      ];
      await tester.goToDisplayTab();
      final w = tester.widget<AbiliaRadio>(
          find.byKey(const ObjectKey(TestKey.monthColorSwitch)));
      expect(w.groupValue, WeekColor.captions.index);
      final dayContainer = tester.firstWidget<Container>(
          find.byKey(TestKey.monthDisplaySettingsDayView));
      expect(
          (dayContainer.decoration as BoxDecoration).color, AbiliaColors.white);
    });

    testWidgets('color saved', (tester) async {
      await tester.goToDisplayTab();
      final dayContainer1 = tester.firstWidget<Container>(
          find.byKey(TestKey.monthDisplaySettingsDayView));
      expect((dayContainer1.decoration as BoxDecoration).color,
          isNot(AbiliaColors.white110));

      await tester.tap(find.text(translate.captions));
      await tester.pumpAndSettle();
      final dayContainer2 = tester.firstWidget<Container>(
          find.byKey(TestKey.monthDisplaySettingsDayView));

      expect((dayContainer2.decoration as BoxDecoration).color,
          AbiliaColors.white);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifySyncGeneric(
        tester,
        genericDb,
        key: MonthCalendarSettings.calendarMonthViewShowColorsKey,
        matcher: WeekColor.captions.index,
      );
    });
  }, skip: !Config.isMP);

  group('respected in month calendar', () {
    testWidgets(
      'defaults',
      (tester) async {
        await tester.goToMonthCalendar();
        final dayContainer = tester.firstWidget<Container>(
          find.descendant(
            of: find.byWidgetPredicate((widget) =>
                widget is MonthDayView && widget.monthDay.isPast == false),
            matching: find.byKey(TestKey.monthCalendarDayBackgroundColor),
          ),
        );

        expect((dayContainer.decoration as BoxDecoration).color,
            isNot(AbiliaColors.white110));
      },
      skip: Config.isMPGO,
    );

    testWidgets(
      'color respected',
      (tester) async {
        generics = [
          Generic.createNew<MemoplannerSettingData>(
            data: MemoplannerSettingData.fromData(
              identifier: MonthCalendarSettings.calendarMonthViewShowColorsKey,
              data: WeekColor.captions.index,
            ),
          ),
        ];
        await tester.goToMonthCalendar();
        final dayContainer = tester.firstWidget<Container>(
          find.byKey(TestKey.monthCalendarDayBackgroundColor),
        );
        expect((dayContainer.decoration as BoxDecoration).color,
            AbiliaColors.white110);
      },
      skip: Config.isMPGO,
    );
  });
}

extension on WidgetTester {
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
    await tap(find.byIcon(AbiliaIcons.menuSetup));
    await pumpAndSettle();
  }

  Future<void> goToMonthCalendar({bool pump = true}) async {
    if (pump) await pumpApp();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
  }
}
