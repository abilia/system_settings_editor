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

import '../../../mocks/shared.dart';
import '../../../mocks/shared.mocks.dart';
import '../../../test_helpers/app_pumper.dart';
import '../../../test_helpers/alarm_schedualer.dart';
import '../../../test_helpers/fake_shared_preferences.dart';
import '../../../test_helpers/permission.dart';
import '../../../test_helpers/verify_generic.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Generic> generics = [];
  late MockGenericDb genericDb;

  setUp(() async {
    setupPermissions();
    tz.initializeTimeZones();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

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

  group('image picker settings page', () {
    testWidgets('shows', (tester) async {
      await tester.goToFunctionImagePickerSettingPage();
      expect(find.byType(ImagePickerSettingsPage), findsOneWidget);
      expect(find.byType(OkButton), findsOneWidget);
      expect(find.byType(CancelButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.folder), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.my_photos), findsWidgets);
      expect(find.byIcon(AbiliaIcons.camera_photo), findsOneWidget);
      expect(find.text(translate.imagePicker), findsOneWidget);
      expect(find.text(translate.imageArchive), findsOneWidget);
      expect(find.text(translate.myPhotos), findsOneWidget);
      expect(find.text(translate.takeNewPhoto), findsOneWidget);
    });

    testWidgets('change display camera is stored', (tester) async {
      await tester.goToFunctionImagePickerSettingPage();
      await tester.tap(find.byIcon(AbiliaIcons.camera_photo));
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.imageMenuDisplayCameraItemKey,
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
        key: MemoplannerSettings.imageMenuDisplayPhotoItemKey,
        matcher: isFalse,
      );
    });
  }, skip: !Config.isMP);

  group('select image visisbility settings', () {
    testWidgets('both camera and folder option shows', (tester) async {
      await tester.goToAddActivityImagePicker();
      expect(find.byIcon(AbiliaIcons.folder), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.upload), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.camera_photo), findsOneWidget);
    });

    testWidgets('hides camera image option', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.imageMenuDisplayCameraItemKey,
          ),
        ),
      ];
      await tester.goToAddActivityImagePicker();
      expect(find.byIcon(AbiliaIcons.camera_photo), findsNothing);
    });

    testWidgets('hides my photo image option', (tester) async {
      // Arrange
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: MemoplannerSettings.imageMenuDisplayPhotoItemKey,
          ),
        ),
      ];
      await tester.goToAddActivityImagePicker();
      expect(find.byIcon(AbiliaIcons.my_photos), findsNothing);
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
    await tap(find.byIcon(AbiliaIcons.my_photos));
    await pumpAndSettle();
  }

  Future<void> goToAddActivityImagePicker() async {
    await pumpApp();
    await tap(find.byType(AddActivityButton));
    await pumpAndSettle();
    await tap(find.byType(NextButton));
    await pumpAndSettle();
    await tap(find.byType(SelectPictureWidget));
    await pumpAndSettle();
  }
}
