// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/db/generic_db.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/repository/all.dart';

import '../../mocks.dart';

void main() {
  final mockClient = MockedClient();
  GenericRepository genericRepository;
  setUp(() async {
    final db = await DatabaseRepository.createInMemoryFfiDb();
    genericRepository = GenericRepository(
      authToken: Fakes.token,
      baseUrl: 'url',
      client: mockClient,
      genericDb: GenericDb(db),
      userId: 1,
    );
  });

  test('synchronize - calls get before posting', () async {
    // Arrange
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) => Future.value(Response('[]', 200)));

    // Act
    await genericRepository.synchronize();

    // Verify
    verify(mockClient.get(any, headers: anyNamed('headers')));
  });
}
