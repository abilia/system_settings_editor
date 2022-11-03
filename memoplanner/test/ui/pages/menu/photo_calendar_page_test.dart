import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

import 'package:intl/intl.dart';

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

      final time = DateTime(2021, 04, 17, 09, 20);

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
          ..ticker = Ticker.fake(initialTime: time)
          ..client = Fakes.client()
          ..database = FakeDatabase()
          ..genericDb = FakeGenericDb()
          ..sortableDb = mockSortableDb
          ..battery = FakeBattery()
          ..deviceDb = FakeDeviceDb()
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
        await tester.tap(
          find.widgetWithIcon(IconActionButton, AbiliaIcons.day),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CalendarPage), findsOneWidget);
      });

      testWidgets('Only tagged photos are showing', (tester) async {
        await tester.goToPhotoCalendarPage(pump: true);
        expect(find.byType(PhotoCalendarPage), findsOneWidget);
        expect(find.byType(PhotoCalendarImage), findsOneWidget);
        final image1 = find.byType(PhotoCalendarImage).evaluate().first.widget
            as PhotoCalendarImage;
        expect(image1.fileId, isIn([file3, file4]));

        await tester.tap(find.byType(PhotoCalendarImage));
        await tester.pump(kDoubleTapMinTime);
        await tester.tap(find.byType(PhotoCalendarImage));
        await tester.pumpAndSettle();

        final image2 = find.byType(PhotoCalendarImage).evaluate().first.widget
            as PhotoCalendarImage;
        expect(image2.fileId, isIn([file3, file4]));
        expect(image2.fileId, isNot(image1.fileId));

        await tester.tap(find.byType(PhotoCalendarImage));
        await tester.pump(kDoubleTapMinTime);
        await tester.tap(find.byType(PhotoCalendarImage));
        await tester.pumpAndSettle();

        final image3 = find.byType(PhotoCalendarImage).evaluate().first.widget
            as PhotoCalendarImage;
        expect(image3.fileId, isIn([file3, file4]));
        expect(image3.fileId, isNot(image2.fileId));
      });

      testWidgets(
          'BUG SGC-1655 - Wrong day in header in Menu/photo calendar/screensaver',
          (tester) async {
        final locale = Intl.getCurrentLocale();
        final translate = Locales.language.values.first;
        await tester.goToPhotoCalendarPage(pump: true);
        expect(
          find.text(DateFormat.EEEE(locale).format(time)),
          findsOneWidget,
        );
        expect(find.text(translate.earlyMorning), findsOneWidget);
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
