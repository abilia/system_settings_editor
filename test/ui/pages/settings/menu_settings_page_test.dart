import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/shared.mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/verify_generic.dart';

void main() {
  final initialTime = DateTime(2021, 04, 13, 10, 04);
  Iterable<Generic> generics = [];
  late MockGenericDb genericDb;

  setUp(() async {
    setupPermissions();
    tz.initializeTimeZones();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;
    generics = [];

    genericDb = MockGenericDb();
    when(genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(genericDb.insertAndAddDirty(any))
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

    testWidgets('change display camera is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.camera_photo));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingsMenuShowCameraKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display my photos is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.my_photos));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingsMenuShowPhotosKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display photo calendar is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.day));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingsMenuShowPhotoCalendarKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display countdown is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.stop_watch));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingsMenuShowTimersKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display quick settings is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.menu_setup));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingsMenuShowQuickSettingsKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display settings to shows popup and is stored',
        (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.settings));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(YesButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingsMenuShowSettingsKey,
        matcher: isFalse,
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
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.settingsMenuShowSettingsKey,
        matcher: isTrue,
      );
    });
  }, skip: !Config.isMP);

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
  }, skip: !Config.isMP);

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
}

extension on WidgetTester {
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
