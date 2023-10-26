import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:generics/generics.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:repository_base/db.dart';
import 'package:repository_base/listenable_client.dart';

class MockBaseUrlDb extends Mock implements BaseUrlDb {}

class MockBaseClient extends Mock implements BaseClient, ListenableClient {}

void main() {
  final mockClient = MockBaseClient();
  final mockBaseUrlDb = MockBaseUrlDb();
  late GenericRepository genericRepository;

  late GenericDb genericDb;
  setUpAll(() {
    registerFallbackValue(Uri());
    when(() => mockBaseUrlDb.baseUrl).thenReturn('aUrl');
  });

  setUp(() async {
    final db = await DatabaseRepository.createInMemoryFfiDb();
    genericDb = GenericDb(db);
    genericRepository = GenericRepository(
      baseUrlDb: mockBaseUrlDb,
      client: mockClient,
      genericDb: genericDb,
      userId: 1,
      noSyncSettings: {},
    );
  });

  tearDown(() async {
    await genericDb.db.delete(DatabaseRepository.genericTableName);
  });

  final synced = Generic.createNew(
    data: GenericSettingData(
      data: false,
      identifier: 'displayAlarmButtonKey',
      type: 'someSetting',
    ),
  );

  test('synchronize - calls get before posting', () async {
    // Arrange
    final getResponse = jsonEncode([
      Generic.createNew(
        data: GenericSettingData(
          data: false,
          identifier: 'id',
          type: 'type',
        ),
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

  test('Do not only fetches memoplannerSettings', () async {
    // Arrange
    final getResponse = jsonEncode([
      Generic.createNew(
        data: GenericSettingData(
          type: 'memoPlannerSettings',
          data: false,
          identifier: 'id',
        ),
      ).wrapWithDbModel(),
      Generic.createNew(
        data: const RawGenericData(
          type: 'type',
          identifier: 'id',
          data: 'data',
        ),
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

    expect(fetched.length, 2);
  });
}
