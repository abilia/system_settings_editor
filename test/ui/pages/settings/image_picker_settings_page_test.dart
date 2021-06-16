// @dart=2.9

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
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Generic> generics = [];
  GenericDb genericDb;

  setUp(() async {
    setupPermissions();
    tz.initializeTimeZones();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

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
