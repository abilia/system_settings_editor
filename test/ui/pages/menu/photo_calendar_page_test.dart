import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  group(
    'Photo calendar page',
    () {
      const file1 = 'file1';
      const file2 = 'file2';
      const file3 = 'file3';
      const file4 = 'file4';

      setUp(() async {
        setupPermissions();
        notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
        scheduleAlarmNotificationsIsolated = noAlarmScheduler;
        final mockSortableDb = MockSortableDb();

        final myPhotosFolder = Sortable.createNew(
          data: const ImageArchiveData(myPhotos: true),
          fixed: true,
        );

        when(() => mockSortableDb.getAllNonDeleted()).thenAnswer(
          (invocation) => Future.value(
            <Sortable<ImageArchiveData>>[
              myPhotosFolder,
              Sortable.createNew(
                groupId: myPhotosFolder.id,
                isGroup: true,
                data: const ImageArchiveData(name: 'folder'),
              ),
              Sortable.createNew(
                groupId: myPhotosFolder.id,
                data: const ImageArchiveData(
                  name: 'image not in photo-calendar',
                  fileId: file1,
                  file: file1,
                ),
              ),
              Sortable.createNew(
                groupId: 'User created folder',
                data: const ImageArchiveData(
                  name: 'image not in photo-calendar',
                  fileId: file2,
                  file: file2,
                ),
              ),
              Sortable.createNew(
                groupId: myPhotosFolder.id,
                data: ImageArchiveData(
                  name: 'image in photo-calendar',
                  fileId: file3,
                  file: file3,
                  tags:
                      UnmodifiableSetView({ImageArchiveData.photoCalendarTag}),
                ),
              ),
              Sortable.createNew(
                groupId: 'User created folder',
                data: ImageArchiveData(
                  name: 'image in photo-calendar',
                  fileId: file4,
                  file: file4,
                  tags:
                      UnmodifiableSetView({ImageArchiveData.photoCalendarTag}),
                ),
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
          ..ticker = Ticker.fake(initialTime: DateTime(2021, 04, 17, 09, 20))
          ..client = Fakes.client()
          ..database = FakeDatabase()
          ..genericDb = FakeGenericDb()
          ..sortableDb = mockSortableDb
          ..battery = FakeBattery()
          ..init();
      });

      tearDown(GetIt.I.reset);

      testWidgets('The page shows', (tester) async {
        await tester.goToPhotoCalendarPage(pump: true);
        expect(find.byType(PhotoCalendarPage), findsOneWidget);
      });

      testWidgets('Can navigate back to calendar', (tester) async {
        await tester.goToPhotoCalendarPage(pump: true);
        expect(find.byType(PhotoCalendarPage), findsOneWidget);
        await tester.tap(find.byIcon(AbiliaIcons.month));
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      testWidgets('Only tagged photos are showing', (tester) async {
        await tester.goToPhotoCalendarPage(pump: true);
        expect(find.byType(PhotoCalendarPage), findsOneWidget);
        expect(find.byType(PhotoCalendarImage), findsOneWidget);
        var image = find.byType(PhotoCalendarImage).evaluate().first.widget
            as PhotoCalendarImage;
        expect(image.fileId == file3 || image.fileId == file4, isTrue);

        await tester.tap(find.byType(PhotoCalendarImage));
        await tester.pump(kDoubleTapMinTime);
        await tester.tap(find.byType(PhotoCalendarImage));
        await tester.pumpAndSettle();

        image = find.byType(PhotoCalendarImage).evaluate().first.widget
            as PhotoCalendarImage;
        expect(image.fileId == file3 || image.fileId == file4, isTrue);

        await tester.tap(find.byType(PhotoCalendarImage));
        await tester.pump(kDoubleTapMinTime);
        await tester.tap(find.byType(PhotoCalendarImage));
        await tester.pumpAndSettle();

        image = find.byType(PhotoCalendarImage).evaluate().first.widget
            as PhotoCalendarImage;
        expect(image.fileId == file3 || image.fileId == file4, isTrue);
      });
    },
    skip: !Config.isMP,
  );
}

extension on WidgetTester {
  Future<void> goToPhotoCalendarPage({bool pump = false}) async {
    if (pump) await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byType(PhotoCalendarButton));
    await pumpAndSettle();
  }
}
