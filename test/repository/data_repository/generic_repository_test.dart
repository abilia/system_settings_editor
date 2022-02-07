import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  final mockClient = MockBaseClient();
  final mockBaseUrlDb = MockBaseUrlDb();
  late GenericRepository genericRepository;
  late GenericDb genericDb;
  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    final db = await DatabaseRepository.createInMemoryFfiDb();
    genericDb = GenericDb(db);
    genericRepository = GenericRepository(
      authToken: Fakes.token,
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
          identifier: MemoplannerSettings.displayAlarmButtonKey,
        ),
      ),
      unsynced = Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: false,
          identifier: MemoplannerSettings.dotsInTimepillarKey,
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

  group('save', () {
    group('mp', () {
      test('saves all as dirty', () async {
        await genericRepository.save(oneSyncOneUnsync);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAll();
        expect(dirty, oneSyncOneUnsync.map((e) => e.wrapWithDbModel(dirty: 1)));
        expect(all, oneSyncOneUnsync);
      });

      test('saves all unsynced as dirty', () async {
        await genericRepository.save(allUnsynced);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAll();
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
        final all = await genericDb.getAll();
        expect(dirty, [synced.wrapWithDbModel(dirty: 1)]);
        expect(all, unorderedEquals(oneSyncOneUnsync));
      });

      test('save none unsyncables as dirty', () async {
        await genericRepository.save(allUnsynced);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAll();
        expect(dirty, isEmpty);
        expect(all, unorderedEquals(allUnsynced));
      });
    }, skip: !Config.isMPGO);

    test('unsynced settings should not overwrite revision', () async {
      // Arrange
      final data2 = Generic.createNew<MemoplannerSettingData>(
        data: MemoplannerSettingData.fromData(
          data: 200,
          identifier: MemoplannerSettings.viewOptionsZoomKey,
        ),
      );
      await genericRepository.db.insert([
        Generic.createNew<MemoplannerSettingData>(
          data: MemoplannerSettingData.fromData(
            data: 100,
            identifier: MemoplannerSettings.viewOptionsZoomKey,
          ),
        ).wrapWithDbModel(revision: 1) as DbModel<Generic<GenericData>>,
        data2.wrapWithDbModel(revision: 2) as DbModel<Generic<GenericData>>,
      ]);

      // Act
      final data3 = data2.copyWithNewData(
        newData: MemoplannerSettingData.fromData(
          data: 300,
          identifier: MemoplannerSettings.viewOptionsZoomKey,
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
      genericRepository = GenericRepository(
        authToken: Fakes.token,
        baseUrlDb: MockBaseUrlDb(),
        client: Fakes.client(genericResponse: () => repsonseAll),
        genericDb: genericDb,
        userId: 1,
      );
    });

    test('revision 0 stores all incoming generics', () async {
      final res = await genericRepository.load();
      final all = await genericDb.getAll();

      expect(all, unorderedEquals(repsonseAll));
      expect(res, unorderedEquals(repsonseAll));
    });

    test('revision >0 stores only syncable generics', () async {
      await genericDb.insert([
        unsynced.wrapWithDbModel(revision: 1) as DbModel<Generic<GenericData>>
      ]);

      final res = await genericRepository.load();
      final all = await genericDb.getAll();

      expect(all, unorderedEquals(oneSyncOneUnsync));
      expect(res, unorderedEquals(oneSyncOneUnsync));
    });
  });
}
