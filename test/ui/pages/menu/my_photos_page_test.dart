import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = FakeFlutterLocalNotificationsPlugin();
    scheduleAlarmNotificationsIsolated = noAlarmScheduler;
    final mockSortableDb = MockSortableDb();
    when(() => mockSortableDb.getAllNonDeleted()).thenAnswer(
      (invocation) => Future.value(
        <Sortable<ImageArchiveData>>[
          Sortable.createNew(
            data: const ImageArchiveData(myPhotos: true),
            fixed: true,
          ),
          Sortable.createNew(
            data: const ImageArchiveData(upload: true),
            fixed: true,
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
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: DateTime(2021, 04, 17, 09, 20),
      )
      ..client = Fakes.client()
      ..database = FakeDatabase()
      ..syncDelay = SyncDelays.zero
      ..genericDb = FakeGenericDb()
      ..sortableDb = mockSortableDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('My photos page', () {
    testWidgets('The page shows', (tester) async {
      await tester.goToMyPhotos();
      expect(find.byType(MyPhotosPage), findsOneWidget);
    });

    testWidgets('Can navigate back to menu', (tester) async {
      await tester.goToMyPhotos();
      expect(find.byType(MyPhotosPage), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
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
