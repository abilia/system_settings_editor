import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:mocktail_image_network/mocktail_image_network.dart';

import 'package:seagull/background/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../../fakes/all.dart';
import '../../../../../mocks/mocks.dart';
import '../../../../../test_helpers/app_pumper.dart';
import '../../../../../test_helpers/register_fallback_values.dart';
import '../../../../../test_helpers/verify_generic.dart';

void main() {
  final translate = Locales.language.values.first;
  final initialTime = DateTime(2021, 04, 26, 13, 37);

  Iterable<Generic> generics = [];
  Iterable<Sortable> sortable = [];
  late MockGenericDb genericDb;
  late MockSortableDb sortableDb;

  final oneTimepillarGeneric = Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
            data: DayCalendarType.oneTimepillar.index,
            identifier: MemoplannerSettings.viewOptionsTimeViewKey),
      ),
      twoTimepillarsGeneric = Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
            data: DayCalendarType.twoTimepillars.index,
            identifier: MemoplannerSettings.viewOptionsTimeViewKey),
      );
  setUp(() async {
    tz.initializeTimeZones();
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;

    genericDb = MockGenericDb();
    when(() => genericDb.getAllNonDeletedMaxRevision())
        .thenAnswer((_) => Future.value(generics));
    when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => genericDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    sortableDb = MockSortableDb();
    when(() => sortableDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(sortable));
    when(() => sortableDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => sortableDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker.fake(initialTime: initialTime)
      ..client = Fakes.client(
        genericResponse: () => generics,
        sortableResponse: () => sortable,
      )
      ..database = FakeDatabase()
      ..genericDb = genericDb
      ..sortableDb = sortableDb
      ..battery = FakeBattery()
      ..init();
  });

  tearDown(() {
    generics = [];
    sortable = [];
    GetIt.I.reset();
  });

  testWidgets('shows', (tester) async {
    await tester.goToGeneralCalendarSettingsPageCategoriesTab();
    expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.clock), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.dayInterval), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.changePageColor), findsNWidgets(2));
    expect(find.byIcon(AbiliaIcons.calendarList), findsOneWidget);
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
  }, skip: !Config.isMP);

  testWidgets('settings shows', (tester) async {
    const fileIdLeft = 'fileIdLeft',
        fileIdRight = 'fileIdRight',
        leftName = 'leftName',
        rightName = 'leftName';
    generics = [
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: MemoplannerSettings.calendarActivityTypeShowTypesKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: leftName,
          identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: rightName,
          identifier: MemoplannerSettings.calendarActivityTypeRightKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: fileIdLeft,
          identifier: MemoplannerSettings.calendarActivityTypeLeftImageKey,
        ),
      ),
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: fileIdRight,
          identifier: MemoplannerSettings.calendarActivityTypeRightImageKey,
        ),
      ),
    ];

    await mockNetworkImages(() async {
      await tester.goToGeneralCalendarSettingsPageCategoriesTab();
      expect(find.byType(CalendarGeneralSettingsPage), findsOneWidget);

      expect(find.byType(CategoryRight), findsNothing);
      expect(find.byType(CategoryLeft), findsNothing);
      expect(find.byType(FadeInAbiliaImage), findsNothing);
      expect(find.text(leftName), findsNothing);
      expect(find.text(rightName), findsNothing);
      expect(find.text(translate.left), findsNothing);
      expect(find.text(translate.right), findsNothing);

      await tester.tap(find.text(translate.showCagetories));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryRight), findsOneWidget);
      expect(find.byType(CategoryLeft), findsOneWidget);
      expect(find.byType(FadeInAbiliaImage), findsNWidgets(4));
      expect(find.text(leftName), findsNWidgets(4));
      expect(find.text(rightName), findsNWidgets(4));
      expect(find.text(translate.left), findsNothing);
      expect(find.text(translate.right), findsNothing);
    });
  }, skip: !Config.isMP);

  group('settings saved', () {
    testWidgets('show color choice saved', (tester) async {
      await tester.goToGeneralCalendarSettingsPageCategoriesTab();

      await tester.dragUntilVisible(
        find.text(translate.showColours),
        find.byType(CategoriesSettingsTab),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(translate.showColours));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();
      verifySyncGeneric(
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
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.calendarActivityTypeShowTypesKey,
        matcher: false,
      );
    });

    testWidgets('edit left category saved', (tester) async {
      const newLeftName = 'new lft name';
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
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.calendarActivityTypeLeftKey,
        matcher: newLeftName,
      );
    });

    testWidgets('edit right category saved', (tester) async {
      const newRightName = 'new rght name';
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
      verifySyncGeneric(
        tester,
        genericDb,
        key: MemoplannerSettings.calendarActivityTypeRightKey,
        matcher: newRightName,
      );
    });

    group('edit image', () {
      testWidgets('right saved', (tester) async {
        await mockNetworkImages(() async {
          const fileId = 'imgfileId';
          sortable = [
            Sortable.createNew<ImageArchiveData>(
              data: const ImageArchiveData(name: 'test image', fileId: fileId),
            ),
            Sortable.createNew<ImageArchiveData>(
              isGroup: true,
              data: const ImageArchiveData(upload: true),
            ),
            Sortable.createNew<ImageArchiveData>(
              isGroup: true,
              data: const ImageArchiveData(myPhotos: true),
            ),
          ];
          await tester.goToGeneralCalendarSettingsPageCategoriesTab();
          await tester.tap(find.byKey(TestKey.editRigthCategory));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(SelectPictureWidget));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.imageArchiveButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ArchiveImage));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
          verifySyncGeneric(
            tester,
            genericDb,
            key: MemoplannerSettings.calendarActivityTypeRightImageKey,
            matcher: fileId,
          );
        });
      });

      testWidgets('left saved', (tester) async {
        await mockNetworkImages(() async {
          const fileId = 'imgfileIds';
          sortable = [
            Sortable.createNew<ImageArchiveData>(
              data: const ImageArchiveData(name: 'test image', fileId: fileId),
            ),
            Sortable.createNew<ImageArchiveData>(
              isGroup: true,
              data: const ImageArchiveData(upload: true),
            ),
            Sortable.createNew<ImageArchiveData>(
              isGroup: true,
              data: const ImageArchiveData(myPhotos: true),
            ),
          ];
          await tester.goToGeneralCalendarSettingsPageCategoriesTab();

          await tester.tap(find.byKey(TestKey.editLeftCategory));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(SelectPictureWidget));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.imageArchiveButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ArchiveImage));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(OkButton));
          await tester.pumpAndSettle();
          verifySyncGeneric(
            tester,
            genericDb,
            key: MemoplannerSettings.calendarActivityTypeLeftImageKey,
            matcher: fileId,
          );
        });
      });
    });
  }, skip: !Config.isMP);

  group('category visisbility settings', () {
    setUpAll(() {
      registerFallbackValues();
    });

    testWidgets('show category false', (tester) async {
      // Arrange
      generics = [
        oneTimepillarGeneric,
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

    testWidgets('show category false - two timepillar', (tester) async {
      // Arrange
      generics = [
        twoTimepillarsGeneric,
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
      expect(find.byType(TwoTimepillarCalendar), findsOneWidget);
      expect(find.byType(CategoryRight), findsNothing);
      expect(find.byType(CategoryLeft), findsNothing);
    });

    testWidgets('show category true', (tester) async {
      // Arrange
      generics = [
        oneTimepillarGeneric,
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
      const right = 'some right name';
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

    testWidgets('category right name, one timepillar view', (tester) async {
      // Arrange
      const right = 'some right name';
      generics = [
        oneTimepillarGeneric,
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
      const left = 'some left name';
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
      const left = 'some left name';
      generics = [
        oneTimepillarGeneric,
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

    testWidgets('category image, timepillar view', (tester) async {
      // Arrange
      const fileIdLeft = 'fileIdLeft', fileIdRight = 'fileIdRight';
      generics = [
        oneTimepillarGeneric,
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: fileIdLeft,
            identifier: MemoplannerSettings.calendarActivityTypeLeftImageKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: fileIdRight,
            identifier: MemoplannerSettings.calendarActivityTypeRightImageKey,
          ),
        ),
      ];

      await mockNetworkImages(
        () async {
          // Act
          await tester.pumpApp(use24: true);
          // Assert
          expect(find.byType(CategoryRight), findsOneWidget);
          expect(find.byType(CategoryLeft), findsOneWidget);
          expect(find.text(translate.left), findsOneWidget);
          expect(find.text(translate.right), findsOneWidget);
          expect(find.byType(CategoryImage), findsNWidgets(2));
        },
      );
    });

    testWidgets('category image and name, two timepillar view', (tester) async {
      // Arrange
      const fileIdLeft = 'fileIdLeft',
          fileIdRight = 'fileIdRight',
          leftName = 'some left name',
          rightName = 'some right name';
      generics = [
        twoTimepillarsGeneric,
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: fileIdLeft,
            identifier: MemoplannerSettings.calendarActivityTypeLeftImageKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: fileIdRight,
            identifier: MemoplannerSettings.calendarActivityTypeRightImageKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: leftName,
            identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: rightName,
            identifier: MemoplannerSettings.calendarActivityTypeRightKey,
          ),
        ),
      ];
      await mockNetworkImages(
        () async {
          // Act
          await tester.pumpApp(use24: true);
          // Assert
          expect(find.byType(CategoryRight), findsOneWidget);
          expect(find.byType(CategoryLeft), findsOneWidget);
          expect(find.text(translate.left), findsNothing);
          expect(find.text(translate.right), findsNothing);
          expect(find.text(leftName), findsOneWidget);
          expect(find.text(rightName), findsOneWidget);
          expect(find.byType(CategoryImage), findsNWidgets(2));
        },
      );
    });

    testWidgets('category image, agenda view', (tester) async {
      // Arrange
      const fileIdLeft = 'fileIdLeft', fileIdRight = 'fileIdRight';
      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: fileIdLeft,
            identifier: MemoplannerSettings.calendarActivityTypeLeftImageKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: fileIdRight,
            identifier: MemoplannerSettings.calendarActivityTypeRightImageKey,
          ),
        ),
      ];

      await mockNetworkImages(
        () async {
          // Act
          await tester.pumpApp(use24: true);
          // Assert
          expect(find.byType(CategoryRight), findsOneWidget);
          expect(find.byType(CategoryLeft), findsOneWidget);
          expect(find.text(translate.left), findsOneWidget);
          expect(find.text(translate.right), findsOneWidget);
          expect(find.byType(CategoryImage), findsNWidgets(2));
        },
      );
    });

    testWidgets('category image, name, edit activityt view', (tester) async {
      // Arrange
      const nameLeft = 'nameLeft',
          nameRight = 'nameRight',
          fileIdLeft = 'fileIdLeft',
          fileIdRight = 'fileIdRight';

      generics = [
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: nameLeft,
            identifier: MemoplannerSettings.calendarActivityTypeLeftKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: nameRight,
            identifier: MemoplannerSettings.calendarActivityTypeRightKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: fileIdLeft,
            identifier: MemoplannerSettings.calendarActivityTypeLeftImageKey,
          ),
        ),
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: fileIdRight,
            identifier: MemoplannerSettings.calendarActivityTypeRightImageKey,
          ),
        ),
      ];
      await mockNetworkImages(() async {
        // Act
        await tester.pumpApp();
        await tester.tap(find.byKey(
          Config.isMPGO ? TestKey.addButtonMPGO : TestKey.addActivityButton,
        ));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.newActivityChoice));
        await tester.pumpAndSettle();
        await tester.dragUntilVisible(
          find.byType(CategoryWidget),
          find.byType(EditActivityPage),
          const Offset(0, -100),
        );
        await tester.pumpAndSettle();

        // Assert
        expect(find.text(nameLeft), findsOneWidget);
        expect(find.text(nameRight), findsOneWidget);
        expect(find.byType(CategoryImage), findsNWidgets(2));
      });
    });
  });
}

extension on WidgetTester {
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
    await tap(find.byIcon(AbiliaIcons.calendarList));
    await pumpAndSettle();
  }
}
