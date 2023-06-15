import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:seagull_clock/ticker.dart';

import 'package:timezone/data/latest.dart' as tz;

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  late final Lt translate;
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Generic> generics = [];
  late MockGenericDb genericDb;

  setUpAll(() async {
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);
  });

  setUp(() async {
    setupPermissions();
    tz.initializeTimeZones();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;

    genericDb = MockGenericDb();
    when(() => genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => genericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker.fake(initialTime: initialTime)
      ..client = fakeClient(genericResponse: () => generics)
      ..database = FakeDatabase()
      ..sortableDb = FakeSortableDb()
      ..genericDb = genericDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..init();
  });

  tearDown(() {
    GetIt.I.reset();
    generics = [];
  });

  group('image picker settings page', () {
    testWidgets('shows', (tester) async {
      await tester.goToFunctionImagePickerSettingPage();
      expect(find.byType(ImagePickerSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.folder), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.myPhotos), findsWidgets);
      expect(find.byIcon(AbiliaIcons.cameraPhoto), findsOneWidget);
      expect(find.text(translate.imagePicker), findsOneWidget);
      expect(find.text(translate.imageArchive), findsOneWidget);
      expect(find.text(translate.myPhotos), findsOneWidget);
      expect(find.text(translate.takeNewPhoto), findsOneWidget);
    });

    testWidgets('change display camera is stored', (tester) async {
      await tester.goToFunctionImagePickerSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.cameraPhoto));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: PhotoMenuSettings.displayCameraKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display my photo is stored', (tester) async {
      await tester.goToFunctionImagePickerSettingPage();
      await tester.tap(find.text(translate.myPhotos));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: PhotoMenuSettings.displayMyPhotosKey,
        matcher: isFalse,
      );
    });

    testWidgets('change display local images is stored', (tester) async {
      await tester.goToFunctionImagePickerSettingPage();
      await tester.tap(find.text(translate.devicesLocalImages));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: PhotoMenuSettings.displayPhotoKey,
        matcher: isFalse,
      );
    });
  }, skip: !Config.isMP);

  group('select image visisbility settings', () {
    testWidgets('both camera, folder and myphotos option shows',
        (tester) async {
      await tester.goToAddActivityImagePicker();
      expect(find.byIcon(AbiliaIcons.folder), findsNWidgets(2));
      if (Config.isMPGO) {
        expect(find.byIcon(AbiliaIcons.upload), findsOneWidget);
      }
      expect(find.byIcon(AbiliaIcons.cameraPhoto), findsOneWidget);
    });

    testWidgets('hides camera image option', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: PhotoMenuSettings.displayCameraKey,
          ),
        ),
      ];
      await tester.goToAddActivityImagePicker();
      expect(find.byIcon(AbiliaIcons.cameraPhoto), findsNothing);
    });

    testWidgets('hides my photo image option', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<GenericSettingData>(
          data: GenericSettingData.fromData(
            data: false,
            identifier: PhotoMenuSettings.displayPhotoKey,
          ),
        ),
      ];
      await tester.goToAddActivityImagePicker();
      expect(find.byIcon(AbiliaIcons.myPhotos), findsNothing);
    });
  });
}

extension on WidgetTester {
  Future<void> goToFunctionImagePickerSettingPage() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(SettingsButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.myPhotos));
    await pumpAndSettle();
  }

  Future<void> goToAddActivityImagePicker() async {
    await pumpApp();
    await tap(find.byKey(TestKey.addActivityButton));
    await pumpAndSettle();
    await tap(find.byKey(TestKey.newActivityChoice));
    await pumpAndSettle();
    await tap(find.byType(SelectPictureWidget));
    await pumpAndSettle();
  }
}
