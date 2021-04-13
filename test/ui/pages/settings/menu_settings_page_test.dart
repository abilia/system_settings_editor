import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';

void main() {
  final initialTime = DateTime(2021, 04, 13, 10, 04);
  Iterable<Generic> generics = [];
  GenericDb genericDb;

  setUp(() async {
    setupPermissions();
    tz.initializeTimeZones();
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

  group('menu settings page', () {
    testWidgets('Menu settings shows', (tester) async {
      await tester.goToMenuSettingPage();
      expect(find.byType(MenuSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.camera_photo), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.my_photos), findsWidgets);
      expect(find.byIcon(AbiliaIcons.day), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.stop_watch), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.menu_setup), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.settings), findsOneWidget);
    });
    Future _verifySaved(
      WidgetTester tester, {
      String key,
      dynamic matcher,
      bool yesOnDialog = false,
    }) async {
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      if (yesOnDialog) {
        await tester.tap(find.byKey(TestKey.yesButton));
        await tester.pumpAndSettle();
      }

      final v = verify(genericDb.insertAndAddDirty(captureAny));
      expect(v.callCount, 1);
      final l = v.captured.single.toList() as List<Generic<GenericData>>;
      final d =
          l.map((e) => e.data).firstWhere((data) => data.identifier == key)
              as MemoplannerSettingData;
      expect(d.data, matcher);
    }

    testWidgets('change display camera is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.camera_photo));
      await _verifySaved(
        tester,
        key: MemoplannerSettings.settingsMenuShowCameraKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display my photos is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.my_photos));
      await _verifySaved(
        tester,
        key: MemoplannerSettings.settingsMenuShowPhotosKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display photo calendar is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.day));
      await _verifySaved(
        tester,
        key: MemoplannerSettings.settingsMenuShowPhotoCalendarKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display countdown is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.stop_watch));
      await _verifySaved(
        tester,
        key: MemoplannerSettings.settingsMenuShowTimersKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display quick settings is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.menu_setup));
      await _verifySaved(
        tester,
        key: MemoplannerSettings.settingsMenuShowQuickSettingsKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display settings to shows popup and is stored',
        (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.settings));
      await _verifySaved(
        tester,
        key: MemoplannerSettings.settingsMenuShowSettingsKey,
        matcher: isFalse,
        yesOnDialog: true,
      );
    });

    testWidgets('change display settings to trye shows no popup and is stored',
        (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowSettingsKey,
          ),
        ),
      ];
      // Act
      await tester.pumpApp();
      expect(find.byType(HiddenSetting), findsOneWidget);
      // Act
      await tester.tap(find.byKey(TestKey.hiddenSettingsButtonLeft));
      await tester.tap(find.byKey(TestKey.hiddenSettingsButtonRight));
      await tester.tap(find.byKey(TestKey.hiddenSettingsButtonLeft));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.app_menu));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.settings));
      await tester.pumpAndSettle();
      await _verifySaved(
        tester,
        key: MemoplannerSettings.settingsMenuShowSettingsKey,
        matcher: isTrue,
      );
    });
  });

  group('menu visisbility settings', () {
    testWidgets('all menu items shows', (tester) async {
      await tester.goToMenuPage();
      expect(find.byType(MenuItemButton), findsNWidgets(6));
      expect(find.byType(CameraButton), findsOneWidget);
      expect(find.byType(MyPhotosButton), findsOneWidget);
      expect(find.byType(PhotoCalendarButton), findsOneWidget);
      expect(find.byType(CountdownButton), findsOneWidget);
      expect(find.byType(QuickSettingsButton), findsOneWidget);
      expect(find.byType(SettingsButton), findsOneWidget);
    });

    testWidgets('hides CameraButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowCameraKey,
          ),
        ),
      ];
      await tester.goToMenuPage();
      expect(find.byType(CameraButton), findsNothing);
    });
    testWidgets('hides MyPhotosButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowPhotosKey,
          ),
        ),
      ];
      await tester.goToMenuPage();
      expect(find.byType(MyPhotosButton), findsNothing);
    });

    testWidgets('hides PhotoCalendarButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowPhotoCalendarKey,
          ),
        ),
      ];
      await tester.goToMenuPage();
      expect(find.byType(PhotoCalendarButton), findsNothing);
    });

    testWidgets('hides CountdownButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowTimersKey,
          ),
        ),
      ];
      await tester.goToMenuPage();
      expect(find.byType(CountdownButton), findsNothing);
    });

    testWidgets('hides QuickSettingsButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowQuickSettingsKey,
          ),
        ),
      ];
      await tester.goToMenuPage();
      expect(find.byType(QuickSettingsButton), findsNothing);
    });

    testWidgets('hides SettingsButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowSettingsKey,
          ),
        ),
      ];
      await tester.goToMenuPage();
      expect(find.byType(SettingsButton), findsNothing);
    });

    testWidgets('hides SettingsButton shows hidden settings buttons',
        (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowSettingsKey,
          ),
        ),
      ];
      await tester.pumpApp();
      expect(find.byType(HiddenSetting), findsOneWidget);
      expect(find.byType(MenuButton), findsOneWidget);
    });

    testWidgets('all menu items disable hiddes menu button', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowCameraKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowPhotosKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowPhotoCalendarKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowTimersKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowQuickSettingsKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.settingsMenuShowSettingsKey,
          ),
        ),
      ];
      await tester.pumpApp();
      expect(find.byType(HiddenSetting), findsOneWidget);
      expect(find.byType(MenuButton), findsNothing);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToMenuPage() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
  }

  Future<void> goToMenuSettingPage() async {
    await goToMenuPage();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.app_menu));
    await pumpAndSettle();
  }
}
