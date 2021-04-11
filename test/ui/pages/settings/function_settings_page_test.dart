import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';

void main() {
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Generic> generics = [];

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    final mockBatch = MockBatch();
    when(mockBatch.commit()).thenAnswer((realInvocation) => Future.value([]));
    final db = MockDatabase();
    when(db.batch()).thenReturn(mockBatch);
    when(db.rawQuery(any)).thenAnswer((realInvocation) => Future.value([]));

    final genericDb = MockGenericDb();
    when(genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: initialTime,
      )
      ..client = Fakes.client(genericResponse: () => generics)
      ..alarmScheduler = noAlarmScheduler
      ..database = db
      ..genericDb = genericDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  testWidgets('shows settings page', (tester) async {
    await tester.goToFunctionSettingsPage(pump: true);
    expect(find.byType(FunctionSettingsPage), findsOneWidget);
    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  });

  group('BottomBar visisbility settings', () {
    testWidgets('Default settings shows all buttons in bottomBar',
        (tester) async {
      // Act
      await tester.pumpApp();

      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AddActivityButton), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.week), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsOneWidget);
      expect(find.byType(MenuButton), findsOneWidget);
    });

    testWidgets('hides AddActivity Button in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.functionMenuDisplayNewActivityKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AddActivityButton), findsNothing);
    });

    testWidgets('hides Menu Button in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.functionMenuDisplayMenuKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(MenuButton), findsNothing);
    });

    testWidgets('hides Week calendar in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.functionMenuDisplayWeekKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.week), findsNothing);
    });

    testWidgets('hides Month calendar in bottomBar', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.functionMenuDisplayMonthKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.month), findsNothing);
    });

    testWidgets('hide Month and week calendar in bottomBar', (tester) async {
      // Arrange
      generics = [
        MemoplannerSettings.functionMenuDisplayMonthKey,
        MemoplannerSettings.functionMenuDisplayWeekKey,
      ].map(
        (id) => Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(data: false, identifier: id),
        ),
      );
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsOneWidget);
      expect(find.byType(AbiliaTabBar), findsNothing);
      expect(find.byIcon(AbiliaIcons.month), findsNothing);
      expect(find.byIcon(AbiliaIcons.week), findsNothing);
    });

    testWidgets('hides bottomBar', (tester) async {
      // Arrange
      generics = [
        MemoplannerSettings.functionMenuDisplayMonthKey,
        MemoplannerSettings.functionMenuDisplayWeekKey,
        MemoplannerSettings.functionMenuDisplayNewActivityKey,
        MemoplannerSettings.functionMenuDisplayMenuKey,
      ].map(
        (id) => Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(data: false, identifier: id),
        ),
      );
      // Act
      await tester.pumpApp();
      // Assert
      expect(find.byType(CalendarBottomBar), findsNothing);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToFunctionSettingsPage({bool pump = false}) async {
    if (pump) await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.menu_setup));
    await pumpAndSettle();
  }
}
