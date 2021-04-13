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
  final initialTime = DateTime(2021, 04, 13, 15, 36);
  final translate = Locales.language.values.first;

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

  group('calendar general settings', () {
    testWidgets('shows', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);
      expect(find.byType(ClockSettingsTab), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
    });
  });

  Future _verifySaved(
    WidgetTester tester, {
    String key,
    dynamic matcher,
  }) async {
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();

    final v = verify(genericDb.insertAndAddDirty(captureAny));
    expect(v.callCount, 1);
    final l = v.captured.single.toList() as List<Generic<GenericData>>;
    final d = l
        .whereType<Generic<MemoplannerSettingData>>()
        .firstWhere((element) => element.data.identifier == key);
    expect(d.data.data, matcher);
  }

  group('clock settings type', () {
    testWidgets('digital clock choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPage();
      await tester.tap(find.text(translate.digital));
      await tester.pumpAndSettle();

      expect(find.byType(AnalogClock), findsNothing);
      expect(find.byType(DigitalClock), findsOneWidget);

      await _verifySaved(
        tester,
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
      await _verifySaved(
        tester,
        key: MemoplannerSettings.settingClockTypeKey,
        matcher: ClockType.analogue.index,
      );
    });

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
  });
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToGeneralCalendarSettingsPage() async {
    await pumpApp();
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
