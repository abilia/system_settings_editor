import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_clock/ticker.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';

void main() {
  final initialTime = DateTime(2021, 04, 23, 13, 37);

  Iterable<Generic> generics;
  late MockGenericDb genericDb;

  setUp(() async {
    await Lokalise.initMock();
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;
    generics = [];

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
      ..sortableDb = FakeSortableDb()
      ..genericDb = genericDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('shows', (tester) async {
    await tester.goToGeneralCalendarSettingsPageDayColorsTab();
    expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.clock), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.dayInterval), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.changePageColor), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.calendarList), findsOneWidget);
    expect(find.byType(ClockSettingsTab), findsNothing);
    expect(find.byType(IntervalsSettingsTab), findsNothing);
    expect(find.byType(DayColorsSettingsTab), findsOneWidget);
    expect(find.byType(CategoriesSettingsTab), findsNothing);
    expect(find.byType(MonthHeading), findsOneWidget);
    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  }, skip: !Config.isMP);

  group('day colors', () {
    testWidgets('Default all day colors', (tester) async {
      // Act
      await tester.goToGeneralCalendarSettingsPageDayColorsTab();
      // Assert
      final monthHeading =
          tester.widget<MonthHeading>(find.byType(MonthHeading));
      expect(monthHeading.dayThemes.every((e) => e.isColor), isTrue);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: GeneralCalendarSettings.calendarDayColorKey,
        matcher: DayColor.allDays.index,
      );
    });

    testWidgets('satureday sunday choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPageDayColorsTab();

      await tester.tap(find.byKey(Key('${DayColor.saturdayAndSunday}')));
      await tester.pumpAndSettle();

      final monthHeading =
          tester.widget<MonthHeading>(find.byType(MonthHeading));
      expect(monthHeading.dayThemes.where((e) => e.isColor), hasLength(2));

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: GeneralCalendarSettings.calendarDayColorKey,
        matcher: DayColor.saturdayAndSunday.index,
      );
    });

    testWidgets('no color choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPageDayColorsTab();

      await tester.tap(find.byKey(Key('${DayColor.noColors}')));
      await tester.pumpAndSettle();

      final monthHeading =
          tester.widget<MonthHeading>(find.byType(MonthHeading));
      expect(monthHeading.dayThemes.any((e) => e.isColor), isFalse);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: GeneralCalendarSettings.calendarDayColorKey,
        matcher: DayColor.noColors.index,
      );
    });
  }, skip: !Config.isMP);

  group('day color visisbility settings', () {
    const noDayColor = AbiliaColors.black80,
        fridayColor = AbiliaColors.yellow,
        saturdayColor = AbiliaColors.pink;

    void expectCorrectColor(WidgetTester tester, Color color) {
      final at = find.byKey(TestKey.animatedTheme);
      expect(at, findsOneWidget);
      final theme = tester.firstWidget(at) as AnimatedTheme;
      expect(theme.data.appBarTheme.backgroundColor, color);
    }

    testWidgets('all colors standard respected ', (tester) async {
      await tester.pumpApp();
      expectCorrectColor(tester, fridayColor);
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      expectCorrectColor(tester, saturdayColor);
    });

    testWidgets('no color respected ', (tester) async {
      generics = [
        Generic.createNew(
          data: MemoplannerSettingData(
            data: DayColor.noColors.index,
            identifier: GeneralCalendarSettings.calendarDayColorKey,
          ),
        ),
      ];

      await tester.pumpApp();

      expectCorrectColor(tester, noDayColor);
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      expectCorrectColor(tester, noDayColor);
    });

    testWidgets('weekend color respected ', (tester) async {
      generics = [
        Generic.createNew(
          data: MemoplannerSettingData(
            data: DayColor.saturdayAndSunday.index,
            identifier: GeneralCalendarSettings.calendarDayColorKey,
          ),
        ),
      ];

      await tester.pumpApp();

      expectCorrectColor(tester, noDayColor);
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      expectCorrectColor(tester, saturdayColor);
    });
  });
}

extension on WidgetTester {
  Future<void> goToGeneralCalendarSettingsPageDayColorsTab() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.settings));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.changePageColor));
    await pumpAndSettle();
  }
}
