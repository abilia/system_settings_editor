// @dart=2.9

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/config.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/db/generic_db.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import '../../mocks.dart';

void main() {
  final mockClient = MockedClient();
  GenericRepository genericRepository;
  GenericDb genericDb;

  setUp(() async {
    final db = await DatabaseRepository.createInMemoryFfiDb();
    genericDb = GenericDb(db);
    genericRepository = GenericRepository(
      authToken: Fakes.token,
      baseUrl: 'url',
      client: mockClient,
      genericDb: genericDb,
      userId: 1,
    );
  });

  tearDown(() {
    genericDb.db.delete(DatabaseRepository.GENERIC_TABLE_NAME);
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
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) => Future.value(Response(getResponse, 200)));
    when(mockClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) => Future.value(Response(postResponse, 200)));
    await genericRepository.save([synced]);

    // Act
    await genericRepository.synchronize();

    // Verify
    verifyInOrder([
      mockClient.get(any, headers: anyNamed('headers')),
      mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
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
      test('only save syncalbes dirty', () async {
        await genericRepository.save(oneSyncOneUnsync);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAll();
        expect(dirty, [synced.wrapWithDbModel(dirty: 1)]);
        expect(all, unorderedEquals(oneSyncOneUnsync));
      });

      test('save none unsyncalbes as dirty', () async {
        await genericRepository.save(allUnsynced);
        final dirty = await genericDb.getAllDirty();
        final all = await genericDb.getAll();
        expect(dirty, isEmpty);
        expect(all, unorderedEquals(allUnsynced));
      });
    }, skip: !Config.isMPGO);
  });
  group('load', () {
    final repsonseAll = [...allUnsynced, synced];

    setUp(() {
      genericRepository = GenericRepository(
        authToken: Fakes.token,
        baseUrl: 'url',
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
      await genericDb.insert([unsynced.wrapWithDbModel(revision: 1)]);

      final res = await genericRepository.load();
      final all = await genericDb.getAll();

      expect(all, unorderedEquals(oneSyncOneUnsync));
      expect(res, unorderedEquals(oneSyncOneUnsync));
    });
  });
}
