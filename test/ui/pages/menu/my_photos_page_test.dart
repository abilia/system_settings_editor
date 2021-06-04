// @dart=2.9

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/background/all.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/main.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../mocks.dart';

void main() {
  final initialTime = DateTime(2021, 04, 17, 09, 20);
  Iterable<Sortable> sortables = [];
  SortableDb sortableDb;

  setUp(() async {
    setupPermissions();
    notificationsPluginInstance = MockFlutterLocalNotificationsPlugin();

    sortableDb = MockSortableDb();
    when(sortableDb.getAllNonDeleted())
        .thenAnswer((_) => Future.value(sortables));
    when(sortableDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(sortableDb.insertAndAddDirty(any))
        .thenAnswer((realInvocation) => Future.value([]));

    final mockBatch = MockBatch();
    when(mockBatch.commit()).thenAnswer((realInvocation) => Future.value([]));
    final db = MockDatabase();
    when(db.batch()).thenReturn(mockBatch);
    when(db.rawQuery(any)).thenAnswer((realInvocation) => Future.value([]));

    GetItInitializer()
      ..sharedPreferences = await MockSharedPreferences.getInstance()
      ..ticker = Ticker(
        stream: StreamController<DateTime>().stream,
        initialTime: initialTime,
      )
      ..client = Fakes.client()
      ..alarmScheduler = noAlarmScheduler
      ..database = db
      ..syncDelay = SyncDelays.zero
      ..genericDb = MockGenericDb()
      ..sortableDb = sortableDb
      ..init();
  });

  tearDown(GetIt.I.reset);

  group('My photos page', () {
    testWidgets('The page shows and my photos folder is created',
        (tester) async {
      await tester.goToMyPhotos();
      expect(find.byType(MyPhotosPage), findsOneWidget);
      await verifyMyPhotosCreated(tester, sortableDb);
    });

    testWidgets('Can navigate back to menu', (tester) async {
      await tester.goToMyPhotos();
      expect(find.byType(MyPhotosPage), findsOneWidget);
      await tester.tap(find.byType(CloseButton));
      await tester.pumpAndSettle();
      expect(find.byType(MenuPage), findsOneWidget);
    });
  }, skip: !Config.isMP);
}

extension on WidgetTester {
  Future<void> pumpApp() async {
    await pumpWidget(App());
    await pumpAndSettle();
  }

  Future<void> goToMyPhotos() async {
    await pumpApp();
    await tap(find.byType(MenuButton));
    await pumpAndSettle();
    await tap(find.byIcon(AbiliaIcons.my_photos));
    await pumpAndSettle();
  }
}

Future verifyMyPhotosCreated(WidgetTester tester, SortableDb sortableDb) async {
  final v = verify(sortableDb.insertAndAddDirty(captureAny));
  expect(v.callCount, 1);
  final sortable = v.captured.single.first as Sortable<ImageArchiveData>;
  expect(sortable.data.myPhotos, isTrue);
}
