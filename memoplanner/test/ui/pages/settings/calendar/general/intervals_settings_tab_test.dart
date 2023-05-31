import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:seagull_fakes/all.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';

void main() {
  final initialTime = DateTime(2021, 04, 16, 13, 37);

  Iterable<Generic> generics;
  late MockGenericDb genericDb;

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
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
      ..client = Fakes.client(genericResponse: () => generics)
      ..database = FakeDatabase()
      ..genericDb = genericDb
      ..sortableDb = FakeSortableDb()
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('shows', (tester) async {
    await tester.goToGeneralCalendarSettingsPageIntervalTab();
    expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.clock), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.dayInterval), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.changePageColor), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.calendarList), findsOneWidget);
    expect(find.byType(ClockSettingsTab), findsNothing);
    expect(find.byType(IntervalsSettingsTab), findsOneWidget);
    expect(find.byType(DayColorsSettingsTab), findsNothing);
    expect(find.byType(CategoriesSettingsTab), findsNothing);
    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  }, skip: !Config.isMP);

  group('time interval', () {
    testWidgets('Default time interval 12h clock', (tester) async {
      // Act
      await tester.goToGeneralCalendarSettingsPageIntervalTab();
      // Assert
      expect(find.text('6:00 AM'), findsOneWidget);
      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('6:00 PM'), findsOneWidget);
      expect(find.text('11:00 PM'), findsOneWidget);
    });

    testWidgets('Default time interval 24h clock', (tester) async {
      // Act
      await tester.goToGeneralCalendarSettingsPageIntervalTab(use24: true);
      // Assert
      expect(find.text('06:00'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('18:00'), findsOneWidget);
      expect(find.text('23:00'), findsOneWidget);
    });

    testWidgets('time interval choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepRight(DayPart.morning);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifyGenerics(tester, genericDb, keyMatch: {
        DayParts.morningIntervalStartKey: 7 * Duration.millisecondsPerHour,
      });
    });

    testWidgets('decrease morning 4 times increase day by 1 hour',
        (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepRight(DayPart.morning, times: 4);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifyGenerics(tester, genericDb, keyMatch: {
        DayParts.forenoonIntervalStartKey: 11 * Duration.millisecondsPerHour,
      });
    });

    testWidgets('max everything disables all increase buttons', (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepRight(DayPart.morning, times: 4);
      await tester.stepRight(DayPart.day, times: 7);
      await tester.stepRight(DayPart.evening, times: 2);
      await tester.stepRight(DayPart.night);

      final morningRight = tester.widget<IconActionButtonDark>(
          find.byKey(IntervalStepper.rightStepKey(DayPart.morning)));
      final dayRight = tester.widget<IconActionButtonDark>(
          find.byKey(IntervalStepper.rightStepKey(DayPart.day)));
      final eveningRight = tester.widget<IconActionButtonDark>(
          find.byKey(IntervalStepper.rightStepKey(DayPart.evening)));
      final nightRight = tester.widget<IconActionButtonDark>(
          find.byKey(IntervalStepper.rightStepKey(DayPart.night)));

      expect(morningRight.onPressed, isNull);
      expect(dayRight.onPressed, isNull);
      expect(eveningRight.onPressed, isNull);
      expect(nightRight.onPressed, isNull);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifyGenerics(tester, genericDb, keyMatch: {
        DayParts.morningIntervalStartKey: 10 * Duration.millisecondsPerHour,
        DayParts.forenoonIntervalStartKey: 18 * Duration.millisecondsPerHour,
        DayParts.eveningIntervalStartKey: 21 * Duration.millisecondsPerHour,
        DayParts.nightIntervalStartKey: 24 * Duration.millisecondsPerHour,
      });
    });

    testWidgets('min everything disables all decrease buttons', (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepLeft(DayPart.morning);
      await tester.stepLeft(DayPart.day, times: 2);
      await tester.stepLeft(DayPart.evening, times: 2);
      await tester.stepLeft(DayPart.night, times: 4);

      final morningRight = tester.widget<IconActionButtonDark>(
          find.byKey(IntervalStepper.leftStepKey(DayPart.morning)));
      final dayRight = tester.widget<IconActionButtonDark>(
          find.byKey(IntervalStepper.leftStepKey(DayPart.day)));
      final eveningRight = tester.widget<IconActionButtonDark>(
          find.byKey(IntervalStepper.leftStepKey(DayPart.evening)));
      final nightRight = tester.widget<IconActionButtonDark>(
          find.byKey(IntervalStepper.leftStepKey(DayPart.night)));

      expect(morningRight.onPressed, isNull);
      expect(dayRight.onPressed, isNull);
      expect(eveningRight.onPressed, isNull);
      expect(nightRight.onPressed, isNull);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      verifyGenerics(tester, genericDb, keyMatch: {
        DayParts.morningIntervalStartKey: 5 * Duration.millisecondsPerHour,
        DayParts.forenoonIntervalStartKey: 8 * Duration.millisecondsPerHour,
        DayParts.eveningIntervalStartKey: 16 * Duration.millisecondsPerHour,
        DayParts.nightIntervalStartKey: 19 * Duration.millisecondsPerHour,
      });
    });

    testWidgets('max day and evening, then min night', (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepRight(DayPart.day, times: 8);
      expect(find.text('6:00 AM'), findsOneWidget);
      expect(find.text('6:00 PM'), findsOneWidget);
      expect(find.text('7:00 PM'), findsOneWidget);
      expect(find.text('11:00 PM'), findsOneWidget);

      await tester.stepLeft(DayPart.night, times: 4);

      expect(find.text('6:00 AM'), findsOneWidget);
      expect(find.text('5:00 PM'), findsOneWidget);
      expect(find.text('6:00 PM'), findsOneWidget);
      expect(find.text('7:00 PM'), findsOneWidget);
    });
  }, skip: !Config.isMP);

  group('time interval visisbility settings', () {
    testWidgets('Change time interval - one timepillar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: 10 * Duration.millisecondsPerHour,
            identifier: DayParts.morningIntervalStartKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: 12 * Duration.millisecondsPerHour,
            identifier: DayParts.forenoonIntervalStartKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: 19 * Duration.millisecondsPerHour,
            identifier: DayParts.nightIntervalStartKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: DayCalendarType.oneTimepillar.index,
            identifier:
                DayCalendarViewOptionsSettings.viewOptionsCalendarTypeKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp(use24: true);
      // Assert
      expect(find.text('09'), findsNothing);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
      expect(find.text('20'), findsNothing);
    });

    testWidgets('Change time interval - two timepillars', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: 10 * Duration.millisecondsPerHour,
            identifier: DayParts.morningIntervalStartKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: 12 * Duration.millisecondsPerHour,
            identifier: DayParts.forenoonIntervalStartKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: 19 * Duration.millisecondsPerHour,
            identifier: DayParts.nightIntervalStartKey,
          ),
        ),
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
              data: DayCalendarType.twoTimepillars.index,
              identifier:
                  DayCalendarViewOptionsSettings.viewOptionsCalendarTypeKey),
        ),
      ];
      // Act
      await tester.pumpApp(use24: true);
      // Assert
      expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
      expect(find.byType(OneTimepillarCalendar), findsNWidgets(2));
      expect(find.text('09'), findsOneWidget);
      expect(find.text('10'), findsNWidgets(2));
      expect(find.text('14'), findsOneWidget);
      expect(find.text('19'), findsNWidgets(2));
      expect(find.text('20'), findsOneWidget);
    });
  });
}

extension on WidgetTester {
  Future<void> goToGeneralCalendarSettingsPageIntervalTab(
      {bool use24 = false}) async {
    await pumpApp(use24: use24);
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.month));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.settings));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.dayInterval));
    await pumpAndSettle();
  }

  Future<void> stepRight(DayPart dayPart, {int times = 1}) async {
    for (var i = 0; i < times; i++) {
      await tap(find.byKey(IntervalStepper.rightStepKey(dayPart)));
      await pumpAndSettle();
    }
  }

  Future<void> stepLeft(DayPart dayPart, {int times = 1}) async {
    for (var i = 0; i < times; i++) {
      await tap(find.byKey(IntervalStepper.leftStepKey(dayPart)));
      await pumpAndSettle();
    }
  }
}
