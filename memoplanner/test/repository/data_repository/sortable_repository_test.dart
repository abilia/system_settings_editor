import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_fakes/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../mocks/mocks.dart';
import '../../test_helpers/register_fallback_values.dart';

void main() {
  const baseUrl = 'url';
  late MockBaseClient mockClient;
  const userId = 1;
  late SortableRepository sortableRepository;
  late Database db;

  setUpAll(() async {
    registerFallbackValues();
    db = await DatabaseRepository.createInMemoryFfiDb();
    SharedPreferences.setMockInitialValues({'base-url': baseUrl});
  });

  setUp(() async {
    mockClient = MockBaseClient();
    sortableRepository = SortableRepository(
      baseUrlDb: BaseUrlDb(await SharedPreferences.getInstance()),
      client: mockClient,
      sortableDb: SortableDb(db),
      userId: userId,
    );
  });

  tearDown(() => DatabaseRepository.clearAll(db));

  test('Corrupt data is ignored (Bug SGC-381)', () async {
    // Arrange
    const revision = 0;
    const validSortable = '''{
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

    const corruptSortable = '''{
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

    const corruptSortableData = '''{
        "id": "2ad47a70-e4c0-4af2-ac18-8a7c109921f3",
        "owner": 284,
        "revision": 2,
        "revisionTime": 0,
        "deleted": false,
        "type": "baseactivity",
        "data": "{\\"title\\":\\"Basaktivitet\\",\\"icon\\":\\"/handi/user/picture/Delfiner.jpg\\",\\"startTime\\":0,\\"duration\\":0,\\"info\\":\\"{\\"info-item\\":[{\\"type\\":\\"checklist\\",\\"data\\":{\\"checked\\":{},\\"questions\\":[{\\"name\\":\\"väckarklocka\\",\\"image\\":\\"/build/whale2/test/data/images/Handi/Handi/väckarklocka.gif\\",\\"id\\":0,\\"checked\\":false,\\"fileId\\":\\"2ab7acb5-5935-4af1-9bba-a13ece4ad8a2\\"},{\\"name\\":\\"skola\\",\\"image\\":\\"/build/whale2/test/data/images/Handi/Handi/skola.gif\\",\\"id\\":1,\\"checked\\":false,\\"fileId\\":\\"f07c8cb0-2ec4-44f1-bbda-64e366511819\\"},{\\"name\\":\\"gympapåse\\",\\"image\\":\\"/build/whale2/test/data/images/Handi/Handi/gympapåse.gif\\",\\"id\\":2,\\"checked\\":false,\\"fileId\\":\\"08eef128-80fa-42cd-ba92-934748c6458e\\"}]}}]}\\",\\"removeAfter\\":false,\\"reminders\\":\\"300000\\",\\"checkable\\":false,\\"fullDay\\":false,\\"alarmType\\":98,\\"category\\":\\"\\",\\"fileId\\":\\"2b3e21cc-6bf7-41d9-901d-15506bae45b9\\"}",
        "group": false,
        "groupId": "f2916cc4-7ec8-4332-a186-dee81963a73f",
        "sortOrder": "P",
        "visible": true
    }'''; // category is empty string "" and not null or empty or int (as in bug)

    const sortableJson =
        '[$validSortable, $corruptSortable, $corruptSortableData]';
    const sortableValidJson = '[$validSortable]';

    when(
      () => mockClient.get(
          '$baseUrl/api/v1/data/$userId/sortableitems?revision=$revision'
              .toUri()),
    ).thenAnswer(
      (_) => Future.value(
        Response.bytes(
          utf8.encode(sortableJson),
          200,
        ),
      ),
    );
    final expectedFiles = (json.decode(sortableValidJson) as List)
        .map((l) => DbSortable.fromJson(l).model)
        .map(
          (e) => DbSortable.toType(
            e.id,
            e.type,
            e.data.toRaw(),
            e.groupId,
            e.sortOrder,
            e.deleted,
            e.isGroup,
            e.visible,
            e.fixed,
          ),
        )
        .toList();

    // Act
    await sortableRepository.synchronize();
    final res = (await sortableRepository.getAll()).toList();

    // Verify
    expect(res, expectedFiles);
  });

  test('synchronize - calls get before posting', () async {
    // Arrange
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) => Future.value(Response('[]', 200)));

    // Act
    await sortableRepository.synchronize();

    // Verify
    verify(() => mockClient.get(any(), headers: any(named: 'headers')));
  });

  test('createMyPhotosFolder calls backend', () async {
    // Arrange
    const id = '98bfb4d8-d1f6-4a83-a29f-a5e8b2fec9d6';
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer(
      (_) => Future.value(
        Response(
          '{'
          '"id":"$id",'
          '"owner":330,'
          '"revision":2,'
          '"revisionTime":0,'
          '"deleted":false,'
          '"type":"imagearchive",'
          '"data":'
          '"{'
          '\\"name\\":\\"Mina foton\\",'
          '\\"icon\\":\\"/images/folder_bg_my_photos.jpg\\",'
          '\\"fileId\\":\\"0bf2dd92-7eec-4d36-acc4-fa0c2cbb6de4\\",'
          '\\"myPhotos\\":true'
          '}",'
          '"group":true,'
          '"groupId":null,'
          '"sortOrder":"N",'
          '"visible":true,'
          '"fixed":true'
          '}',
          200,
        ),
      ),
    );

    // Act
    final folder = await sortableRepository.createMyPhotosFolder();
    expect(folder?.model.id, id);

    // Verify
    final captured = verify(
            () => mockClient.get(captureAny(), headers: any(named: 'headers')))
        .captured;

    expect(captured, hasLength(1));
    final firstcall = captured.first;
    expect(firstcall, isA<Uri>());
    expect(
      (firstcall as Uri).pathSegments.last,
      SortableRepository.myPhotosPath,
    );
  });

  test('createUploadsFolder calls backend', () async {
    const id = 'da5003df-cad9-475b-9695-d46618871188';
    // Arrange
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer(
      (_) => Future.value(
        Response(
          '{'
          '"id":"$id",'
          '"owner":330,'
          '"revision":1,"revisionTime":0,"deleted":false,"type":"imagearchive",'
          '"data":'
          '"{'
          '\\"name\\":\\"Mobilbilder\\",'
          '\\"icon\\":\\"/images/folder_bg_mobile_devices.jpg\\",'
          '\\"fileId\\":\\"0bf2dd92-7eec-4d36-acc4-fa0c2cbb6de4\\",'
          '\\"upload\\":true'
          '}",'
          '"group":true,'
          '"groupId":null,'
          '"sortOrder":"N",'
          '"visible":true,'
          '"fixed":true'
          '}',
          200,
        ),
      ),
    );

    // Act
    final folder = await sortableRepository.createUploadsFolder();

    // Verify
    expect(folder?.model.id, id);
    final captured = verify(
      () => mockClient.get(captureAny(), headers: any(named: 'headers')),
    ).captured;

    expect(captured, hasLength(1));
    final firstcall = captured.first;
    expect(firstcall, isA<Uri>());
    expect(
      (firstcall as Uri).pathSegments.last,
      SortableRepository.mobileUploadPath,
    );
  });

  test('createMyPhotosFolder fails returns null', () async {
    // Arrange
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer(
      (_) => Future.value(
        Response('', 404),
      ),
    );

    // Act
    final folder = await sortableRepository.createMyPhotosFolder();
    expect(folder, null);
  });

  test('createUploadsFolder fails returns null', () async {
    // Arrange
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer(
      (_) => Future.value(
        Response('', 404),
      ),
    );
    // Act
    final folder = await sortableRepository.createUploadsFolder();
    expect(folder, null);
  });

  test('applyTemplate apply correct template', () async {
    // Arrange
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) => Future.value(Response('''
[
    {
        "id": "54fabe78-7a0d-4956-91bd-cefde5664518",
        "templateId": 256,
        "name": "memoplanner_sv",
        "language": "sv"
    },
    {
        "id": "6942900c-ebe0-4b64-a08f-8eb37a2f8737",
        "templateId": 257,
        "name": "memoplanner_nb",
        "language": "nb"
    },
    {
        "id": "0b236c31-a64c-4e33-8869-a71c0b5a3d9d",
        "templateId": 258,
        "name": "memoplanner_en",
        "language": "en"
    },
    {
        "id": "3ab0425c-459b-465f-99ca-c981e6d1e505",
        "templateId": 259,
        "name": "memoplanner_da",
        "language": "da"
    },
    {
        "id": "a0396cb9-dfb7-4761-91d3-3e9118b54fc0",
        "templateId": 297,
        "name": "memoplanner_nl",
        "language": "nl"
    },
    {
        "id": "a767ebec-50db-4f5f-8acf-d653c59c1418",
        "templateId": 338,
        "name": "memoplanner_fi",
        "language": "fi"
    },
    {
        "id": "116d6e8e-1269-4629-ae18-3409f8d6a0dc",
        "templateId": 358,
        "name": "memoplanner_de",
        "language": "de"
    },
    {
        "id": "c5fe7999-0ae0-4383-a15d-7b16b056554e",
        "templateId": 412,
        "name": "data",
        "language": "sv"
    },
    {
        "id": "66cf650a-be48-4c2d-95de-962f25294485",
        "templateId": 431,
        "name": "pontusBasData",
        "language": "en"
    }
]
''', 200)));
    when(() => mockClient.post(any(), headers: any(named: 'headers')))
        .thenAnswer((_) => Future.value(Response('', 200)));
    // Act
    final f = await sortableRepository.applyTemplate('fi');
    // Assert
    expect(f, isTrue);
    verify(() => mockClient.get(any(), headers: any(named: 'headers')))
        .called(1);
    final capturedPost = verify(
            () => mockClient.post(captureAny(), headers: any(named: 'headers')))
        .captured
        .single;
    expect(capturedPost.pathSegments,
        contains('a767ebec-50db-4f5f-8acf-d653c59c1418'));
  });

  test('No gewa templates are fetched', () async {
    when(() => mockClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer(
      (_) => Future.value(
        Response(
          '[{'
          '"id":"1234567890","owner":1,"revision":1,"revisionTime":0,"deleted":false,'
          '"type":"imagearchive",'
          '"data":'
          '"{'
          '\\"name\\":\\"Folder\\",'
          '\\"icon\\":\\"/images/an_image.jpg\\",'
          '\\"fileId\\":\\"0bf2dd92-7eec-4d36-acc4-fa0c2cbb6de4\\",'
          '}",'
          '"group":true,"groupId":null,"sortOrder":"N","visible":true'
          '},'
          '{'
          '"id":"99999999","owner":1,"revision":2,"revisionTime":0,"deleted":false,'
          '"type":"gewaTemplate",'
          '"data":'
          '"{'
          '\\"name\\":\\"gewatemplate\\",'
          '}",'
          '"group":false,"groupId":null,"sortOrder":"N","visible":true'
          '}]',
          200,
        ),
      ),
    );
    // ignore: invalid_use_of_protected_member
    final sortables = await sortableRepository.fetchData(0);
    expect(sortables.length, 1);
    expect(sortables.first.model.type, SortableType.imageArchive);
  });
}
