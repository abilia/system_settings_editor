import 'package:flutter_test/flutter_test.dart';

import 'dart:async';

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
  final initialTime = DateTime(2021, 04, 16, 13, 37);
  // final translate = Locales.language.values.first;

  Iterable<Generic> generics;
  GenericDb genericDb;

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    generics = [];

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
    await tester.goToGeneralCalendarSettingsPageIntervalTab();
    expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.clock), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.day_interval), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.change_page_color), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.calendar_list), findsOneWidget);
    expect(find.byType(ClockSettingsTab), findsNothing);
    expect(find.byType(IntervalsSettingsTab), findsOneWidget);
    expect(find.byType(DayColorsSettingsTab), findsNothing);
    expect(find.byType(CategoriesSettingsTab), findsNothing);
    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  });

  Future _verifySaved(
      WidgetTester tester, Map<String, dynamic> keyMatch) async {
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    final v = verify(genericDb.insertAndAddDirty(captureAny));
    expect(v.callCount, 1);
    final l = v.captured.single.toList() as List<Generic<GenericData>>;
    for (var kvp in keyMatch.entries) {
      final d = l
          .whereType<Generic<MemoplannerSettingData>>()
          .firstWhere((element) => element.data.identifier == kvp.key);
      expect(d.data.data, kvp.value);
    }
  }

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

      await _verifySaved(tester, {
        MemoplannerSettings.morningIntervalStartKey:
            7 * Duration.millisecondsPerHour,
      });
    });

    testWidgets('decrease morning 4 times increase day by 1 hour',
        (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepRight(DayPart.morning, times: 4);

      await _verifySaved(tester, {
        MemoplannerSettings.forenoonIntervalStartKey:
            11 * Duration.millisecondsPerHour,
      });
    });

    testWidgets('max everything disables all increase buttons', (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepRight(DayPart.morning, times: 4);
      await tester.stepRight(DayPart.forenoon, times: 7);
      await tester.stepRight(DayPart.evening, times: 2);
      await tester.stepRight(DayPart.night);

      final morningRight = tester.widget<ActionButtonDark>(
          find.byKey(IntervalStepper.rightStepKey(DayPart.morning)));
      final dayRight = tester.widget<ActionButtonDark>(
          find.byKey(IntervalStepper.rightStepKey(DayPart.forenoon)));
      final eveningRight = tester.widget<ActionButtonDark>(
          find.byKey(IntervalStepper.rightStepKey(DayPart.evening)));
      final nightRight = tester.widget<ActionButtonDark>(
          find.byKey(IntervalStepper.rightStepKey(DayPart.night)));

      expect(morningRight.onPressed, isNull);
      expect(dayRight.onPressed, isNull);
      expect(eveningRight.onPressed, isNull);
      expect(nightRight.onPressed, isNull);

      await _verifySaved(tester, {
        MemoplannerSettings.morningIntervalStartKey:
            10 * Duration.millisecondsPerHour,
        MemoplannerSettings.forenoonIntervalStartKey:
            18 * Duration.millisecondsPerHour,
        MemoplannerSettings.eveningIntervalStartKey:
            21 * Duration.millisecondsPerHour,
        MemoplannerSettings.nightIntervalStartKey:
            24 * Duration.millisecondsPerHour,
      });
    });

    testWidgets('min everything disables all decrease buttons', (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepLeft(DayPart.morning);
      await tester.stepLeft(DayPart.forenoon, times: 2);
      await tester.stepLeft(DayPart.evening, times: 2);
      await tester.stepLeft(DayPart.night, times: 4);

      final morningRight = tester.widget<ActionButtonDark>(
          find.byKey(IntervalStepper.leftStepKey(DayPart.morning)));
      final dayRight = tester.widget<ActionButtonDark>(
          find.byKey(IntervalStepper.leftStepKey(DayPart.forenoon)));
      final eveningRight = tester.widget<ActionButtonDark>(
          find.byKey(IntervalStepper.leftStepKey(DayPart.evening)));
      final nightRight = tester.widget<ActionButtonDark>(
          find.byKey(IntervalStepper.leftStepKey(DayPart.night)));

      expect(morningRight.onPressed, isNull);
      expect(dayRight.onPressed, isNull);
      expect(eveningRight.onPressed, isNull);
      expect(nightRight.onPressed, isNull);

      await _verifySaved(tester, {
        MemoplannerSettings.morningIntervalStartKey:
            5 * Duration.millisecondsPerHour,
        MemoplannerSettings.forenoonIntervalStartKey:
            8 * Duration.millisecondsPerHour,
        MemoplannerSettings.eveningIntervalStartKey:
            16 * Duration.millisecondsPerHour,
        MemoplannerSettings.nightIntervalStartKey:
            19 * Duration.millisecondsPerHour,
      });
    });

    testWidgets('max day and evening, then min night', (tester) async {
      await tester.goToGeneralCalendarSettingsPageIntervalTab();

      await tester.stepRight(DayPart.forenoon, times: 8);
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
  });

  group('time interval visisbility settings', () {
    testWidgets('Change time interval', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: 10 * Duration.millisecondsPerHour,
            identifier: MemoplannerSettings.morningIntervalStartKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: 12 * Duration.millisecondsPerHour,
            identifier: MemoplannerSettings.forenoonIntervalStartKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: 19 * Duration.millisecondsPerHour,
            identifier: MemoplannerSettings.nightIntervalStartKey,
          ),
        ),
      ];
      // Act
      await tester.goToTimePillarCalendar(use24: true);
      // Assert
      expect(find.text('09'), findsNothing);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
      expect(find.text('20'), findsNothing);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp({bool use24 = false}) async {
    binding.window.alwaysUse24HourFormatTestValue = use24;
    await pumpWidget(App());
    await pumpAndSettle();
  }

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
    await tap(find.byIcon(AbiliaIcons.day_interval));
    await pumpAndSettle();
  }

  Future<void> goToTimePillarCalendar({bool use24 = false}) async {
    await pumpApp(use24: use24);
    await tap(find.byType(EyeButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.timeline));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.ok));
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