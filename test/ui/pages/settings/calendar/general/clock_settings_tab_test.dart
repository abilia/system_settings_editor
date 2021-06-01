import 'package:flutter_test/flutter_test.dart';

import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../../mocks.dart';
import '../../../../../utils/verify_generic.dart';

void main() {
  final initialTime = DateTime(2021, 04, 13, 13, 37);
  final translate = Locales.language.values.first;

  Iterable<Generic> generics;
  GenericDb genericDb;
  final timepillarGeneric = Generic.createNew<MemoplannerSettingData>(
    data: MemoplannerSettingData.fromData(
        data: DayCalendarType.TIMEPILLAR.index,
        identifier: MemoplannerSettings.viewOptionsTimeViewKey),
  );

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    generics = [timepillarGeneric];

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

  testWidgets('shows', (tester) async {
    await tester.goToGeneralCalendarSettingsPage();
    expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.clock), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.day_interval), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.change_page_color), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.calendar_list), findsOneWidget);
    expect(find.byType(ClockSettingsTab), findsOneWidget);
    expect(find.byType(IntervalsSettingsTab), findsNothing);
    expect(find.byType(DayColorsSettingsTab), findsNothing);
    expect(find.byType(CategoriesSettingsTab), findsNothing);
    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  }, skip: !Config.isMP);

  group('clock', () {
    testWidgets('digital clock choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.tap(find.text(translate.digital));
      await tester.pumpAndSettle();

      expect(find.byType(AnalogClock), findsNothing);
      expect(find.byType(DigitalClock), findsOneWidget);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingClockTypeKey,
        matcher: ClockType.digital.index,
      );
    });

    testWidgets('analog clock choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.tap(find.text(translate.analogue));
      await tester.pumpAndSettle();

      expect(find.byType(AnalogClock), findsOneWidget);
      expect(find.byType(DigitalClock), findsNothing);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingClockTypeKey,
        matcher: ClockType.analogue.index,
      );
    });
  }, skip: !Config.isMP);

  group('clock visisbility settings', () {
    testWidgets('Default settings digital and analogue', (tester) async {
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(DigitalClock), findsOneWidget);
      expect(find.byType(AnalogClock), findsOneWidget);
    });

    testWidgets('hides digital', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: ClockType.analogue.index,
            identifier: MemoplannerSettings.settingClockTypeKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(AnalogClock), findsOneWidget);
      expect(find.byType(DigitalClock), findsNothing);
    });

    testWidgets('hides analog', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: ClockType.digital.index,
            identifier: MemoplannerSettings.settingClockTypeKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(AnalogClock), findsNothing);
      expect(find.byType(DigitalClock), findsOneWidget);
    });
  });

  group('timepillar', () {
    testWidgets('12h format disabled', (tester) async {
      await tester.goToGeneralCalendarSettingsPage(use24: false);
      await tester.dragUntilVisible(
        find.byKey(TestKey.use12hSwitch),
        find.byType(ClockSettingsTab),
        Offset(0, -100),
      );

      final toggle =
          tester.widget<Switch>(find.byKey(ObjectKey(TestKey.use12hSwitch)));
      expect(toggle.onChanged, isNull);
      expect(toggle.value, isTrue);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('24h changes to 12h', (tester) async {
      await tester.goToGeneralCalendarSettingsPage(use24: true);
      await tester.dragUntilVisible(
        find.byKey(TestKey.use12hSwitch),
        find.byType(ClockSettingsTab),
        Offset(0, -100),
      );

      final toggle =
          tester.widget<Switch>(find.byKey(ObjectKey(TestKey.use12hSwitch)));

      expect(toggle.onChanged, isNotNull);
      expect(toggle.value, isFalse);
      expect(find.text('13'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);

      await tester.tap(find.byKey(TestKey.use12hSwitch));
      await tester.pumpAndSettle();

      expect(find.text('13'), findsNothing);
      expect(find.text('14'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.setting12hTimeFormatTimelineKey,
        matcher: isTrue,
      );
    });

    testWidgets('pillars of dots', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.dragUntilVisible(
        find.text(translate.columnOfDots),
        find.byType(ClockSettingsTab),
        Offset(0, -100),
      );

      final timepillarBefore =
          tester.widget<TimePillar>(find.byType(TimePillar));

      expect(timepillarBefore.columnOfDots, isFalse);

      await tester.tap(find.text(translate.columnOfDots));
      await tester.pumpAndSettle();
      final timepillarAfter =
          tester.widget<TimePillar>(find.byType(TimePillar));

      expect(timepillarAfter.columnOfDots, isTrue);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingTimePillarTimelineKey,
        matcher: isTrue,
      );
    });

    testWidgets('timeline', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.dragUntilVisible(
        find.text(translate.lineAcrossCurrentTime),
        find.byType(ClockSettingsTab),
        Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Timeline), findsWidgets);

      await tester.tap(find.text(translate.lineAcrossCurrentTime));
      await tester.pumpAndSettle();

      expect(find.byType(Timeline), findsNothing);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingDisplayTimelineKey,
        matcher: isFalse,
      );
    });

    testWidgets('linesForEachHour', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.dragUntilVisible(
        find.text(translate.linesForEachHour),
        find.byType(ClockSettingsTab),
        Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HourLines), findsNothing);

      await tester.tap(find.text(translate.linesForEachHour));
      await tester.pumpAndSettle();

      expect(find.byType(HourLines), findsWidgets);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingDisplayHourLinesKey,
        matcher: isTrue,
      );
    });
  }, skip: !Config.isMP);

  group('timepillar settings', () {
    testWidgets('timePillar standard settings 12h', (tester) async {
      await tester.pumpApp(use24: false);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('13'), findsNothing);
      expect(find.text('14'), findsNothing);
      expect(
        tester.widget<TimePillar>(find.byType(TimePillar)).columnOfDots,
        isFalse,
      );
      expect(find.byType(Timeline), findsWidgets);
      expect(find.byType(HourLines), findsNothing);
    });

    testWidgets('timePillar standard settings 24h', (tester) async {
      await tester.pumpApp(use24: true);
      expect(find.text('13'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);
      expect(find.text('1'), findsNothing);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('12h true in 24h settings', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: MemoplannerSettings.setting12hTimeFormatTimelineKey,
          ),
        ),
        timepillarGeneric,
      ];
      await tester.pumpApp(use24: true);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('13'), findsNothing);
      expect(find.text('14'), findsNothing);
    });

    testWidgets('column of red dots', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: MemoplannerSettings.settingTimePillarTimelineKey,
          ),
        ),
        timepillarGeneric,
      ];
      await tester.pumpApp(use24: false);
      expect(
        tester.widget<TimePillar>(find.byType(TimePillar)).columnOfDots,
        isTrue,
      );
    });

    testWidgets('time line hides', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingDisplayTimelineKey,
          ),
        ),
        timepillarGeneric,
      ];
      await tester.pumpApp(use24: false);
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('HourLines shows', (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: MemoplannerSettings.settingDisplayHourLinesKey,
          ),
        ),
        timepillarGeneric,
      ];
      await tester.pumpApp(use24: false);
      expect(find.byType(HourLines), findsWidgets);
    });
  });
}

extension on WidgetTester {
  Future<void> goToGeneralCalendarSettingsPage({bool use24 = false}) async {
    await pumpApp(use24: use24);
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.settings));
    await pumpAndSettle();
  }
}
