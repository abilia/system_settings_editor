import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sortables/models/all.dart';

void main() {
  test('parse json test', () {
    const id = 'f1069915-ac41-4d74-9449-b8842637b924';
    const revision = 12345;
    const type = 'imagearchive';
    const data =
        '{\\"name\\":\\"DVD\\",\\"file\\":\\"/images/Handi/Handi/DVD_2.gif\\"}';
    const expectedRawData =
        '{"name":"DVD","file":"/images/Handi/Handi/DVD_2.gif"}';
    const expectedData = ImageArchiveData(
      file: '/images/Handi/Handi/DVD_2.gif',
      name: 'DVD',
    );

    const groupId = 'a82c92c0-bee2-4689-9f5d-954de468d5ed';
    const sortOrder = '12309{}';
    const sortableJson = '''
    [
      {
        "id": "$id",
        "revision": $revision,
        "deleted": false,
        "type": "$type",
        "data": "$data",
        "group": false,
        "groupId": "$groupId",
        "sortOrder": "$sortOrder",
        "visible": true
      }
    ]
      ''';

    final sortables = (json.decode(sortableJson) as List)
        .map((e) => DbSortable.fromJson(e))
        .toList();

    expect(sortables.length, 1);
    final dbS = sortables.first;
    final s = dbS.sortable;
    expect(s.id, id);
    expect(s.deleted, false);
    expect(s.type, type);
    expect(s.data.toRaw(), expectedRawData);
    expect(s.isGroup, false);
    expect(s.groupId, groupId);
    expect(s.sortOrder, sortOrder);
    expect(s.visible, true);
    expect(dbS.dirty, 0);
    expect(dbS.revision, revision);
    expect(s, isA<Sortable<RawSortableData>>());

    final archive = ImageArchiveData.fromJson(s.data.toRaw());
    expect(archive, expectedData);
    expect(archive, isA<ImageArchiveData>());
  });

  test('To dbMap and back', () {
    final dbMap = {
      'id': 'id-111',
      'type': 'type',
      'data': 'dbdata',
      'group_id': 'group_id',
      'sort_order': 'sort_order',
      'deleted': 1,
      'is_group': 1,
      'visible': 1,
      'revision': 999,
      'dirty': 1,
      'fixed': 0,
    };
    final dbSortable = DbSortable.fromDbMap(dbMap);
    expect(dbSortable.dirty, 1);
    expect(dbSortable.revision, 999);
    final s = dbSortable.sortable;
    expect(s.id, 'id-111');
    expect(s.data, const RawSortableData('dbdata'));
    expect(s.type, 'type');
    expect(s.groupId, 'group_id');
    expect(s.sortOrder, 'sort_order');
    expect(s.isGroup, true);
    expect(s.visible, true);
    expect(s.deleted, true);
    expect(s.fixed, false);

    final mapAgain = dbSortable.toMapForDb();
    expect(mapAgain, dbMap);
  });

  test('SGC-902, null in db parses to empty string', () {
    final dbMap = {
      'id': 'cc8cc2c3-5fc7-4343-8bd6-4db0952cd80c',
      'type': SortableType.imageArchive,
      'data': '{"name":"","icon":""}',
      'group_id': null,
      'sort_order': 'wsdfgh',
      'deleted': 1,
      'is_group': 1,
      'visible': 1,
      'revision': 0,
      'dirty': 0,
    };
    final s = DbSortable.fromDbMap(dbMap).sortable;
    expect(s.groupId, '');
    expect(s.data, const ImageArchiveData());
  });

  test('Get correct type when ImageArchiveData', () {
    final s = Sortable.createNew(
      data: const ImageArchiveData(),
    );
    expect(s.type, SortableType.imageArchive);
  });

  test('Get correct type when NoteData', () {
    final s = Sortable.createNew(
      data: const NoteData(),
    );
    expect(s.type, SortableType.note);
  });

  test('Get correct type when BasicActivityDataItem', () {
    final s = Sortable.createNew(
      data: BasicActivityDataItem.createNew(title: 'title'),
    );
    expect(s.type, SortableType.basicActivity);
  });

  test('Get correct type when BasicActivityDataFolder', () {
    final s = Sortable.createNew(
      data: BasicActivityDataFolder.createNew(name: 'foldername'),
    );
    expect(s.type, SortableType.basicActivity);
  });

  test('Get correct type when BasicTimerDataItem', () {
    final s = Sortable.createNew(
      data: BasicTimerDataItem.fromJson(
        '{'
        '"title":"title",'
        '"duration":60000'
        '}',
      ),
    );
    expect(s.type, SortableType.basicTimer);
  });

  test('Get correct type when BasicTimerDataFolder', () {
    final s = Sortable.createNew(
      data: BasicTimerDataFolder.fromJson('{"title":"title"}'),
    );
    expect(s.type, SortableType.basicTimer);
  });

  test('SGC-1525 Sorting basic timers deletes name (and duration) in list', () {
    const title = 'basicTimerTitle';
    const duration = 1000;
    final dbMap = {
      'id': 'cc8cc2c3-5fc7-4343-8bd6-4db0952cd80c',
      'type': SortableType.basicTimer,
      'data': '{"title":"$title","icon":"", "duration":$duration}',
      'group_id': null,
      'sort_order': 'wsdfgh',
      'deleted': 1,
      'is_group': 0,
      'visible': 1,
      'revision': 0,
      'dirty': 0,
    };
    final timer = DbSortable.fromDbMap(dbMap).sortable;
    final converted = BasicTimerDataItem.fromJson(timer.data.toRaw());
    expect(title, converted.basicTimerTitle);
    expect(duration, converted.duration);
  });

  test('BUG-2480 parsing issue when secretExemptions does not exist', () {
    const data = '{"checkable":false,'
        '"alarmType":100,'
        '"icon":"/Handi/User/Picture/shower.gif",'
        '"category":0,'
        '"title":"Shower",'
        '"info":null,'
        '"fullDay":false,'
        '"removeAfter":true,'
        '"fileId":"334f2339-ef6a-4fcb-91a1-917f4b45bb53",'
        '"startTime":0,'
        '"reminders":"",'
        '"duration":0}';

    final result = BasicActivityDataItem.fromJson(data);
    expect(<int>{}, result.secretExemptions);
  });
}
