import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:seagull/background/all.dart';

import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../../fakes/all.dart';
import '../../../../mocks/mocks.dart';
import '../../../../test_helpers/app_pumper.dart';

void main() {
  late MockSortableDb mockSortableDb;
  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;
    mockSortableDb = MockSortableDb();

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
      ..client = Fakes.client()
      ..database = FakeDatabase()
      ..genericDb = FakeGenericDb()
      ..sortableDb = mockSortableDb
      ..battery = FakeBattery()
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('My photos page', () {
    testWidgets('Pressing + sign on MPGo shows SelectPicturePage',
        (tester) async {
      await mockNetworkImages(() async {
        await tester.goToMyPhotos();
        await tester.tap(find.byIcon(AbiliaIcons.plus));
        await tester.pumpAndSettle();
        expect(find.byType(ImportPicturePage), findsOneWidget);
        expect(find.byType(ImageSourceWidget), findsNWidgets(2));
        expect(find.byType(PickField), findsNWidgets(2));
      });
    }, skip: Config.isMP);

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
        expect(find.byType(MenuPage), findsOneWidget);
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
  });
}

extension on WidgetTester {
  Future<void> goToMyPhotos() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.myPhotos));
    await pumpAndSettle();
  }
}
