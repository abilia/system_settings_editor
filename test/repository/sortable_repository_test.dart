import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import '../mocks.dart';

void main() {
  SortableDb sortableDb;
  final baseUrl = 'url';
  final mockClient = MockedClient();
  final userId = 1;
  SortableRepository sortableRepository;
  setUp(() async {
    final db = await DatabaseRepository.createInMemoryFfiDb();
    sortableDb = SortableDb(db);
    sortableRepository = SortableRepository(
      authToken: Fakes.token,
      baseUrl: baseUrl,
      client: mockClient,
      sortableDb: sortableDb,
      userId: userId,
    );
  });

  test('Corrupt data is ignored (Bug SGC-381)', () async {
    // Arrange
    final revision = 0;
    final validSortable = '''{
        "id": "f2916cc4-7ec8-4332-a186-dee81963a73f",
        "owner": 284,
        "revision": 1,
        "revisionTime": 0,
        "deleted": false,
        "type": "imagearchive",
        "data": "{\\"name\\":\\"Handi\\",\\"fileId\\":\\"45e9e593-bd6e-4d2f-aa89-94a9dfb430cf\\",\\"icon\\":\\"/build/whale2/test/data/images/Handi/Handi.png\\"}",
        "group": true,
        "groupId": null,
        "sortOrder": "P",
        "visible": true
    }''';

    final corruptSortable = '''{
        "id": "f2916cc4-7ec8-4332-a186-dee81963a73f",
        "owner": 284,
        "revision": 1,
        "revisionTime": 0,
        "deleted": false,
        "type": "imagearchive",
        "data": "{\\"name\\":\\"Handi\\",\\"fileId\\":\\"45e9e593-bd6e-4d2f-aa89-94a9dfb430cf\\",\\"icon\\":\\"/build/whale2/test/data/images/Handi/Handi.png\\"}",
        "group": true,
        "groupId": 1,
        "sortOrder": "P",
        "visible": true
    }'''; // groupId is 1 and not null or string

    final corruptSortableData = '''{
        "id": "2ad47a70-e4c0-4af2-ac18-8a7c109921f3",
        "owner": 284,
        "revision": 2,
        "revisionTime": 0,
        "deleted": false,
        "type": "baseactivity",
        "data": "{\\"title\\":\\"Basaktivitet\\",\\"icon\\":\\"/handi/user/picture/Delfiner.jpg\\",\\"startTime\\":0,\\"duration\\":0,\\"info\\":\\"{\\\"info-item\\\":[{\\\"type\\\":\\\"checklist\\\",\\\"data\\\":{\\\"checked\\\":{},\\\"questions\\\":[{\\\"name\\\":\\\"väckarklocka\\\",\\\"image\\\":\\\"/build/whale2/test/data/images/Handi/Handi/väckarklocka.gif\\\",\\\"id\\\":0,\\\"checked\\\":false,\\\"fileId\\\":\\\"2ab7acb5-5935-4af1-9bba-a13ece4ad8a2\\\"},{\\\"name\\\":\\\"skola\\\",\\\"image\\\":\\\"/build/whale2/test/data/images/Handi/Handi/skola.gif\\\",\\\"id\\\":1,\\\"checked\\\":false,\\\"fileId\\\":\\\"f07c8cb0-2ec4-44f1-bbda-64e366511819\\\"},{\\\"name\\\":\\\"gympapåse\\\",\\\"image\\\":\\\"/build/whale2/test/data/images/Handi/Handi/gympapåse.gif\\\",\\\"id\\\":2,\\\"checked\\\":false,\\\"fileId\\\":\\\"08eef128-80fa-42cd-ba92-934748c6458e\\\"}]}}]}\\\",\\"removeAfter\\":false,\\"reminders\\":\\"300000\\",\\"checkable\\":false,\\"fullDay\\":false,\\"alarmType\\":98,\\"category\\":\\"\\",\\"fileId\\":\\"2b3e21cc-6bf7-41d9-901d-15506bae45b9\\"}",
        "group": false,
        "groupId": "f2916cc4-7ec8-4332-a186-dee81963a73f",
        "sortOrder": "P",
        "visible": true
    }'''; // category is empty string "" and not null or empty or int (as in bug)

    final sortableJson =
        '[$validSortable, $corruptSortable, $corruptSortableData]';
    final sortableValidJson = '[$validSortable]';

    when(
      mockClient.get(
        '$baseUrl/api/v1/data/$userId/sortableitems?revision=$revision',
        headers: authHeader(Fakes.token),
      ),
    ).thenAnswer(
      (_) => Future.value(
        Response(
          sortableJson,
          200,
        ),
      ),
    );
    final expectedFiles = (json.decode(sortableValidJson) as List)
        .map((l) => DbSortable.fromJson(l).model)
        .map((e) => DbSortable.toType(e.id, e.type, e.data.toRaw(), e.groupId,
            e.sortOrder, e.deleted, e.isGroup, e.visible))
        .toList();

    // Act
    final res = (await sortableRepository.load()).toList();

    // Verify
    expect(res, expectedFiles);
  });
}