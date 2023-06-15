import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:repository_base/models/data_models.dart';
import 'package:seagull_clock/ticker.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/app_pumper.dart';

void main() {
  late MockSortableDb mockSortableDb;
  late SessionsDb mockSessionsDb;
  setUp(() async {
    await Lokalise.initMock();
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleNotificationsIsolated = noAlarmScheduler;
    mockSortableDb = MockSortableDb();
    mockSessionsDb = MockSessionsDb();

    when(() => mockSessionsDb.setHasMP4Session(any()))
        .thenAnswer((_) => Future.value());
    when(() => mockSessionsDb.hasMP4Session).thenReturn(true);

    final myPhotosFolder = Sortable.createNew(
      data: const ImageArchiveData(myPhotos: true),
      fixed: true,
    );
    when(() => mockSortableDb.getAllNonDeleted()).thenAnswer(
      (invocation) => Future.value(
        <Sortable<ImageArchiveData>>[
          myPhotosFolder,
          Sortable.createNew(
            data: const ImageArchiveData(upload: true),
            fixed: true,
          ),
          Sortable.createNew(
            groupId: myPhotosFolder.id,
            data: const ImageArchiveData(
              name: 'image',
              fileId: 'fileId',
            ),
          ),
          Sortable.createNew(
            groupId: myPhotosFolder.id,
            data: ImageArchiveData(
              name: 'image in photo-calendar',
              fileId: 'fileId',
              tags: UnmodifiableSetView({ImageArchiveData.photoCalendarTag}),
            ),
          ),
          Sortable.createNew(
            groupId: myPhotosFolder.id,
            isGroup: true,
            data: const ImageArchiveData(name: 'folder'),
          ),
        ],
      ),
    );
    when(() => mockSortableDb.insertAndAddDirty(any()))
        .thenAnswer((_) => Future.value(true));

    when(() => mockSortableDb.getAllDirty())
        .thenAnswer((_) => Future.value(<DbModel<Sortable>>[]));

    GetItInitializer()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..ticker = Ticker.fake(
        initialTime: DateTime(2021, 04, 17, 09, 20),
      )
      ..client = fakeClient()
      ..database = FakeDatabase()
      ..genericDb = FakeGenericDb()
      ..sortableDb = mockSortableDb
      ..battery = FakeBattery()
      ..deviceDb = FakeDeviceDb()
      ..sessionsDb = mockSessionsDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('Mp go my photos', () {
    testWidgets('Pressing + sign on MPGo shows SelectPicturePage',
        (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotosMpGo();
        await tester.tap(find.byIcon(AbiliaIcons.plus));
        await tester.pumpAndSettle();
        expect(find.byType(ImportPicturePage), findsOneWidget);
        expect(find.byType(ImageSourceWidget), findsNWidgets(2));
        expect(find.byType(PickField), findsNWidgets(2));
      });
    }, skip: Config.isMP);
  });

  group('My photos page', () {
    testWidgets('The page shows', (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotos();
        expect(find.byType(MyPhotosPage), findsOneWidget);
        expect(find.byType(LibraryFolder), findsOneWidget);
        expect(find.byType(ThumbnailPhoto), findsNWidgets(2));
      });
    });

    testWidgets('Can navigate back to menu', (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotos();
        expect(find.byType(MyPhotosPage), findsOneWidget);
        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        expect(
            find.byType(Config.isMP ? MenuPage : MpGoMenuPage), findsOneWidget);
      });
    });

    testWidgets('Can switch between all photos and photo-calendar tabs',
        (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotos();
        expect(find.byKey(TestKey.allPhotosTabButton), findsOneWidget);
        expect(find.byKey(TestKey.photoCalendarTabButton), findsOneWidget);
        expect(find.byKey(TestKey.allPhotosTab), findsOneWidget);
        expect(find.byKey(TestKey.photoCalendarTab), findsNothing);
        expect(find.byType(ThumbnailPhoto), findsNWidgets(2));

        await tester.tap(find.byKey(TestKey.photoCalendarTabButton));
        await tester.pumpAndSettle();
        expect(find.byKey(TestKey.allPhotosTab), findsNothing);
        expect(find.byKey(TestKey.photoCalendarTab), findsOneWidget);
        expect(find.byType(ThumbnailPhoto), findsOneWidget);
      });
    });

    testWidgets('Photo-calendar tagged photos have sticker', (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotos();
        expect(find.byKey(TestKey.allPhotosTab), findsOneWidget);
        expect(find.byKey(TestKey.photoCalendarTab), findsNothing);
        expect(find.byType(ThumbnailPhoto), findsNWidgets(2));
        expect(find.byType(PhotoCalendarSticker), findsOneWidget);

        await tester.tap(find.byKey(TestKey.photoCalendarTabButton));
        await tester.pumpAndSettle();
        expect(find.byKey(TestKey.allPhotosTab), findsNothing);
        expect(find.byKey(TestKey.photoCalendarTab), findsOneWidget);
        expect(find.byType(ThumbnailPhoto), findsOneWidget);
        expect(find.byType(PhotoCalendarSticker), findsOneWidget);
      });
    });

    testWidgets('SGC-2424 - No search bar or search button shows',
        (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotos();

        expect(find.byIcon(AbiliaIcons.find), findsNothing);
        expect(find.byType(TextField), findsNothing);

        await tester.tap(find.byType(LibraryFolder));
        await tester.pumpAndSettle();

        expect(find.byIcon(AbiliaIcons.find), findsNothing);
        expect(find.byType(TextField), findsNothing);
      });
    });

    testWidgets('Photo can be deleted', (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotos();
        expect(find.byType(ThumbnailPhoto), findsNWidgets(2));

        await tester.tap(find.byType(ThumbnailPhoto).first);
        await tester.pumpAndSettle();
        expect(find.byType(PhotoPage), findsOneWidget);

        await tester.tap(find.byIcon(AbiliaIcons.deleteAllClear));
        await tester.pumpAndSettle();
        expect(find.byType(ViewDialog), findsOneWidget);

        await tester.tap(find.byType(YesButton));
        await tester.pumpAndSettle();
        expect(find.byType(PhotoPage), findsNothing);
        expect(find.byType(MyPhotosPage), findsOneWidget);

        final capturedSortable =
            verify(() => mockSortableDb.insertAndAddDirty(captureAny()))
                .captured;

        expect(
          ((capturedSortable.single as List).single as Sortable<SortableData>)
              .deleted,
          isTrue,
        );
      });
    });

    testWidgets('Delete button not visible when photo added to photo calendar',
        (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotos();
        await tester.tap(find.byType(PhotoCalendarSticker));
        await tester.pumpAndSettle();

        expect(find.byType(PhotoPage), findsOneWidget);
        expect(find.byIcon(AbiliaIcons.deleteAllClear), findsNothing);
      });
    });
  });
}

extension on WidgetTester {
  Future<void> goToMyPhotos() async {
    if (Config.isMPGO) return goToMyPhotosMpGo();
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.myPhotos));
    await pumpAndSettle();
  }

  Future<void> goToMyPhotosMpGo() async {
    await pumpApp();
    await tap(find.byType(MpGoMenuButton));
    await pumpAndSettle();
    await tap(find.byType(MyPhotosPickField));
    await pumpAndSettle();
  }
}
