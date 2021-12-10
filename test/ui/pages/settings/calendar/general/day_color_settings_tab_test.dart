import 'package:flutter_test/flutter_test.dart';

import 'dart:async';

import 'package:get_it/get_it.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';
import '../../../../../test_helpers/verify_generic.dart';

void main() {
  final initialTime = DateTime(2021, 04, 23, 13, 37);

  Iterable<Generic> generics;
  late MockGenericDb genericDb;

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;
    generics = [];

    genericDb = MockGenericDb();
    when(() => genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => genericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

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
      ..battery = FakeBattery()
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
        key: MemoplannerSettings.calendarDayColorKey,
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
        key: MemoplannerSettings.calendarDayColorKey,
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
        key: MemoplannerSettings.calendarDayColorKey,
        matcher: DayColor.noColors.index,
      );
    });
  }, skip: !Config.isMP);

  group('day color visisbility settings', () {
    const noDayColor = AbiliaColors.black80,
        fridayColor = AbiliaColors.yellow,
        saturdayColor = AbiliaColors.pink;

    void _expectCorrectColor(WidgetTester tester, Color color) {
      final at = find.byKey(TestKey.animatedTheme);
      expect(at, findsOneWidget);
      final theme = tester.firstWidget(at) as AnimatedTheme;
      expect(theme.data.appBarTheme.backgroundColor, color);
    }

    testWidgets('all colors standard respected ', (tester) async {
      await tester.pumpApp();
      _expectCorrectColor(tester, fridayColor);
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      _expectCorrectColor(tester, saturdayColor);
    });

    testWidgets('no color respected ', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: DayColor.noColors.index,
            identifier: MemoplannerSettings.calendarDayColorKey,
          ),
        ),
      ];

      await tester.pumpApp();

      _expectCorrectColor(tester, noDayColor);
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      _expectCorrectColor(tester, noDayColor);
    });

    testWidgets('weekend color respected ', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: DayColor.saturdayAndSunday.index,
            identifier: MemoplannerSettings.calendarDayColorKey,
          ),
        ),
      ];

      await tester.pumpApp();

      _expectCorrectColor(tester, noDayColor);
      await tester.tap(find.byIcon(AbiliaIcons.goToNextPage));
      await tester.pumpAndSettle();
      _expectCorrectColor(tester, saturdayColor);
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
