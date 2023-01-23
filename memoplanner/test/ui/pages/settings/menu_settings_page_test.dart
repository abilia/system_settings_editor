import 'package:flutter_test/flutter_test.dart';

import 'package:timezone/data/latest.dart' as tz;

import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/verify_generic.dart';

void main() {
  final initialTime = DateTime(2021, 04, 13, 10, 04);
  Iterable<Generic> generics = [];
  late MockGenericDb genericDb;

  setUp(() async {
    setupPermissions();
    tz.initializeTimeZones();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;
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
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('menu settings page', () {
    testWidgets('Menu settings shows', (tester) async {
      await tester.goToMenuSettingPage();
      expect(find.byType(MenuSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.cameraPhoto), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.myPhotos), findsWidgets);
      expect(find.byIcon(AbiliaIcons.photoCalendar), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.favoritesShow), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.menuSetup), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.settings), findsOneWidget);
    });

    testWidgets('change display camera is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.cameraPhoto));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MenuSettings.showCameraKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display my photos is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.myPhotos));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MenuSettings.showPhotosKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display photo calendar is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.photoCalendar));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MenuSettings.showPhotoCalendarKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display basic templates is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.favoritesShow));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MenuSettings.showTemplatesKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display quick settings is stored', (tester) async {
      await tester.goToMenuSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.menuSetup));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MenuSettings.showQuickSettingsKey,
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
        key: MenuSettings.showSettingsKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display settings shows no popup and is stored',
        (tester) async {
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MenuSettings.showSettingsKey,
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
      await tester.tap(find.byIcon(AbiliaIcons.appMenu));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(AbiliaIcons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MenuSettings.showSettingsKey,
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
      expect(find.byType(QuickSettingsButton), findsOneWidget);
      expect(find.byType(SettingsButton), findsOneWidget);
    });

    testWidgets('CalendarBottomBar is visible', (tester) async {
      await tester.goToMenuPage();
      expect(find.byType(CalendarBottomBar), findsOneWidget);
    });

    testWidgets('hides CameraButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MenuSettings.showCameraKey,
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
            identifier: MenuSettings.showPhotosKey,
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
            identifier: MenuSettings.showPhotoCalendarKey,
          ),
        ),
      ];
      await tester.goToMenuPage();
      expect(find.byType(PhotoCalendarButton), findsNothing);
    });

    testWidgets('hides BasicTemplatesButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MenuSettings.showTemplatesKey,
          ),
        ),
      ];
      await tester.goToMenuPage();
      expect(find.byType(BasicTemplatesButton), findsNothing);
    });

    testWidgets('hides QuickSettingsButton', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MenuSettings.showQuickSettingsKey,
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
            identifier: MenuSettings.showSettingsKey,
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
            identifier: MenuSettings.showSettingsKey,
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
          identifier: MenuSettings.showCameraKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: MenuSettings.showPhotosKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: MenuSettings.showPhotoCalendarKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: MenuSettings.showTemplatesKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: MenuSettings.showQuickSettingsKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: MenuSettings.showSettingsKey,
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
    await tap(find.byIcon(AbiliaIcons.appMenu));
    await pumpAndSettle();
  }
}
