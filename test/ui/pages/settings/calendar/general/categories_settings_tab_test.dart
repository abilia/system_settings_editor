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
import '../../../../../utils/verify_generic.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 04, 26, 13, 37);

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
    await tester.goToGeneralCalendarSettingsPageCategoriesTab();
    expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.clock), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.day_interval), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.change_page_color), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.calendar_list), findsOneWidget);
    expect(find.byType(ClockSettingsTab), findsNothing);
    expect(find.byType(IntervalsSettingsTab), findsNothing);
    expect(find.byType(DayColorsSettingsTab), findsNothing);
    expect(find.byType(CategoriesSettingsTab), findsOneWidget);
    expect(find.byType(CategoryRight), findsOneWidget);
    expect(find.byType(CategoryLeft), findsOneWidget);
    expect(find.text(translate.left), findsNWidgets(2));
    expect(find.text(translate.right), findsNWidgets(2));

    expect(find.byType(OkButton), findsOneWidget);
    expect(find.byType(CancelButton), findsOneWidget);
  });

  group('settings saved', () {
    testWidgets('show color choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPageCategoriesTab();

      await tester.dragUntilVisible(
        find.text(translate.showColours),
        find.byType(CategoriesSettingsTab),
        Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(translate.showColours));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.calendarActivityTypeShowColorKey,
        matcher: false,
      );
    });

    testWidgets('show categories choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPageCategoriesTab();

      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);
      expect(find.text(translate.left), findsNWidgets(2));
      expect(find.text(translate.right), findsNWidgets(2));

      await tester.tap(find.text(translate.showCagetories));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryRight), findsNothing);
      expect(find.byType(CategoryLeft), findsNothing);
      expect(find.text(translate.left), findsNothing);
      expect(find.text(translate.right), findsNothing);

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.calendarActivityTypeShowTypesKey,
        matcher: false,
      );
    });

    testWidgets('edit left category saved', (tester) async {
      final newLeftName = 'new lft name';
      await tester.goToGeneralCalendarSettingsPageCategoriesTab();
      expect(find.text(translate.left), findsNWidgets(2));

      await tester.tap(find.byKey(TestKey.editLeftCategory));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), newLeftName);
      await tester.pumpAndSettle();
      expect(find.text(newLeftName), findsWidgets);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.text(translate.left), findsNothing);
      expect(find.text(newLeftName), findsNWidgets(2));

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.calendarActivityTypeLeftKey,
        matcher: newLeftName,
      );
    });

    testWidgets('edit right category saved', (tester) async {
      final newRightName = 'new rght name';
      await tester.goToGeneralCalendarSettingsPageCategoriesTab();
      expect(find.text(translate.right), findsNWidgets(2));

      await tester.tap(find.byKey(TestKey.editRigthCategory));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), newRightName);
      await tester.pumpAndSettle();
      expect(find.text(newRightName), findsWidgets);
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      expect(find.text(translate.right), findsNothing);
      expect(find.text(newRightName), findsNWidgets(2));

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await verifyGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.calendarActivityTypeRightKey,
        matcher: newRightName,
      );
    });
  });

  group('category visisbility settings', () {
    testWidgets('show category false', (tester) async {
      // Arrange
      generics = [
        timepillarGeneric,
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.calendarActivityTypeShowTypesKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp(use24: true);
      // Assert
      expect(find.byType(CategoryRight), findsNothing);
      expect(find.byType(CategoryLeft), findsNothing);
    });

    testWidgets('show category true', (tester) async {
      // Arrange
      generics = [
        timepillarGeneric,
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: true,
            identifier: MemoplannerSettings.calendarActivityTypeShowTypesKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp(use24: true);
      // Assert
      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);
    });

    testWidgets('category right name, agenda view', (tester) async {
      // Arrange
      final right = 'some right name';
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: right,
            identifier: MemoplannerSettings.calendarActivityTypeRightKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp(use24: true);
      // Assert
      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);
      expect(find.text(right), findsOneWidget);
      expect(find.text(translate.left), findsOneWidget);
    });

    testWidgets('category right name, timepillar view', (tester) async {
      // Arrange
      final right = 'some right name';
      generics = [
        timepillarGeneric,
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: right,
            identifier: MemoplannerSettings.calendarActivityTypeRightKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp(use24: true);
      // Assert
      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);
      expect(find.text(right), findsOneWidget);
      expect(find.text(translate.left), findsOneWidget);
    });

    testWidgets('category left name, agenda view', (tester) async {
      // Arrange
      final left = 'some left name';
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: left,
            identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp(use24: true);
      // Assert
      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);
      expect(find.text(left), findsOneWidget);
      expect(find.text(translate.right), findsOneWidget);
    });

    testWidgets('category left name, timepillar view', (tester) async {
      // Arrange
      final left = 'some left name';
      generics = [
        timepillarGeneric,
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: left,
            identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp(use24: true);
      // Assert
      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);
      expect(find.text(left), findsOneWidget);
      expect(find.text(translate.right), findsOneWidget);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp({bool use24 = false}) async {
    binding.window.alwaysUse24HourFormatTestValue = use24;
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToGeneralCalendarSettingsPageCategoriesTab(
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
    await tap(find.byIcon(AbiliaIcons.calendar_list));
    await pumpAndSettle();
  }
}