import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
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
  final initialTime = DateTime(2021, 04, 13, 13, 37);
  late final Lt translate;

  Iterable<Generic> generics;
  late MockGenericDb genericDb;
  late SharedPreferences fakeSharedPreferences;

  setUpAll(() async {
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);
  });

  setUp(() async {
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

    fakeSharedPreferences = await FakeSharedPreferences.getInstance(extras: {
      DayCalendarViewSettings.viewOptionsCalendarTypeKey:
          DayCalendarType.oneTimepillar.index,
    });

    GetItInitializer()
      ..sharedPreferences = fakeSharedPreferences
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

  testWidgets('shows', (tester) async {
    await tester.goToGeneralCalendarSettingsPage();
    expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.clock), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.dayInterval), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.changePageColor), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.calendarList), findsOneWidget);
    expect(find.byType(ClockSettingsTab), findsOneWidget);
    expect(find.byType(IntervalsSettingsTab), findsNothing);
    expect(find.byType(DayColorsSettingsTab), findsNothing);
    expect(find.byType(CategoriesSettingsTab), findsNothing);
    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  }, skip: !Config.isMP);

  testWidgets('BUG SGC-1564 Has ScrollArrows', (tester) async {
    await tester.goToGeneralCalendarSettingsPage();
    expect(find.byType(ScrollArrows), findsOneWidget);
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
      verifySyncGeneric(
        tester,
        genericDb,
        key: GeneralCalendarSettings.settingClockTypeKey,
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
      verifySyncGeneric(
        tester,
        genericDb,
        key: GeneralCalendarSettings.settingClockTypeKey,
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
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: ClockType.analogue.index,
            identifier: GeneralCalendarSettings.settingClockTypeKey,
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
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: ClockType.digital.index,
            identifier: GeneralCalendarSettings.settingClockTypeKey,
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
        const Offset(0, -100),
      );

      final toggle = tester
          .widget<Switch>(find.byKey(const ObjectKey(TestKey.use12hSwitch)));
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
        const Offset(0, -100),
      );

      final toggle = tester
          .widget<Switch>(find.byKey(const ObjectKey(TestKey.use12hSwitch)));

      expect(toggle.onChanged, isNotNull);
      expect(toggle.value, isFalse);
      expect(find.text('13'), findsOneWidget);
      expect(find.text('14'), findsOneWidget);

      await tester.dragFrom(
          tester.getCenter(find.byType(Scaffold)), const Offset(0.0, -200));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.use12hSwitch));
      await tester.pumpAndSettle();

      expect(find.text('13'), findsNothing);
      expect(find.text('14'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: TimepillarSettings.setting12hTimeFormatTimelineKey,
        matcher: isTrue,
      );
    });

    testWidgets('pillars of dots', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.dragUntilVisible(
        find.text(translate.columnOfDots),
        find.byType(ClockSettingsTab),
        const Offset(0, -100),
      );

      final timepillarBefore =
          tester.widget<TimePillar>(find.byType(TimePillar));

      expect(timepillarBefore.columnOfDots, isFalse);

      await tester.dragFrom(
          tester.getCenter(find.byType(Scaffold)), const Offset(0.0, -200));
      await tester.pumpAndSettle();

      await tester.tap(find.text(translate.columnOfDots));
      await tester.pumpAndSettle();
      final timepillarAfter =
          tester.widget<TimePillar>(find.byType(TimePillar));

      expect(timepillarAfter.columnOfDots, isTrue);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: TimepillarSettings.settingTimePillarTimelineKey,
        matcher: isTrue,
      );
    });

    testWidgets('timeline', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.dragUntilVisible(
        find.text(translate.lineAcrossCurrentTime),
        find.byType(ClockSettingsTab),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Timeline), findsWidgets);

      await tester.tap(find.text(translate.lineAcrossCurrentTime));
      await tester.pumpAndSettle();

      expect(find.byType(Timeline), findsNothing);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: TimepillarSettings.settingDisplayTimelineKey,
        matcher: isFalse,
      );
    });

    testWidgets('linesForEachHour', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.dragUntilVisible(
        find.text(translate.linesForEachHour),
        find.byType(ClockSettingsTab),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HourLines), findsNothing);

      await tester.tap(find.text(translate.linesForEachHour));
      await tester.pumpAndSettle();

      expect(find.byType(HourLines), findsWidgets);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: TimepillarSettings.settingDisplayHourLinesKey,
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
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: TimepillarSettings.setting12hTimeFormatTimelineKey,
          ),
        ),
      ];
      await tester.pumpApp(use24: true);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('13'), findsNothing);
      expect(find.text('14'), findsNothing);
    });

    testWidgets('column of red dots', (tester) async {
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: TimepillarSettings.settingTimePillarTimelineKey,
          ),
        ),
      ];
      await tester.pumpApp(use24: false);
      expect(
        tester.widget<TimePillar>(find.byType(TimePillar)).columnOfDots,
        isTrue,
      );
    });

    testWidgets('time line hides', (tester) async {
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: TimepillarSettings.settingDisplayTimelineKey,
          ),
        ),
      ];
      await tester.pumpApp(use24: false);
      expect(find.byType(Timeline), findsNothing);
    });

    testWidgets('HourLines shows', (tester) async {
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: true,
            identifier: TimepillarSettings.settingDisplayHourLinesKey,
          ),
        ),
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
