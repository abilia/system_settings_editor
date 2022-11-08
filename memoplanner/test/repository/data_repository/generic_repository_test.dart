import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'package:memoplanner/config.dart';
import 'package:memoplanner/db/all.dart';
import '../../fakes/fake_client.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';

import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  final mockClient = MockBaseClient();
  final mockBaseUrlDb = MockBaseUrlDb();
  late GenericRepository genericRepository;
  late GenericDb genericDb;
  setUpAll(() {
    when(() => mockBaseUrlDb.baseUrl).thenReturn('aUrl');
    registerFallbackValues();
  });

  setUp(() async {
    final db = await DatabaseRepository.createInMemoryFfiDb();
    genericDb = GenericDb(db);
    genericRepository = GenericRepository(
      baseUrlDb: mockBaseUrlDb,
      client: mockClient,
      genericDb: genericDb,
      userId: 1,
    );
  });

  tearDown(() {
    genericDb.db.delete(DatabaseRepository.genericTableName);
  });

  final synced = Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: ActivityViewSettings.displayAlarmButtonKey,
        ),
      ),
      unsynced = Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: DayCalendarViewOptionsSettings.viewOptionsDotsKey,
        ),
      );
  final oneSyncOneUnsync = [synced, unsynced];

  final allUnsynced = MemoplannerSettings.noSyncSettings
      .map(
        (e) => Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: false,
            identifier: e,
          ),
        ),
      )
      .toList();

  test('synchronize - calls get before posting', () async {
    // Arrange
    final getResponse = jsonEncode([
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(data: false, identifier: 'id'),
      ).wrapWithDbModel()
    ]);
    final postResponse = jsonEncode({
      'previousRevision': 1,
      'failedUpdates': [],
      'dataRevisionUpdates': [],
    });
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) => Future.value(Response(getResponse, 200)));
    when(() => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer((_) => Future.value(Response(postResponse, 200)));
    await genericRepository.save([synced]);

    // Act
    await genericRepository.synchronize();

    // Verify
    verifyInOrder([
      () => mockClient.get(any(), headers: any(named: 'headers')),
      () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
    ]);
  });

  test('Only fetches memoplannerSettings', () async {
    // Arrange
    final getResponse = jsonEncode([
      Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(data: false, identifier: 'id'),
      ).wrapWithDbModel(),
      Generic.createNew<RawGenericData>(
        data: RawGenericData('data', 'identifier'),
      ).wrapWithDbModel(),
    ]);
    final postResponse = jsonEncode({
      'previousRevision': 1,
      'failedUpdates': [],
      'dataRevisionUpdates': [],
    });
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) => Future.value(Response(getResponse, 200)));
    when(() => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        )).thenAnswer((_) => Future.value(Response(postResponse, 200)));

    // Act
    // ignore: invalid_use_of_protected_member
    final fetched = await genericRepository.fetchData(0);

    expect(fetched.length, 1);
  });

  group('save', () {
    group('mp', () {
      test('saves all as dirty', () async {
        await genericRepository.save(oneSyncOneUnsync);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAllNonDeleted();
        expect(dirty, oneSyncOneUnsync.map((e) => e.wrapWithDbModel(dirty: 1)));
        expect(all, oneSyncOneUnsync);
      });

      test('saves all unsynced as dirty', () async {
        await genericRepository.save(allUnsynced);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAllNonDeleted();
        expect(
            dirty,
            unorderedEquals(
                allUnsynced.map((e) => e.wrapWithDbModel(dirty: 1))));
        expect(all.toList(), unorderedEquals(allUnsynced));
      });
    }, skip: !Config.isMP);

    group('mpgo', () {
      test('only save syncables dirty', () async {
        await genericRepository.save(oneSyncOneUnsync);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAllNonDeleted();
        expect(dirty, [synced.wrapWithDbModel(dirty: 1)]);
        expect(all, unorderedEquals(oneSyncOneUnsync));
      });

      test('save none unsyncables as dirty', () async {
        await genericRepository.save(allUnsynced);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAllNonDeleted();
        expect(dirty, isEmpty);
        expect(all, unorderedEquals(allUnsynced));
      });
    }, skip: !Config.isMPGO);

    test('unsynced settings should not overwrite revision', () async {
      // Arrange
      final data2 = Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: 200,
          identifier:
              DayCalendarViewOptionsSettings.viewOptionsTimepillarZoomKey,
        ),
      );
      await genericRepository.db.insert([
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: 100,
            identifier:
                DayCalendarViewOptionsSettings.viewOptionsTimepillarZoomKey,
          ),
        ).wrapWithDbModel(revision: 1) as DbModel<Generic<GenericData>>,
        data2.wrapWithDbModel(revision: 2) as DbModel<Generic<GenericData>>,
      ]);

      // Act
      final data3 = data2.copyWithNewData(
        newData: MemoplannerSettingData.fromData(
          data: 300,
          identifier:
              DayCalendarViewOptionsSettings.viewOptionsTimepillarZoomKey,
        ),
      );
      final allMaxRevisionPre = await genericDb.getAllNonDeletedMaxRevision();
      await genericRepository.save([data3]);
      final allMaxRevisionPost = await genericDb.getAllNonDeletedMaxRevision();
      final byId = await genericDb.getById(data2.id);

      // Assert
      expect(allMaxRevisionPre.single, data2);
      expect(allMaxRevisionPost.single, data3);
      if (Config.isMP) {
        expect(byId, data3.wrapWithDbModel(revision: 2, dirty: 1));
      } else {
        expect(byId, data3.wrapWithDbModel(revision: 2, dirty: 0));
      }
    });
  });
  group('load', () {
    final repsonseAll = [...allUnsynced, synced];

    setUp(() {
      final mockBaseUrlDb = MockBaseUrlDb();
      when(() => mockBaseUrlDb.baseUrl).thenReturn('baseUrl');
      genericRepository = GenericRepository(
        baseUrlDb: mockBaseUrlDb,
        client: Fakes.client(genericResponse: () => repsonseAll),
        genericDb: genericDb,
        userId: 1,
      );
    });

    test('revision 0 stores all incoming generics', () async {
      await genericRepository.synchronize();
      final res = await genericRepository.getAll();
      final all = await genericDb.getAllNonDeleted();

      expect(all, unorderedEquals(repsonseAll));
      expect(res, unorderedEquals(repsonseAll));
    });

    test('revision >0 stores only syncable generics', () async {
      await genericDb.insert([
        unsynced.wrapWithDbModel(revision: 1) as DbModel<Generic<GenericData>>
      ]);

      await genericRepository.synchronize();
      final res = await genericRepository.getAll();
      final all = await genericDb.getAllNonDeleted();

      expect(all, unorderedEquals(oneSyncOneUnsync));
      expect(res, unorderedEquals(oneSyncOneUnsync));
    });
  });
}
